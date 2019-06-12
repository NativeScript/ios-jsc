//
//  FunctionWrapper.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "FFICache.h"
#include "FFICall.h"
#include "ObjCTypes.h"
#include <JavaScriptCore/JSObjectRef.h>
#include <JavaScriptCore/JSPromiseDeferred.h>
#include <JavaScriptCore/interpreter/FrameTracers.h>
#include <JavaScriptCore/interpreter/Interpreter.h>
#include <JavaScriptCore/runtime/Error.h>
#include <dispatch/dispatch.h>
#include <malloc/malloc.h>

#include "FunctionWrapper.h"
#include "Metadata.h"

#import "TNSRuntime.h"

namespace NativeScript {
using namespace JSC;

JSObject* createErrorFromNSException(TNSRuntime* runtime, ExecState* execState, NSException* exception) {
    JSObject* error = createError(execState, [[exception reason] UTF8String]);

    JSGlobalContextRef context = runtime.globalContext;
    JSValueRef wrappedException = [runtime convertObject:exception];
    JSStringRef nativeExceptionPropertyName = JSStringCreateWithUTF8CString("nativeException");
    JSObjectSetProperty(context, (JSObjectRef)error, nativeExceptionPropertyName,
                        wrappedException, kJSPropertyAttributeNone, NULL);
    JSStringRelease(nativeExceptionPropertyName);

    return error;
}

const ClassInfo FunctionWrapper::s_info = { "FunctionWrapper", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(FunctionWrapper) };

void FunctionWrapper::initializeFunctionWrapper(VM& vm, size_t maxParametersCount) {

    this->putDirect(vm, vm.propertyNames->length, jsNumber(maxParametersCount), PropertyAttribute::ReadOnly | PropertyAttribute::DontEnum | PropertyAttribute::DontDelete);
}

void FunctionWrapper::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    FunctionWrapper* wrapper = jsCast<FunctionWrapper*>(cell);

    for (std::unique_ptr<FFICall>& func : wrapper->functionsContainer()) {
        visitor.append(func->returnTypeCell());
        visitor.append(func->parameterTypesCells().begin(), func->parameterTypesCells().end());
    }
}

FunctionWrapper::~FunctionWrapper() {
    WTF::LockHolder lock(FFICache::global()->_cacheLock);
    for (std::unique_ptr<FFICall>& func : this->_functionsContainer) {
        if (func->cif().use_count() == 2) {
            FFICache::FFIMap::const_iterator it;
            it = FFICache::global()->cifCache.find(func->signatureVector);
            if (it != FFICache::global()->cifCache.end()) {
                FFICache::global()->cifCache.erase(it);
            }
        }
    }
}

EncodedJSValue JSC_HOST_CALL FunctionWrapper::call(ExecState* execState) {
    FunctionWrapper* call = jsCast<FunctionWrapper*>(execState->callee().asCell());

    const std::unique_ptr<FFICall>& c = Metadata::getProperFunctionFromContainer<std::unique_ptr<FFICall>>(call->functionsContainer(), execState->argumentCount(), [](const std::unique_ptr<FFICall>& fficall) { return static_cast<int>(fficall.get()->parametersCount()); });
    FFICall* callee = c.get();

    ASSERT(callee);

    FFICall::Invocation invocation(callee);
    ReleasePoolHolder releasePoolHolder(execState);

    JSC::VM& vm = execState->vm();

    [[TNSRuntime current] tryCollectGarbage];

    auto scope = DECLARE_THROW_SCOPE(vm);

    callee->preCall(execState, invocation);
    if (scope.exception()) {
        return JSValue::encode(scope.exception());
    }

    @try {
        {
            JSLock::DropAllLocks locksDropper(execState);
            ffi_call(callee->cif()->get(), FFI_FN(invocation.function), invocation.resultBuffer(), reinterpret_cast<void**>(invocation._buffer + callee->argsArrayOffset()));
        }

        if (scope.exception()) {
            return JSValue::encode(scope.exception());
        }

        JSValue result = callee->returnType().read(execState, invocation._buffer + callee->returnOffset(), callee->returnTypeCell().get());

        return JSValue::encode(result);
    } @catch (NSException* exception) {
        return throwVMError(execState, scope, createErrorFromNSException([TNSRuntime current], execState, exception));
    } @finally {
        callee->postCall(execState, invocation);
    }
}

