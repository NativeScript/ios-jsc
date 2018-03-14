//
//  ExtVectorTypeInstance.cpp
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 30/01/2018.
//

#include "ExtVectorTypeInstance.h"
#include "FFISimpleType.h"
#include "IndexedRefInstance.h"
#include "Interop.h"
#include "PointerInstance.h"
#include "RecordConstructor.h"
#include "ReferenceInstance.h"
#include "ReferenceTypeInstance.h"
#include "ffi.h"

namespace NativeScript {
using namespace JSC;
typedef ReferenceTypeInstance Base;

const ClassInfo ExtVectorTypeInstance::s_info = { "ExtVectorTypeInstance", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ExtVectorTypeInstance) };

JSValue ExtVectorTypeInstance::read(ExecState* execState, const void* buffer, JSCell* self) {
    const void* data = buffer;

    if (!data) {
        return jsNull();
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    ExtVectorTypeInstance* referenceType = jsCast<ExtVectorTypeInstance*>(self);

    PointerInstance* pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState->vm(), const_cast<void*>(data)));
    return IndexedRefInstance::create(execState->vm(), globalObject, globalObject->interop()->extVectorInstanceStructure(), referenceType->innerType(), pointer);
}

void ExtVectorTypeInstance::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    ExtVectorTypeInstance* referenceType = jsCast<ExtVectorTypeInstance*>(self);

    if (value.isUndefinedOrNull()) {
        memset(buffer, 0, referenceType->ffiTypeMethodTable().ffiType->size);
        return;
    }

    if (IndexedRefInstance* reference = jsDynamicCast<IndexedRefInstance*>(execState->vm(), value)) {
        if (!reference->data()) {
            GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
            reference->createBackingStorage(execState->vm(), globalObject, execState, referenceType->innerType());
        }
    }

    bool hasHandle;
    JSC::VM& vm = execState->vm();
    void* handle = tryHandleofValue(vm, value, &hasHandle);
    if (!hasHandle) {
        JSC::VM& vm = execState->vm();
        auto scope = DECLARE_THROW_SCOPE(vm);

        JSValue exception = createError(execState, WTF::ASCIILiteral("Value is not a reference."));
        scope.throwException(execState, exception);
        return;
    }

    memcpy(buffer, handle, referenceType->ffiTypeMethodTable().ffiType->size);
}

const char* ExtVectorTypeInstance::encode(VM& vm, JSCell* cell) {
    ExtVectorTypeInstance* self = jsCast<ExtVectorTypeInstance*>(cell);

    if (!self->_compilerEncoding.empty()) {
        return self->_compilerEncoding.c_str();
    }

    self->_compilerEncoding = "[" + std::to_string(self->_size) + "^";
    const FFITypeMethodTable& table = getFFITypeMethodTable(vm, self->_innerType.get());
    self->_compilerEncoding += table.encode(vm, self->_innerType.get());
    self->_compilerEncoding += "]";
    return self->_compilerEncoding.c_str();
}

void ExtVectorTypeInstance::finishCreation(JSC::VM& vm, JSCell* innerType) {
    Base::finishCreation(vm);
    ffi_type* innerFFIType = const_cast<ffi_type*>(getFFITypeMethodTable(vm, innerType).ffiType);

    size_t arraySize = this->_size;

    if (this->_size % 2) {
        arraySize = this->_size + 1;
    }

    ffi_type* type = new ffi_type({ .size = arraySize * innerFFIType->size, .alignment = innerFFIType->alignment, .type = FFI_TYPE_EXT_VECTOR });

    ffi_type* ffiTypeEl = new ffi_type({ .size = 4,
                                         .alignment = 4,
                                         .type = FFI_TYPE_FLOAT });

    type->elements = new ffi_type*[arraySize + 1];

    for (size_t i = 0; i < arraySize; i++) {
        type->elements[i] = ffiTypeEl;
    }

    type->elements[arraySize] = nullptr;
    this->_extVectorType = type;
    this->_ffiTypeMethodTable.ffiType = type;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.write = &write;

    this->_innerType.set(vm, this, innerType);
}

void ExtVectorTypeInstance::visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    ExtVectorTypeInstance* object = jsCast<ExtVectorTypeInstance*>(cell);
    visitor.append(object->_innerType);
}

} // namespace NativeScript
