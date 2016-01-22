//
//  FunctionReferenceInstance.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/19/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "NativeScript-Prefix.h"
#include "FunctionReferenceInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo FunctionReferenceInstance::s_info = { "FunctionReference", &Base::s_info, 0, CREATE_METHOD_TABLE(FunctionReferenceInstance) };

void FunctionReferenceInstance::finishCreation(VM& vm, JSGlobalObject* globalObject, JSCell* function) {
    JSObject* object = jsCast<JSObject*>(function);

    ExecState* execState = globalObject->globalExec();
    Base::finishCreation(vm, object->get(execState, vm.propertyNames->name).toString(execState)->value(execState));

    size_t length = object->get(execState, vm.propertyNames->length).toUInt32(execState);
    this->putDirect(vm, vm.propertyNames->length, jsNumber(length), ReadOnly | DontEnum | DontDelete);

    this->_function = WriteBarrier<JSCell>(vm, this, function);
}

static EncodedJSValue JSC_HOST_CALL callFunc(ExecState* execState) {
    FunctionReferenceInstance* functionReference = jsCast<FunctionReferenceInstance*>(execState->callee());

    CallData callData;
    CallType callType = getCallData(functionReference->function(), callData);
    return JSValue::encode(call(execState, functionReference->function(), callType, callData, execState->globalThisValue(), execState));
}

CallType FunctionReferenceInstance::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &callFunc;
    return CallTypeHost;
}

void FunctionReferenceInstance::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    FunctionReferenceInstance* object = jsCast<FunctionReferenceInstance*>(cell);
    visitor.append(&object->_functionCallback);
    visitor.append(&object->_function);
}

void FunctionReferenceInstance::setCallback(VM& vm, FFIFunctionCallback* functionCallback) {
    ASSERT(!this->_functionCallback);

    gcProtect(functionCallback);
    this->_functionCallback.set(vm, this, functionCallback);
}

FunctionReferenceInstance::~FunctionReferenceInstance() {
    FFIFunctionCallback* functionCallback = this->_functionCallback.get();
    gcUnprotectNullTolerant(functionCallback);
}
}
