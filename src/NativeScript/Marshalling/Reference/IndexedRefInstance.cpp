//
//  IndexedRefInstance.cpp
//  NativeScript
//
//  Created by Deyan Ginev on 16.01.18.
//
//

#include "IndexedRefInstance.h"
#include "Interop.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo IndexedRefInstance::s_info = { "IndexedRef", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(IndexedRefInstance) };

void IndexedRefInstance::finishCreation(VM& vm, JSValue value) {
    Base::finishCreation(vm);

    this->putDirect(vm, vm.propertyNames->value, value, static_cast<unsigned>(PropertyAttribute::None));
}

void IndexedRefInstance::finishCreation(VM& vm, JSGlobalObject* globalObject, JSCell* innerType, PointerInstance* pointer) {
    Base::finishCreation(vm);

    this->setType(vm, innerType);
    this->_pointer.set(vm, this, pointer);
}

void IndexedRefInstance::createBackingStorage(VM& vm, GlobalObject* globalObject, ExecState* execState, JSCell* innerType) {
    this->setType(vm, innerType);

    void* data = calloc(this->_ffiTypeMethodTable.ffiType->size, 1);
    this->_pointer.set(vm, this, jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(vm, data)));
    this->_pointer->setAdopted(true);

    PropertySlot propertySlot(this, PropertySlot::InternalMethodType::GetOwnProperty);
    if (this->methodTable()->getOwnPropertySlot(this, execState, execState->vm().propertyNames->value, propertySlot)) {
        this->_ffiTypeMethodTable.write(execState, propertySlot.getValue(execState, execState->vm().propertyNames->value), this->data(), this->_innerTypeCell.get());

        Base::deleteProperty(this, execState, vm.propertyNames->value);
    }
}

void IndexedRefInstance::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    IndexedRefInstance* referenceInstance = jsCast<IndexedRefInstance*>(cell);
    visitor.append(referenceInstance->_innerTypeCell);
    visitor.append(referenceInstance->_pointer);
}

void IndexedRefInstance::setType(VM& vm, JSCell* innerType) {
    this->_innerTypeCell.set(vm, this, innerType);
    this->_ffiTypeMethodTable = getFFITypeMethodTable(vm, innerType);
}

bool IndexedRefInstance::getOwnPropertySlotByIndex(JSObject* object, ExecState* execState, unsigned propertyName, PropertySlot& propertySlot) {
    IndexedRefInstance* reference = jsCast<IndexedRefInstance*>(object);
    if (!reference->innerType()) {
        if (propertyName == 0) {
            propertySlot.setValue(object, static_cast<unsigned>(PropertyAttribute::None), reference->get(execState, execState->vm().propertyNames->value));
            return true;
        }
        return false;
    }

    const void* element = static_cast<void*>(reinterpret_cast<char*>(reference->data()) + propertyName * reference->_ffiTypeMethodTable.ffiType->size);
    JSValue value = reference->_ffiTypeMethodTable.read(execState, element, reference->_innerTypeCell.get());
    propertySlot.setValue(object, static_cast<unsigned>(PropertyAttribute::None), value);
    return true;
}

bool IndexedRefInstance::putByIndex(JSCell* cell, ExecState* execState, unsigned propertyName, JSValue value, bool shouldThrow) {
    IndexedRefInstance* reference = jsCast<IndexedRefInstance*>(cell);

    void* element = static_cast<void*>(reinterpret_cast<char*>(reference->data()) + propertyName * reference->_ffiTypeMethodTable.ffiType->size);
    reference->_ffiTypeMethodTable.write(execState, value, element, reference->_innerTypeCell.get());

    return true;
}
}; // namespace NativeScript
