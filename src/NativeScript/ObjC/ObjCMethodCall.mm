//
//  ObjCMethodCall.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "ObjCMethodCall.h"
#include "AllocatedPlaceholder.h"
#include "Interop.h"
#include "Metadata.h"
#include "ObjCConstructorDerived.h"
#include "ObjCPrototype.h"
#include "ObjCSuperObject.h"
#include "ObjCTypes.h"
#include "ObjCWrapperObject.h"
#include "ReleasePool.h"
#include "TypeFactory.h"
#include <objc/message.h>

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

const ClassInfo ObjCMethodWrapper::s_info = { "ObjCMethodWrapper", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCMethodWrapper) };

void ObjCMethodWrapper::finishCreation(VM& vm, GlobalObject* globalObject, std::vector<const MemberMeta*> methods) {
    ASSERT(methods.size() > 0);
    Base::finishCreation(vm, methods.front()->jsName());

    size_t maxParamsCount = 0;
    for (auto m : methods) {

        const MethodMeta* method = (const MethodMeta*)m;

        const TypeEncoding* encodings = method->encodings()->first();

        auto returnTypeCell = globalObject->typeFactory()->parseType(globalObject, /*r*/ encodings, false);
        auto parameterTypesCells = globalObject->typeFactory()->parseTypes(globalObject, /*r*/ encodings, method->encodings()->count - 1, false);

        if (parameterTypesCells.size() > maxParamsCount) {
            maxParamsCount = parameterTypesCells.size();
        }

        std::unique_ptr<ObjCMethodCall> call(new ObjCMethodCall(this, method));
        call->initializeFFI(vm, { &preInvocation, &postInvocation }, returnTypeCell.get(), parameterTypesCells, 2);
        call->_retainsReturnedCocoaObjects = method->ownsReturnedCocoaObject();
        call->_isOptional = method->isOptional();
        call->_isInitializer = method->isInitializer();
        call->_hasErrorOutParameter = method->hasErrorOutParameter();

        if (call->_hasErrorOutParameter) {
            call->_argumentCountValidator = [](FFICall* call, ExecState* execState) {
                return execState->argumentCount() == call->parametersCount() || execState->argumentCount() == call->parametersCount() - 1;
            };
        }

        call->_msgSend = reinterpret_cast<void*>(&objc_msgSend);
        call->_msgSendSuper = reinterpret_cast<void*>(&objc_msgSendSuper);

#if defined(__i386__)
        const unsigned X86_RET_STRUCTPOP = 10;

        const ffi_type* returnFFIType = call->returnType().ffiType;
        if (returnFFIType->type == FFI_TYPE_FLOAT || returnFFIType->type == FFI_TYPE_DOUBLE || returnFFIType->type == FFI_TYPE_LONGDOUBLE) {
            call->_msgSend = reinterpret_cast<void*>(&objc_msgSend_fpret);
        } else if (call->cif()->flags == X86_RET_STRUCTPOP) {
            call->_msgSend = reinterpret_cast<void*>(&objc_msgSend_stret);
            call->_msgSendSuper = reinterpret_cast<void*>(&objc_msgSendSuper_stret);
        }
#elif defined(__x86_64__)
        const unsigned UNIX64_FLAG_RET_IN_MEM = (1 << 10);

        const ffi_type* returnFFIType = call->returnType().ffiType;
        if (returnFFIType->type == FFI_TYPE_LONGDOUBLE) {
            call->_msgSend = reinterpret_cast<void*>(&objc_msgSend_fpret);
        } else if (returnFFIType->type == FFI_TYPE_STRUCT && (call->cif()->flags & UNIX64_FLAG_RET_IN_MEM)) {
            call->_msgSend = reinterpret_cast<void*>(&objc_msgSend_stret);
            call->_msgSendSuper = reinterpret_cast<void*>(&objc_msgSendSuper_stret);
        }
#elif defined(__arm__) && !defined(__LP64__)
        const unsigned ARM_TYPE_STRUCT = 6;

        if (call->cif()->flags == ARM_TYPE_STRUCT) {
            call->_msgSend = reinterpret_cast<void*>(&objc_msgSend_stret);
            call->_msgSendSuper = reinterpret_cast<void*>(&objc_msgSendSuper_stret);
        }
#endif

        call->setSelector(method->selector());
        this->_functionsContainer.push_back(std::move(call));
    }
    Base::initializeFunctionWrapper(vm, maxParamsCount);
}

