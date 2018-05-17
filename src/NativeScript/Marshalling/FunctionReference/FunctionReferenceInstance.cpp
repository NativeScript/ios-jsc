//
//  FunctionReferenceInstance.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/19/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "FunctionReferenceInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo FunctionReferenceInstance::s_info = { "FunctionReference", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(FunctionReferenceInstance) };

void FunctionReferenceInstance::finishCreation(VM& vm, JSGlobalObject* globalObject, JSCell* function) {
    JSFunction* object = jsCast<JSFunction*>(function);

    ExecState* execState = globalObject->globalExec();
    Base::finishCreation(vm, object->jsExecutable()->ecmaName().string());

    size_t length = object->get(execState, vm.propertyNames->length).toUInt32(execState);
    this->putDirect(vm, vm.propertyNames->length, jsNumber(length), PropertyAttribute::ReadOnly | PropertyAttribute::DontEnum | PropertyAttribute::DontDelete);

    this->_function = WriteBarrier<JSCell>(vm, this, function);
}

EncodedJSValue JSC_HOST_CALL FunctionReferenceInstance::callFunc(ExecState* execState) {
    FunctionReferenceInstance* functionReference = jsCast<FunctionReferenceInstance*>(execState->callee().asCell());

    CallData callData;
    CallType callType = JSC::getCallData(functionReference->function(), callData);
    return JSValue::encode(call(execState, functionReference->function(), callType, callData, execState->globalThisValue(), execState));
}

void FunctionReferenceInstance::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    FunctionReferenceInstance* object = jsCast<FunctionReferenceInstance*>(cell);
    visitor.append(object->_functionCallback);
    visitor.append(object->_function);
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
} // namespace NativeScript
