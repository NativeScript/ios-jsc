//
//  FunctionReferenceConstructor.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/20/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "FunctionReferenceConstructor.h"
#include "FunctionReferenceInstance.h"
#include "Interop.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo FunctionReferenceConstructor::s_info = { "FunctionReference", &Base::s_info, 0, CREATE_METHOD_TABLE(FunctionReferenceConstructor) };

void FunctionReferenceConstructor::finishCreation(VM& vm, JSValue prototype) {
    Base::finishCreation(vm, this->classInfo()->className);
    this->putDirect(vm, vm.propertyNames->prototype, prototype, DontEnum | DontDelete | ReadOnly);
    this->putDirect(vm, vm.propertyNames->length, jsNumber(1), ReadOnly | DontEnum | DontDelete);
}

static EncodedJSValue JSC_HOST_CALL constructFunctionReferenceInstance(ExecState* execState) {
    CallData callData;
    if (!(execState->argumentCount() == 1 && getCallData(execState->uncheckedArgument(0), callData) != CallTypeNone)) {
        return JSValue::encode(execState->vm().throwException(execState, createError(execState, WTF::ASCIILiteral("Function required."))));
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    JSCell* func = execState->uncheckedArgument(0).asCell();
    FunctionReferenceInstance* functionReference = FunctionReferenceInstance::create(execState->vm(), globalObject, globalObject->interop()->functionReferenceInstanceStructure(), func);
    return JSValue::encode(functionReference);
}

ConstructType FunctionReferenceConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = &constructFunctionReferenceInstance;
    return ConstructTypeHost;
}

CallType FunctionReferenceConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &constructFunctionReferenceInstance;
    return CallTypeHost;
}
}