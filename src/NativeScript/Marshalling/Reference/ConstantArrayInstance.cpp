//
//  ConstantArrayInstance.cpp
//  NativeScript
//
//  Created by Deyan Ginev on 16.01.18.
//
//

#include "ConstantArrayInstance.h"
#include "Interop.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ConstantArrayInstance::s_info = { "ConstantArray", &Base::s_info, 0, CREATE_METHOD_TABLE(ConstantArrayInstance) };

void ConstantArrayInstance::finishCreation(VM& vm, JSValue value) {
    Base::finishCreation(vm);

    this->putDirect(vm, vm.propertyNames->value, value, None);
}

void ConstantArrayInstance::finishCreation(VM& vm, JSGlobalObject* globalObject, JSCell* innerType, PointerInstance* pointer) {
    Base::finishCreation(vm);

    this->setType(vm, innerType);
    this->_pointer.set(vm, this, pointer);
}

void ConstantArrayInstance::createBackingStorage(VM& vm, GlobalObject* globalObject, ExecState* execState, JSCell* innerType) {
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

void ConstantArrayInstance::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    ConstantArrayInstance* referenceInstance = jsCast<ConstantArrayInstance*>(cell);
    visitor.append(&referenceInstance->_innerTypeCell);
    visitor.append(&referenceInstance->_pointer);
}

void ConstantArrayInstance::setType(VM& vm, JSCell* innerType) {
    this->_innerTypeCell.set(vm, this, innerType);
    this->_ffiTypeMethodTable = getFFITypeMethodTable(innerType);
}

bool ConstantArrayInstance::getOwnPropertySlotByIndex(JSObject* object, ExecState* execState, unsigned propertyName, PropertySlot& propertySlot) {
    ConstantArrayInstance* reference = jsCast<ConstantArrayInstance*>(object);
    if (!reference->innerType()) {
        if (propertyName == 0) {
            propertySlot.setValue(object, None, reference->get(execState, execState->vm().propertyNames->value));
            return true;
        }
        return false;
    }

    const void* element = static_cast<void*>(reinterpret_cast<char*>(reference->data()) + propertyName * reference->_ffiTypeMethodTable.ffiType->size);
    JSValue value = reference->_ffiTypeMethodTable.read(execState, element, reference->_innerTypeCell.get());
    propertySlot.setValue(object, None, value);
    return true;
}

bool ConstantArrayInstance::putByIndex(JSCell* cell, ExecState* execState, unsigned propertyName, JSValue value, bool shouldThrow) {
    ConstantArrayInstance* reference = jsCast<ConstantArrayInstance*>(cell);

    void* element = static_cast<void*>(reinterpret_cast<char*>(reference->data()) + propertyName * reference->_ffiTypeMethodTable.ffiType->size);
    reference->_ffiTypeMethodTable.write(execState, value, element, reference->_innerTypeCell.get());

    return true;
}
}; // namespace NativeScript
