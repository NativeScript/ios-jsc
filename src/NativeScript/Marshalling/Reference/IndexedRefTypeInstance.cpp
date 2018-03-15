//
//  IndexedRefTypeInstance.cpp
//  NativeScript
//
//  Created by Deyan Ginev on 8.01.18.
//

#include "IndexedRefTypeInstance.h"
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

const ClassInfo IndexedRefTypeInstance::s_info = { "IndexedRefTypeInstance", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(IndexedRefTypeInstance) };

JSValue IndexedRefTypeInstance::read(ExecState* execState, const void* buffer, JSCell* self) {
    const void* data = buffer; //*reinterpret_cast<void* const*>(buffer);

    if (!data) {
        return jsNull();
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    IndexedRefTypeInstance* referenceType = jsCast<IndexedRefTypeInstance*>(self);

    PointerInstance* pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState->vm(), const_cast<void*>(data)));
    return IndexedRefInstance::create(execState->vm(), globalObject, globalObject->interop()->indexedRefInstanceStructure(), referenceType->innerType(), pointer);
}

void IndexedRefTypeInstance::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    IndexedRefTypeInstance* referenceType = jsCast<IndexedRefTypeInstance*>(self);

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

const char* IndexedRefTypeInstance::encode(VM& vm, JSCell* cell) {
    IndexedRefTypeInstance* self = jsCast<IndexedRefTypeInstance*>(cell);

    if (!self->_compilerEncoding.empty()) {
        return self->_compilerEncoding.c_str();
    }

    self->_compilerEncoding = "[" + std::to_string(self->_size) + "^";
    const FFITypeMethodTable& table = getFFITypeMethodTable(vm, self->_innerType.get());
    self->_compilerEncoding += table.encode(vm, self->_innerType.get());
    self->_compilerEncoding += "]";
    return self->_compilerEncoding.c_str();
}

void IndexedRefTypeInstance::finishCreation(JSC::VM& vm, JSCell* innerType) {
    Base::finishCreation(vm);
    ffi_type* innerFFIType = const_cast<ffi_type*>(getFFITypeMethodTable(vm, innerType).ffiType);

    ffi_type* type = new ffi_type({ .size = this->_size * innerFFIType->size, .alignment = innerFFIType->alignment, .type = FFI_TYPE_STRUCT });

    type->elements = new ffi_type*[this->_size + 1];

    for (size_t i = 0; i < this->_size; i++) {
        type->elements[i] = innerFFIType;
    }

    type->elements[this->_size] = nullptr;
    this->_indexedRefType = type;
    this->_ffiTypeMethodTable.ffiType = type;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.write = &write;

    this->_innerType.set(vm, this, innerType);
}

void IndexedRefTypeInstance::visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    IndexedRefTypeInstance* object = jsCast<IndexedRefTypeInstance*>(cell);
    visitor.append(object->_innerType);
}

} // namespace NativeScript
