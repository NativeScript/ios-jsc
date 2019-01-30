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
        auto arg0 = execState->argument(0);

        if (arg0.isObject()) {
            if (JSWrapperObject* wrapper = jsCast<JSWrapperObject*>(arg0)) {
                arg0 = wrapper->internalValue();
            }
        }

        if (!arg0.isAnyInt()) {
            auto scope = DECLARE_THROW_SCOPE(execState->vm());
            return throwVMError(execState, scope, createError(execState, "Pointer constructor's first arg must be an integer."_s));
        }
#if __SIZEOF_POINTER__ == 8
        // JSC stores 64-bit integers as doubles in JSValue.
        // Caution: This means that pointers with more than 54 significant bits
        // are likely to be rounded and misrepresented!
        // However, current OS and hardware implementations are using 48 bits,
        // so we're safe at the time being.
        // See https://en.wikipedia.org/wiki/X86-64#Virtual_address_space_details
        // and https://en.wikipedia.org/wiki/ARM_architecture#ARMv8-A
        value = reinterpret_cast<void*>(arg0.asAnyInt());
#else
        value = reinterpret_cast<void*>(arg0.toInt32(execState));
#endif
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

        JSValue exception = createError(execState, "Value is not a pointer."_s);
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
