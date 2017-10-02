//
//  FFICall.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "FFICall.h"
#include "FFICache.h"
#include <JavaScriptCore/Interpreter.h>
#include <JavaScriptCore/JSPromiseDeferred.h>
#include <JavaScriptCore/StrongInlines.h>
#include <dispatch/dispatch.h>
#include <malloc/malloc.h>

namespace NativeScript {
using namespace JSC;

const ClassInfo FFICall::s_info = { "FFICall", &Base::s_info, 0, CREATE_METHOD_TABLE(FFICall) };

void deleteCif(ffi_cif* cif) {
    delete[] cif->arg_types;
    delete cif;
}

void FFICall::initializeFFI(VM& vm, const InvocationHooks& hooks, JSCell* returnType, const Vector<JSCell*>& parameterTypes, size_t initialArgumentIndex) {
    this->_invocationHooks = hooks;

    this->_initialArgumentIndex = initialArgumentIndex;

    this->_returnTypeCell.set(vm, this, returnType);
    this->_returnType = getFFITypeMethodTable(returnType);

    size_t parametersCount = parameterTypes.size();
    this->putDirect(vm, vm.propertyNames->length, jsNumber(parametersCount), ReadOnly | DontEnum | DontDelete);

    const ffi_type** parameterTypesFFITypes = new const ffi_type*[parametersCount + initialArgumentIndex];

    this->signatureVector.push_back(getFFITypeMethodTable(returnType).ffiType);

    for (size_t i = 0; i < initialArgumentIndex; ++i) {
        parameterTypesFFITypes[i] = &ffi_type_pointer;
        this->signatureVector.push_back(&ffi_type_pointer);
    }

    for (size_t i = 0; i < parametersCount; i++) {
        JSCell* parameterTypeCell = parameterTypes[i];
        this->_parameterTypesCells.append(WriteBarrier<JSCell>(vm, this, parameterTypeCell));

        const FFITypeMethodTable& ffiTypeMethodTable = getFFITypeMethodTable(parameterTypeCell);
        this->_parameterTypes.append(ffiTypeMethodTable);

        parameterTypesFFITypes[i + initialArgumentIndex] = ffiTypeMethodTable.ffiType;
        this->signatureVector.push_back(parameterTypesFFITypes[i + initialArgumentIndex]);
    }

    this->_cif = checkForExistingCif(parametersCount + initialArgumentIndex, const_cast<ffi_type*>(this->_returnType.ffiType), const_cast<ffi_type**>(parameterTypesFFITypes));

    this->_argsCount = _cif->nargs;
    this->_stackSize = 0;

    this->_argsArrayOffset = this->_stackSize;
    this->_stackSize += malloc_good_size(sizeof(void * [this->_cif->nargs]));

    this->_returnOffset = this->_stackSize;
    this->_stackSize += malloc_good_size(std::max(this->_cif.get()->rtype->size, sizeof(ffi_arg)));

    for (size_t i = 0; i < this->_argsCount; i++) {
        this->_argValueOffsets.push_back(this->_stackSize);
        this->_stackSize += malloc_good_size(std::max(this->_cif->arg_types[i]->size, sizeof(ffi_arg)));
    }
}

std::shared_ptr<ffi_cif> FFICall::checkForExistingCif(unsigned int nargs, ffi_type* rtype, ffi_type** atypes) {

    std::unordered_map<std::vector<const ffi_type*>, std::shared_ptr<ffi_cif>, SignatureHash>::const_iterator it = FFICache::global()->cifCache.find(this->signatureVector);

    if (it == FFICache::global()->cifCache.end()) {
        std::shared_ptr<ffi_cif> shared(new ffi_cif, deleteCif);
        ffi_prep_cif(shared.get(), FFI_DEFAULT_ABI, nargs, rtype, atypes);
        FFICache::global()->cifCache[this->signatureVector] = shared;
    }

    return FFICache::global()->cifCache[this->signatureVector];
}

FFICall::~FFICall() {

    if (this->_cif.use_count() == 2) {
        std::unordered_map<std::vector<const ffi_type*>, std::shared_ptr<ffi_cif>, SignatureHash>::const_iterator it;
        it = FFICache::global()->cifCache.find(this->signatureVector);
        FFICache::global()->cifCache.erase(it);
    }
}

void FFICall::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    FFICall* ffiCall = jsCast<FFICall*>(cell);
    visitor.append(&ffiCall->_returnTypeCell);
    visitor.append(ffiCall->_parameterTypesCells.begin(), ffiCall->_parameterTypesCells.end());
}

CallType FFICall::getCallData(JSCell*, CallData& callData) {
    callData.native.function = &call;
    return JSC::CallType::Host;
}

