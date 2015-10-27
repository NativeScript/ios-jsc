#include "UnmanagedType.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo UnmanagedType::s_info = { "Unmanaged", &Base::s_info, 0, CREATE_METHOD_TABLE(UnmanagedType) };

void UnmanagedType::finishCreation(VM& vm, JSCell* returnType) {
    Base::finishCreation(vm);

    this->_returnType.set(vm, this, returnType);

    this->_ffiTypeMethodTable.ffiType = &ffi_type_pointer;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.write = &write;
    this->_ffiTypeMethodTable.canConvert = &canConvert;
    this->_ffiTypeMethodTable.encode = &encode;
}

JSValue UnmanagedType::read(ExecState* execState, const void* buffer, JSCell* self) {
    const void* data = *reinterpret_cast<void* const*>(buffer);

    if (!data) {
        return jsNull();
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    UnmanagedType* unmanagedType = jsCast<UnmanagedType*>(self);

    return UnmanagedInstance::create(execState->vm(), globalObject->unmanagedInstanceStructure(), unmanagedType->_returnType.get(), const_cast<void*>(data));
}

void UnmanagedType::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    UnmanagedType* unmanagedType = jsCast<UnmanagedType*>(cell);
    visitor.append(&unmanagedType->_returnType);
}

void UnmanagedType::write(ExecState* execState, const JSValue&, void*, JSCell* self) {
    throwVMTypeError(execState, WTF::ASCIILiteral("Unmanaged type could not be consumed from native. Try calling takeRetained/takeUnretained before."));
}

bool UnmanagedType::canConvert(ExecState*, const JSValue&, JSCell* self) {
    return false;
}

const char* UnmanagedType::encode(JSCell* cell) {
    UnmanagedType* self = jsCast<UnmanagedType*>(cell);
    const FFITypeMethodTable* methodTable;
    if (NativeScript::tryGetFFITypeMethodTable(self->_returnType.get(), &methodTable)) {
        return methodTable->encode(self->_returnType.get());
    }

    RELEASE_ASSERT_NOT_REACHED();
}
}