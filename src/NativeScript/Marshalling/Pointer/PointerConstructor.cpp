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

const ClassInfo PointerConstructor::s_info = { "Pointer", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(PointerConstructor) };

void PointerConstructor::finishCreation(VM& vm, PointerPrototype* pointerPrototype) {
    Base::finishCreation(vm, this->classInfo()->className);

    this->_ffiTypeMethodTable.ffiType = &ffi_type_pointer;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.write = &write;
    this->_ffiTypeMethodTable.canConvert = &canConvert;
    this->_ffiTypeMethodTable.encode = &encode;

    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, pointerPrototype, PropertyAttribute::DontEnum | PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
    this->putDirectWithoutTransition(vm, vm.propertyNames->length, jsNumber(1), PropertyAttribute::ReadOnly | PropertyAttribute::DontEnum | PropertyAttribute::DontDelete);
}

EncodedJSValue JSC_HOST_CALL PointerConstructor::constructPointerInstance(ExecState* execState) {
    void* value = nullptr;
    if (execState->argumentCount() == 1) {
        value = reinterpret_cast<void*>(execState->argument(0).toUInt32(execState));
    }

    JSValue result = jsCast<GlobalObject*>(execState->lexicalGlobalObject())->interop()->pointerInstanceForPointer(execState, value);
    return JSValue::encode(result);
}

JSValue PointerConstructor::read(ExecState* execState, const void* buffer, JSCell* self) {
    const void* data = *reinterpret_cast<void* const*>(buffer);

    if (!data) {
        return jsNull();
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    return globalObject->interop()->pointerInstanceForPointer(execState, const_cast<void*>(data));
}

void PointerConstructor::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    if (value.isUndefinedOrNull()) {
        *reinterpret_cast<void**>(buffer) = nullptr;
        return;
    }

    bool hasHandle;
    JSC::VM& vm = execState->vm();
    void* handle = tryHandleofValue(vm, value, &hasHandle);
    if (!hasHandle) {
        auto scope = DECLARE_THROW_SCOPE(vm);

        JSValue exception = createError(execState, WTF::ASCIILiteral("Value is not a pointer."));
        scope.throwException(execState, exception);
        return;
    }

    *reinterpret_cast<void**>(buffer) = handle;
}

void PointerConstructor::postCall(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
}

bool PointerConstructor::canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    JSC::VM& vm = execState->vm();
    return value.isUndefinedOrNull() || value.inherits(vm, ReferenceInstance::info()) || value.inherits(vm, PointerInstance::info());
}

const char* PointerConstructor::encode(VM&, JSCell* cell) {
    return "^v";
}
} // namespace NativeScript
