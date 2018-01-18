//
//  ConstantArrayTypeInstance.cpp
//  NativeScript
//
//  Created by Deyan Ginev on 8.01.18.
//

#include "ConstantArrayTypeInstance.h"
#include "Interop.h"
#include "PointerInstance.h"
#include "ReferenceInstance.h"
#include "ReferenceTypeInstance.h"
#include "ffi.h"

namespace NativeScript {
using namespace JSC;
typedef ReferenceTypeInstance Base;

const ClassInfo ConstantArrayTypeInstance::s_info = { "ConstantArrayTypeInstance", &Base::s_info, 0, CREATE_METHOD_TABLE(ConstantArrayTypeInstance) };

JSValue ConstantArrayTypeInstance::read(ExecState* execState, const void* buffer, JSCell* self) {
    const void* data = buffer; //*reinterpret_cast<void* const*>(buffer);

    if (!data) {
        return jsNull();
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    ReferenceTypeInstance* referenceType = jsCast<ReferenceTypeInstance*>(self);

    PointerInstance* pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState->vm(), const_cast<void*>(data)));
    return ReferenceInstance::create(execState->vm(), globalObject, globalObject->interop()->referenceInstanceStructure(), referenceType->innerType(), pointer);
}

void ConstantArrayTypeInstance::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    ReferenceTypeInstance* referenceType = jsCast<ReferenceTypeInstance*>(self);

    if (value.isUndefinedOrNull()) {
        // *reinterpret_cast<void**>(buffer) = nullptr;
        buffer = nullptr;
        return;
    }

    if (ReferenceInstance* reference = jsDynamicCast<ReferenceInstance*>(value)) {
        if (!reference->data()) {
            GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
            reference->createBackingStorage(execState->vm(), globalObject, execState, referenceType->innerType());
        }
    }

    bool hasHandle;
    void* handle = tryHandleofValue(value, &hasHandle);
    if (!hasHandle) {
        JSC::VM& vm = execState->vm();
        auto scope = DECLARE_THROW_SCOPE(vm);

        JSValue exception = createError(execState, WTF::ASCIILiteral("Value is not a reference."));
        scope.throwException(execState, exception);
        return;
    }

    //*reinterpret_cast<void**>(buffer) = handle;
    buffer = handle;
}

void ConstantArrayTypeInstance::finishCreation(JSC::VM& vm, JSCell* innerType) {
    Base::finishCreation(vm, innerType);
    ffi_type* innerFFIType = const_cast<ffi_type*>(getFFITypeMethodTable(innerType).ffiType);
    ffi_type* type = new ffi_type({ .size = this->_size * innerFFIType->size, .alignment = innerFFIType->alignment, .type = FFI_TYPE_STRUCT });
    type->elements = new ffi_type*[this->_size + 1];
    for (size_t i = 0; i < this->_size; i++) {
        type->elements[i] = innerFFIType;
    }
    type->elements[this->_size] = nullptr;
    this->_constArrayType = type;
    this->_ffiTypeMethodTable.ffiType = type;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.write = &write;

    this->_innerType.set(vm, this, innerType);
}
} // namespace NativeScript