static bool isJavaScriptDerived(JSC::JSValue value) {
    if (value.isCell()) {
        JSCell* cell = value.asCell();
        const Structure* structure = cell->structure();
        const ClassInfo* info = structure->classInfo();
        if (info == ObjCWrapperObject::info()) {
            JSC::JSValue prototype = structure->storedPrototype();
            return prototype.isCell() && prototype.asCell()->classInfo(*cell->vm()) != ObjCPrototype::info();
        } else {
            return info == ObjCConstructorDerived::info() || info == ObjCSuperObject::info();
        }
    }

    return false;
}

void ObjCMethodWrapper::preInvocation(FFICall* callee, ExecState* execState, FFICall::Invocation& invocation) {
    ObjCMethodCall* call = static_cast<ObjCMethodCall*>(callee);

    JSC::VM& vm = execState->vm();
    if (!(execState->thisValue().inherits(vm, ObjCConstructorBase::info()) || execState->thisValue().inherits(vm, ObjCWrapperObject::info()) || execState->thisValue().inherits(vm, AllocatedPlaceholder::info()) || execState->thisValue().inherits(vm, ObjCSuperObject::info()))) {
        auto scope = DECLARE_THROW_SCOPE(vm);

        throwVMError(execState, scope, createError(execState, "This value is not a native object."_s));
        return;
    }

    id target = NativeScript::toObject(execState, execState->thisValue());

    if (call->_hasErrorOutParameter && call->parameterTypesCells().size() - 1 == execState->argumentCount()) {
        std::vector<NSError*> outError = { nil };
        invocation.setArgument(call->argsCount() - 1, outError.data());
        releaseSoon(execState, std::move(outError));
    }

    if (isJavaScriptDerived(execState->thisValue())) {
        std::unique_ptr<objc_super> super = std::make_unique<objc_super>();
        super->receiver = target;
        super->super_class = class_getSuperclass(object_getClass(target));
#ifdef DEBUG_OBJC_INVOCATION
        bool isInstance = !class_isMetaClass(object_getClass(target));
        NSLog(@"> %@[%@(%@) %@]", isInstance ? @"-" : @"+", NSStringFromClass(object_getClass(target)), NSStringFromClass(super->super_class), NSStringFromSelector(call->_selector));
#endif
        invocation.setArgument(0, super.get());
        invocation.setArgument(1, call->_selector);
        invocation.function = call->_msgSendSuper;
        releaseSoon(execState, std::move(super));
    } else {
#ifdef DEBUG_OBJC_INVOCATION
        bool isInstance = !class_isMetaClass(object_getClass(target));
        NSLog(@"> %@[%@ %@]", isInstance ? @"-" : @"+", NSStringFromClass(object_getClass(target)), NSStringFromSelector(call->_selector));
#endif
        if (call->_isOptional && ![target respondsToSelector:call->_selector]) {
            // Unimplemented optional method: Silently perform a dummy call to nil object
            invocation.setArgument(0, nil);
        } else {
            invocation.setArgument(0, target);
        }
        invocation.setArgument(1, call->_selector);
        invocation.function = call->_msgSend;
    }
}

void ObjCMethodWrapper::postInvocation(FFICall* callee, ExecState* execState, FFICall::Invocation& invocation) {
    ObjCMethodCall* call = static_cast<ObjCMethodCall*>(callee);
    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    if (call->retainsReturnedCocoaObjects() || (asObject(execState->thisValue())->classInfo(vm) == AllocatedPlaceholder::info() && call->_isInitializer)) {
        [invocation.getResult<id>() release];
    }

    if (call->_hasErrorOutParameter && call->parameterTypesCells().size() - 1 == execState->argumentCount()) {
        if (NSError* error = *invocation.getArgument<NSError**>(call->argsCount() - 1)) {
            scope.throwException(execState, interop(execState)->wrapError(execState, error));
        }
    }
}
}
