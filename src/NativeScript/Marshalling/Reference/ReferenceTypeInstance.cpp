//
//  ReferenceTypeInstance.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 21.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "ReferenceTypeInstance.h"
#include "Interop.h"
#include "ReferenceInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ReferenceTypeInstance::s_info = { "ReferenceTypeInstance", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ReferenceTypeInstance) };

JSValue ReferenceTypeInstance::read(ExecState* execState, const void* buffer, JSCell* self) {
    const void* data = *reinterpret_cast<void* const*>(buffer);

    if (!data) {
        return jsNull();
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    ReferenceTypeInstance* referenceType = jsCast<ReferenceTypeInstance*>(self);

    PointerInstance* pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState, const_cast<void*>(data)));
    return ReferenceInstance::create(execState->vm(), globalObject, globalObject->interop()->referenceInstanceStructure(), referenceType->innerType(), pointer).get();
}

void ReferenceTypeInstance::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    ReferenceTypeInstance* referenceType = jsCast<ReferenceTypeInstance*>(self);

    if (value.isUndefinedOrNull()) {
        *reinterpret_cast<void**>(buffer) = nullptr;
        return;
    }

    if (ReferenceInstance* reference = jsDynamicCast<ReferenceInstance*>(execState->vm(), value)) {
        if (!reference->data()) {
            GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
            reference->createBackingStorage(execState->vm(), globalObject, execState, referenceType->innerType());
        }
    }

    bool hasHandle;
    JSC::VM& vm = execState->vm();
    void* handle = tryHandleofValue(vm, value, &hasHandle);
    if (!hasHandle) {
        auto scope = DECLARE_THROW_SCOPE(vm);

        JSValue exception = createError(execState, value, "is not a reference."_s, defaultSourceAppender);
        scope.throwException(execState, exception);
        return;
    }

    *reinterpret_cast<void**>(buffer) = handle;
}

bool ReferenceTypeInstance::canConvert(ExecState* execState, const JSValue& value, JSCell* buffer) {
    JSC::VM& vm = execState->vm();
    return value.isUndefinedOrNull() || value.inherits(vm, ReferenceInstance::info()) || value.inherits(vm, PointerInstance::info());
}

const char* ReferenceTypeInstance::encode(VM& vm, JSCell* cell) {
    ReferenceTypeInstance* self = jsCast<ReferenceTypeInstance*>(cell);

    if (!self->_compilerEncoding.empty()) {
        return self->_compilerEncoding.c_str();
    }

    self->_compilerEncoding = "^";
    const FFITypeMethodTable& table = getFFITypeMethodTable(vm, self->_innerType.get());
    self->_compilerEncoding += table.encode(vm, self->_innerType.get());
    return self->_compilerEncoding.c_str();
}

void ReferenceTypeInstance::finishCreation(JSC::VM& vm, JSCell* innerType) {
    Base::finishCreation(vm);

    this->_ffiTypeMethodTable.ffiType = &ffi_type_pointer;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.write = &write;
    this->_ffiTypeMethodTable.canConvert = &canConvert;
    this->_ffiTypeMethodTable.encode = &encode;

    this->_innerType.set(vm, this, innerType);
}

void ReferenceTypeInstance::visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    ReferenceTypeInstance* object = jsCast<ReferenceTypeInstance*>(cell);
    visitor.append(object->_innerType);
}

CallType ReferenceTypeInstance::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &readFromPointer;
    return CallType::Host;
}
} // namespace NativeScript
