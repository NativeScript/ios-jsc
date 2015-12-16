//
//  ObjCMethodCall.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "ObjCMethodCall.h"
#include <objc/message.h>
#include "ObjCTypes.h"
#include "ObjCPrototype.h"
#include "ObjCConstructorDerived.h"
#include "ObjCSuperObject.h"
#include "ObjCWrapperObject.h"
#include "TypeFactory.h"
#include "Metadata.h"
#include "AllocatedPlaceholder.h"
#include "ReleasePool.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

const ClassInfo ObjCMethodCall::s_info = { "ObjCMethodCall", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCMethodCall) };

void ObjCMethodCall::finishCreation(VM& vm, GlobalObject* globalObject, const MethodMeta* metadata) {
    Base::finishCreation(vm, metadata->jsName());
    const TypeEncoding* encodings = metadata->encodings()->first();

    JSCell* returnTypeCell = globalObject->typeFactory()->parseType(globalObject, encodings);
    const WTF::Vector<JSCell*> parameterTypesCells = globalObject->typeFactory()->parseTypes(globalObject, encodings, metadata->encodings()->count - 1);

    Base::initializeFFI(vm, { &preInvocation, &postInvocation }, returnTypeCell, parameterTypesCells, 2);
    this->_retainsReturnedCocoaObjects = metadata->ownsReturnedCocoaObject();
    this->_isInitializer = metadata->isInitializer();
    this->_hasErrorOutParameter = metadata->hasErrorOutParameter();

    if (this->_hasErrorOutParameter) {
        this->_argumentCountValidator = [](FFICall* call, ExecState* execState) {
            return execState->argumentCount() == call->parametersCount() ||
                   execState->argumentCount() == call->parametersCount() - 1;
        };
    }

    this->_msgSend = reinterpret_cast<void*>(&objc_msgSend);
    this->_msgSendSuper = reinterpret_cast<void*>(&objc_msgSendSuper);

#if defined(__i386__)
    const ffi_type* returnFFIType = this->_returnType.ffiType;
    if (returnFFIType->type == FFI_TYPE_FLOAT || returnFFIType->type == FFI_TYPE_DOUBLE || returnFFIType->type == FFI_TYPE_LONGDOUBLE) {
        this->_msgSend = reinterpret_cast<void*>(&objc_msgSend_fpret);
    } else if (returnFFIType->type == FFI_TYPE_STRUCT && returnFFIType->size > 8) {
        this->_msgSend = reinterpret_cast<void*>(&objc_msgSend_stret);
        this->_msgSendSuper = reinterpret_cast<void*>(&objc_msgSendSuper_stret);
    }
#elif defined(__x86_64__)
    const ffi_type* returnFFIType = this->_returnType.ffiType;
    if (returnFFIType->type == FFI_TYPE_LONGDOUBLE) {
        this->_msgSend = reinterpret_cast<void*>(&objc_msgSend_fpret);
    } else if (returnFFIType->type == FFI_TYPE_STRUCT && returnFFIType->size >= 32) {
        this->_msgSend = reinterpret_cast<void*>(&objc_msgSend_stret);
        this->_msgSendSuper = reinterpret_cast<void*>(&objc_msgSendSuper_stret);
    }
#elif defined(__arm__) && !defined(__LP64__)
    const ffi_type* returnFFIType = this->_returnType.ffiType;
    if (returnFFIType->type == FFI_TYPE_STRUCT) {
        this->_msgSend = reinterpret_cast<void*>(&objc_msgSend_stret);
        this->_msgSendSuper = reinterpret_cast<void*>(&objc_msgSendSuper_stret);
    }
#endif

    this->setSelector(metadata->selector());
}

static bool isJavaScriptDerived(JSC::JSValue value) {
    if (value.isCell()) {
        JSCell* cell = value.asCell();
        const Structure* structure = cell->structure();
        const ClassInfo* info = structure->classInfo();
        if (info == ObjCWrapperObject::info()) {
            JSC::JSValue prototype = structure->storedPrototype();
            return prototype.isCell() && prototype.asCell()->classInfo() != ObjCPrototype::info();
        } else {
            return info == ObjCConstructorDerived::info() || info == ObjCSuperObject::info();
        }
    }

    return false;
}

void ObjCMethodCall::preInvocation(FFICall* callee, ExecState* execState, FFICall::Invocation& invocation) {
    ObjCMethodCall* call = jsCast<ObjCMethodCall*>(callee);
    id target = NativeScript::toObject(execState, execState->thisValue());

    if (call->_hasErrorOutParameter && call->_parameterTypesCells.size() - 1 == execState->argumentCount()) {
        std::vector<NSError*> outError = { nil };
        invocation.setArgument(call->_argsCount - 1, outError.data());
        releaseSoon(execState, std::move(outError));
    }

    if (isJavaScriptDerived(execState->thisValue())) {
        std::unique_ptr<objc_super> super = std::make_unique<objc_super>();
        super->receiver = target;
        super->super_class = class_getSuperclass(object_getClass(target));
#ifdef DEBUG_OBJC_INVOCATION
        bool isInstance = !class_isMetaClass(object_getClass(target));
        NSLog(@"> %@[%@(%@) %@]", isInstance ? @"-" : @"+", NSStringFromClass(object_getClass(target)), NSStringFromClass(super->super_class), NSStringFromSelector(this->selector()));
#endif
        invocation.setArgument(0, super.get());
        invocation.setArgument(1, call->_selector);
        invocation.function = call->_msgSendSuper;
        releaseSoon(execState, std::move(super));
    } else {
#ifdef DEBUG_OBJC_INVOCATION
        bool isInstance = !class_isMetaClass(object_getClass(target));
        NSLog(@"> %@[%@ %@]", isInstance ? @"-" : @"+", NSStringFromClass(object_getClass(target)), NSStringFromSelector(this->selector()));
#endif
        invocation.setArgument(0, target);
        invocation.setArgument(1, call->_selector);
        invocation.function = call->_msgSend;
    }
}

void ObjCMethodCall::postInvocation(FFICall* callee, ExecState* execState, FFICall::Invocation& invocation) {
    ObjCMethodCall* call = jsCast<ObjCMethodCall*>(callee);

    if (call->retainsReturnedCocoaObjects() || (asObject(execState->thisValue())->classInfo() == AllocatedPlaceholder::info() && call->_isInitializer)) {
        [invocation.getResult<id>() release];
    }

    if (call->_hasErrorOutParameter && call->_parameterTypesCells.size() - 1 == execState->argumentCount()) {
        if (NSError* error = *invocation.getArgument<NSError**>(call->_argsCount - 1)) {
            execState->vm().throwException(execState, toValue(execState, error));
        }
    }
}
}
