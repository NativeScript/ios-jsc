#include "UnmanagedInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo UnmanagedInstance::s_info = { "Unmanaged", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(UnmanagedInstance) };

void UnmanagedInstance::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    UnmanagedInstance* instance = jsCast<UnmanagedInstance*>(cell);
    visitor.append(instance->_returnType);
}

void UnmanagedInstance::finishCreation(VM& vm, JSCell* returnType, void* value) {
    Base::finishCreation(vm);

    this->_returnType.set(vm, this, returnType);
    this->_data = value;
}
} // namespace NativeScript