EncodedJSValue JSC_HOST_CALL FFICall::call(ExecState* execState) {
    FFICall* callee = jsCast<FFICall*>(execState->callee());
    Invocation invocation(callee);
    ReleasePoolHolder releasePoolHolder(execState);

    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    callee->preCall(execState, invocation);
    callee->_invocationHooks.pre(callee, execState, invocation);
    if (scope.exception()) {
        return JSValue::encode(scope.exception());
    }

    {
        JSLock::DropAllLocks locksDropper(execState);
        ffi_call(callee->_cif.get(), FFI_FN(invocation.function), invocation._buffer + callee->_returnOffset, reinterpret_cast<void**>(invocation._buffer + callee->_argsArrayOffset));
    }

    JSValue result = callee->_returnType.read(execState, invocation._buffer + callee->_returnOffset, callee->_returnTypeCell.get());

    if (InvocationHook post = callee->_invocationHooks.post) {
        post(callee, execState, invocation);
    }

    return JSValue::encode(result);
}

JSObject* FFICall::async(ExecState* execState, JSValue thisValue, const ArgList& arguments) {
    __block std::unique_ptr<Invocation> invocation(new Invocation(this));
    ReleasePoolHolder releasePoolHolder(execState);

    Register* fakeCallFrame = new Register[CallFrame::headerSizeInRegisters + execState->argumentCount() + 1];
    ExecState* fakeExecState = ExecState::create(fakeCallFrame);

    fakeExecState->setArgumentCountIncludingThis(arguments.size() + 1);
    fakeExecState->setCallee(this);
    fakeExecState->setThisValue(thisValue);
    fakeExecState->setCodeBlock(nullptr);
    fakeExecState->setCallerFrame(execState->callerFrame());
    for (size_t i = 0; i < arguments.size(); i++) {
        fakeExecState->setArgument(i, arguments.at(i));
    }
    ASSERT(fakeExecState->argumentCount() == arguments.size());

    {
        JSC::VM& vm = execState->vm();
        auto scope = DECLARE_THROW_SCOPE(vm);

        TopCallFrameSetter frameSetter(execState->vm(), fakeExecState);
        this->preCall(fakeExecState, *invocation);
        this->_invocationHooks.pre(this, fakeExecState, *invocation);
        if (Exception* exception = scope.exception()) {
            delete[] fakeCallFrame;
            return exception;
        }
    }

    JSPromiseDeferred* deferred = JSPromiseDeferred::create(execState, execState->lexicalGlobalObject());
    auto* releasePool = new ReleasePoolBase::Item(releasePoolHolder.relinquish());
    __block Strong<FFICall> callee(execState->vm(), this);

    dispatch_async(dispatch_get_global_queue(0, 0), ^{

      JSC::VM& vm = fakeExecState->vm();
      auto scope = DECLARE_CATCH_SCOPE(vm);

      ffi_call(callee->_cif.get(), FFI_FN(invocation->function), invocation->resultBuffer(), reinterpret_cast<void**>(invocation->_buffer + callee->_argsArrayOffset));

      JSLockHolder lockHolder(fakeExecState);
      // we no longer have a valid caller on the stack, what with being async and all
      fakeExecState->setCallerFrame(CallFrame::noCaller());

      JSValue result;
      {
          TopCallFrameSetter frameSetter(fakeExecState->vm(), fakeExecState);
          result = _returnType.read(fakeExecState, invocation->_buffer + _returnOffset, _returnTypeCell.get());

          if (InvocationHook post = _invocationHooks.post) {
              post(this, fakeExecState, *invocation);
          }
      }

      if (Exception* exception = scope.exception()) {
          scope.clearException();
          CallData rejectCallData;
          CallType rejectCallType = JSC::getCallData(deferred->reject(), rejectCallData);

          MarkedArgumentBuffer rejectArguments;
          rejectArguments.append(exception->value());
          JSC::call(fakeExecState->lexicalGlobalObject()->globalExec(), deferred->reject(), rejectCallType, rejectCallData, jsUndefined(), rejectArguments);
      } else {
          CallData resolveCallData;
          CallType resolveCallType = JSC::getCallData(deferred->resolve(), resolveCallData);

          MarkedArgumentBuffer resolveArguments;
          resolveArguments.append(result);
          JSC::call(fakeExecState->lexicalGlobalObject()->globalExec(), deferred->resolve(), resolveCallType, resolveCallData, jsUndefined(), resolveArguments);
      }

      delete[] fakeCallFrame;
      delete releasePool;
    });

    return deferred->promise();
}
} // namespace NativeScript
