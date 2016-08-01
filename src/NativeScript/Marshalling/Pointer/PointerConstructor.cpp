//
//  PointerConstructor.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/17/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "PointerConstructor.h"
#include "Interop.h"
#include "PointerInstance.h"
#include "PointerPrototype.h"
#include "ReferenceInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo PointerConstructor::s_info = { "Pointer", &Base::s_info, 0, CREATE_METHOD_TABLE(PointerConstructor) };

void PointerConstructor::finishCreation(VM& vm, PointerPrototype* pointerPrototype) {
    Base::finishCreation(vm, this->classInfo()->className);

    this->_ffiTypeMethodTable.ffiType = &ffi_type_pointer;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.write = &write;
    this->_ffiTypeMethodTable.canConvert = &canConvert;
    this->_ffiTypeMethodTable.encode = &encode;

    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, pointerPrototype, DontEnum | DontDelete | ReadOnly);
    this->putDirectWithoutTransition(vm, vm.propertyNames->length, jsNumber(1), ReadOnly | DontEnum | DontDelete);
}

static EncodedJSValue JSC_HOST_CALL constructPointerInstance(ExecState* execState) {
    void* value = nullptr;
    if (execState->argumentCount() == 1) {
        value = reinterpret_cast<void*>(execState->argument(0).toUInt32(execState));
    }

    JSValue result = jsCast<GlobalObject*>(execState->lexicalGlobalObject())->interop()->pointerInstanceForPointer(execState->vm(), value);
    return JSValue::encode(result);
}

ConstructType PointerConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = &constructPointerInstance;
    return ConstructTypeHost;
}

CallType PointerConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &constructPointerInstance;
    return CallTypeHost;
}

JSValue PointerConstructor::read(ExecState* execState, const void* buffer, JSCell* self) {
    const void* data = *reinterpret_cast<void* const*>(buffer);

    if (!data) {
        return jsNull();
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    return globalObject->interop()->pointerInstanceForPointer(execState->vm(), const_cast<void*>(data));
}

void PointerConstructor::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    if (value.isUndefinedOrNull()) {
        *reinterpret_cast<void**>(buffer) = nullptr;
        return;
    }

    bool hasHandle;
    void* handle = tryHandleofValue(value, &hasHandle);
    if (!hasHandle) {
        JSValue exception = createError(execState, WTF::ASCIILiteral("Value is not a pointer."));
        execState->vm().throwException(execState, exception);
        return;
    }

    *reinterpret_cast<void**>(buffer) = handle;
}

void PointerConstructor::postCall(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
}

bool PointerConstructor::canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return value.isUndefinedOrNull() || value.inherits(ReferenceInstance::info()) || value.inherits(PointerInstance::info());
}

const char* PointerConstructor::encode(JSCell* cell) {
    return "^v";
}
}
