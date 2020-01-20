//
//  Reference.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 8/6/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ReferenceInstance.h"
#include "Interop.h"
#include "JSErrors.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ReferenceInstance::s_info = { "Reference", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ReferenceInstance) };

void ReferenceInstance::finishCreation(VM& vm, JSValue value) {
    Base::finishCreation(vm);

    this->putDirect(vm, vm.propertyNames->value, value, static_cast<unsigned>(PropertyAttribute::None));
}

void ReferenceInstance::finishCreation(VM& vm, JSGlobalObject* globalObject, JSCell* innerType, PointerInstance* pointer) {
    Base::finishCreation(vm);

    this->setType(vm, innerType);
    this->_pointer.set(vm, this, pointer);
}

void ReferenceInstance::createBackingStorage(VM& vm, GlobalObject* globalObject, ExecState* execState, JSCell* innerType) {
    this->setType(vm, innerType);

    void* data = calloc(this->_ffiTypeMethodTable.ffiType->size, 1);
    this->_pointer.set(vm, this, jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState, data)));
    this->_pointer->setAdopted(true);

    PropertySlot propertySlot(this, PropertySlot::InternalMethodType::GetOwnProperty);
    if (this->methodTable(vm)->getOwnPropertySlot(this, execState, execState->vm().propertyNames->value, propertySlot)) {
        this->_ffiTypeMethodTable.write(execState, propertySlot.getValue(execState, execState->vm().propertyNames->value), this->data(), this->_innerTypeCell.get());

        Base::deleteProperty(this, execState, vm.propertyNames->value);
    }
}

void ReferenceInstance::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    ReferenceInstance* referenceInstance = jsCast<ReferenceInstance*>(cell);
    visitor.append(referenceInstance->_innerTypeCell);
    visitor.append(referenceInstance->_pointer);

    for (auto it : referenceInstance->assignedValues) {
        visitor.append(it.second);
    }
}

void ReferenceInstance::setType(VM& vm, JSCell* innerType) {
    this->_innerTypeCell.set(vm, this, innerType);
    this->_ffiTypeMethodTable = getFFITypeMethodTable(vm, innerType);
}

bool ReferenceInstance::getOwnPropertySlotByIndex(JSObject* object, ExecState* execState, unsigned propertyName, PropertySlot& propertySlot) {
    NS_TRY {
        ReferenceInstance* reference = jsCast<ReferenceInstance*>(object);
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
    NS_CATCH_THROW_TO_JS(execState)

    return false;
}

bool ReferenceInstance::putByIndex(JSCell* cell, ExecState* execState, unsigned propertyName, JSValue value, bool shouldThrow) {
    NS_TRY {
        ReferenceInstance* reference = jsCast<ReferenceInstance*>(cell);

        void* element = static_cast<void*>(reinterpret_cast<char*>(reference->data()) + propertyName * reference->_ffiTypeMethodTable.ffiType->size);
        reference->_ffiTypeMethodTable.write(execState, value, element, reference->_innerTypeCell.get());

        if (value.isCell()) {
            reference->assignedValues[propertyName].set(execState->vm(), reference, value.asCell());
        }

        return true;
    }
    NS_CATCH_THROW_TO_JS(execState)

    return false;
}
}; // namespace NativeScript