JSObject* FunctionWrapper::async(ExecState* execState, JSValue thisValue, const ArgList& arguments) {
    size_t fakeExecStateArgsSize = arguments.size() + 1;

    const std::unique_ptr<FFICall>& c = Metadata::getProperFunctionFromContainer<std::unique_ptr<FFICall>>(this->_functionsContainer, fakeExecStateArgsSize, [](const std::unique_ptr<FFICall>& fficall) { return static_cast<int>(fficall.get()->parametersCount()); });
    FFICall* call = c.get();

    __block std::unique_ptr<FFICall::Invocation> invocation(new FFICall::Invocation(call));
    ReleasePoolHolder releasePoolHolder(execState);

    JSC::VM& vm = execState->vm();

    Register* fakeCallFrame = new Register[CallFrame::headerSizeInRegisters + execState->argumentCount() + 1];
    ExecState* fakeExecState = ExecState::create(fakeCallFrame);

    fakeExecState->setArgumentCountIncludingThis(fakeExecStateArgsSize);
    fakeExecState->setCallee(this);
    fakeExecState->setThisValue(thisValue);
    fakeExecState->setCodeBlock(nullptr);
    fakeExecState->setCallerFrame(execState->callerFrame());

    __block Vector<Strong<JSCell>> argsOwner(arguments.size() + 1);

    if (thisValue.isCell()) {
        argsOwner.append(Strong<JSCell>(vm, thisValue.asCell()));
    }

    for (size_t i = 0; i < arguments.size(); i++) {
        fakeExecState->setArgument(i, arguments.at(i));
        if (arguments.at(i).isCell()) {
            argsOwner.append(Strong<JSCell>(vm, arguments.at(i).asCell()));
        }
    }
    ASSERT(fakeExecState->argumentCount() == arguments.size());

    __block auto deferred = Strong<JSPromiseDeferred>(vm, JSPromiseDeferred::tryCreate(execState, execState->lexicalGlobalObject()));
    auto* releasePool = new ReleasePoolBase::Item(releasePoolHolder.relinquish());
    __block Strong<FunctionWrapper> callee(vm, this);
    TNSRuntime* runtime = [TNSRuntime current];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      JSLockHolder lockHolder(vm);
      auto scope = DECLARE_CATCH_SCOPE(vm);

      [[TNSRuntime current] tryCollectGarbage];

      // we no longer have a valid caller on the stack, what with being async and all
      fakeExecState->setCallerFrame(fakeExecState->lexicalGlobalObject()->globalExec());
      TopCallFrameSetter frameSetter(vm, fakeExecState);

      call->preCall(fakeExecState, *invocation);

      JSValue result;
      if (!scope.exception()) {
          @try {
              // Native call is made outside of the VM lock by design.
              // For more information see https://github.com/NativeScript/ios-runtime/issues/215 and it's corresponding PR.
              // This creates a racing condition which might corrupt the internal state of the VM but
              // a fix for it is outside of this PR's scope, so I'm leaving it like it has always been.
              JSLock::DropAllLocks locksDropper(fakeExecState);

              ffi_call(call->cif()->get(), FFI_FN(invocation->function), invocation->resultBuffer(), reinterpret_cast<void**>(invocation->_buffer + call->argsArrayOffset()));

          } @catch (NSException* ex) {
              auto throwScope = DECLARE_THROW_SCOPE(vm);
              throwVMError(fakeExecState, throwScope, JSValue(createErrorFromNSException(runtime, fakeExecState, ex)));
          }

          // The result is invalid and could crash on read when an exception has been thrown.
          if (!scope.exception()) {
              result = call->returnType().read(fakeExecState, invocation->_buffer + call->returnOffset(), call->returnTypeCell().get());
          }

          call->postCall(fakeExecState, *invocation);
      }

      if (Exception* ex = scope.exception()) {
          scope.clearException();

          CallData rejectCallData;
          CallType rejectCallType = JSC::getCallData(vm, deferred->reject(), rejectCallData);

          MarkedArgumentBuffer rejectArguments;
          rejectArguments.append(ex->value());
          JSC::call(fakeExecState->lexicalGlobalObject()->globalExec(), deferred->reject(), rejectCallType, rejectCallData, jsUndefined(), rejectArguments);
      } else {
          CallData resolveCallData;
          CallType resolveCallType = JSC::getCallData(vm, deferred->resolve(), resolveCallData);

          MarkedArgumentBuffer resolveArguments;
          resolveArguments.append(result);
          JSC::call(fakeExecState->lexicalGlobalObject()->globalExec(), deferred->resolve(), resolveCallType, resolveCallData, jsUndefined(), resolveArguments);
      }
      delete[] fakeCallFrame;
      delete releasePool;
      // release `this` value and arguments
      argsOwner.clear();
    });

    return deferred->promise();
}

} // namespace NativeScript
