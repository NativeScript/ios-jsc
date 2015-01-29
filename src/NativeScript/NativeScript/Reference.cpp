//
//  Reference.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 8/6/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "Reference.h"
#include <cassert>
#include "Interop.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ReferencePrototype::s_info = { "Reference", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(ReferencePrototype) };

static EncodedJSValue JSC_HOST_CALL referenceProtoFuncGetValue(ExecState* execState) {
    ReferenceInstance* reference = jsCast<ReferenceInstance*>(execState->thisValue());
    if (!reference->data()) {
        return JSValue::encode(jsUndefined());
    }

    JSValue result = reference->ffiType()->read(execState, reference->data());
    return JSValue::encode(result);
}

static EncodedJSValue JSC_HOST_CALL referenceProtoFuncSetValue(ExecState* execState) {
    ReferenceInstance* reference = jsCast<ReferenceInstance*>(execState->thisValue());
    reference->ffiType()->write(execState, execState->argument(0), reference->data());
    return JSValue::encode(jsUndefined());
}

static EncodedJSValue JSC_HOST_CALL referenceProtoFuncToString(ExecState* execState) {
    ReferenceInstance* reference = jsCast<ReferenceInstance*>(execState->thisValue());
    WTF::String toString = WTF::String::format("<%s: %p>", ReferenceInstance::info()->className, reference->data());
    return JSValue::encode(jsString(execState, toString));
}

void ReferencePrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->toString, 0, referenceProtoFuncToString, NoIntrinsic, DontEnum | Attribute::Function);

    PropertyDescriptor descriptor;
    descriptor.setEnumerable(true);

    descriptor.setGetter(JSFunction::create(vm, globalObject, 0, WTF::emptyString(), &referenceProtoFuncGetValue));
    descriptor.setSetter(JSFunction::create(vm, globalObject, 1, WTF::emptyString(), &referenceProtoFuncSetValue));

    Base::defineOwnProperty(this, globalObject->globalExec(), vm.propertyNames->value, descriptor, false);
}

const ClassInfo ReferenceConstructor::s_info = { "Reference", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(ReferenceConstructor) };

void ReferenceConstructor::finishCreation(VM& vm, JSValue referencePrototype) {
    Base::finishCreation(vm, this->classInfo()->className);
    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, referencePrototype, DontEnum | DontDelete | ReadOnly);
    this->putDirectWithoutTransition(vm, vm.propertyNames->length, jsNumber(1), ReadOnly | DontEnum | DontDelete);
}

static EncodedJSValue JSC_HOST_CALL constructReference(ExecState* execState) {
    ReferenceInstance* result = jsCast<GlobalObject*>(execState->lexicalGlobalObject())->interop()->createReference(execState->vm(), execState->argument(0));
    return JSValue::encode(result);
}

ConstructType ReferenceConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = &constructReference;
    return ConstructTypeHost;
}

CallType ReferenceConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &constructReference;
    return CallTypeHost;
}

const ClassInfo ReferenceInstance::s_info = { "Reference", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(ReferenceInstance) };

const unsigned ReferenceInstance::StructureFlags = OverridesGetOwnPropertySlot | Base::StructureFlags;

ReferenceInstance::ReferenceInstance(VM& vm, Structure* structure)
    : Base(vm, structure) {
}

void ReferenceInstance::finishCreation(VM& vm, JSValue value) {
    Base::finishCreation(vm);

    this->putDirect(vm, vm.propertyNames->value, value, None);
}

void ReferenceInstance::finishCreation(JSC::VM& vm, GlobalObject* globalObject, const FFIType* ffiType, void* data) {
    Base::finishCreation(vm);
    this->_ffiType = ffiType;
    this->setData(vm, globalObject, data);
}

// TODO: Get type from constructor?
void ReferenceInstance::updateTypeAndData(VM& vm, GlobalObject* globalObject, ExecState* execState, const FFIType* ffiType) {
    this->_ffiType = ffiType;

    void* data = calloc(this->_ffiType->type->size, 1);
    this->setData(vm, globalObject, data);
    this->_pointer->setAdopted(true);

    PropertySlot propertySlot(this);
    if (this->methodTable()->getOwnPropertySlot(this, execState, execState->vm().propertyNames->value, propertySlot)) {
        this->_ffiType->write(execState, propertySlot.getValue(execState, execState->vm().propertyNames->value), this->data());

        Base::deleteProperty(this, execState, vm.propertyNames->value);
    }
}

void ReferenceInstance::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    ReferenceInstance* referenceInstance = jsCast<ReferenceInstance*>(cell);
    visitor.append(&referenceInstance->_pointer);
}

void ReferenceInstance::setData(JSC::VM& vm, GlobalObject* globalObject, void* data) {
    assert(data);

    PointerInstance* pointer = jsDynamicCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(vm, data));
    this->_pointer.set(vm, this, pointer);
}
};
