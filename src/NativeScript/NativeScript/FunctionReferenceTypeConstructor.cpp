//
//  FunctionReferenceTypeConstructor.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 11/3/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "FunctionReferenceTypeConstructor.h"
#include "FunctionReferenceTypeInstance.h"
#include "TypeFactory.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo FunctionReferenceTypeConstructor::s_info = { "FunctionReferenceType", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(FunctionReferenceTypeConstructor) };

void FunctionReferenceTypeConstructor::finishCreation(VM& vm, JSObject* functionReferenceTypePrototype) {
    Base::finishCreation(vm, this->classInfo()->className);

    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, functionReferenceTypePrototype, DontEnum | DontDelete | ReadOnly);
}

static EncodedJSValue JSC_HOST_CALL constructFunctionReferenceTypeInstance(ExecState* execState) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    if (execState->argumentCount() < 1) {
        return throwVMError(execState, createError(execState, WTF::ASCIILiteral("FunctionReferenceType constructor expects at least one argument.")));
    }

    JSValue returnType = execState->uncheckedArgument(0);

    const FFITypeMethodTable* methodTable;
    if (!tryGetFFITypeMethodTable(returnType, &methodTable)) {
        return throwVMError(execState, createError(execState, WTF::ASCIILiteral("Not a valid type object is passed as return type of function reference.")));
    }

    WTF::Vector<JSCell*> parametersTypes;
    for (size_t i = 1; i < execState->argumentCount(); i++) {
        JSValue currentParameter = execState->uncheckedArgument(i);
        if (!tryGetFFITypeMethodTable(currentParameter, &methodTable)) {
            return throwVMError(execState, createError(execState, WTF::ASCIILiteral("Not a valid type object is passed as parameter of function reference.")));
        }
        parametersTypes.append(currentParameter.asCell());
    }

    return JSValue::encode(globalObject->typeFactory()->getFunctionReferenceTypeInstance(globalObject, returnType.asCell(), parametersTypes));
}

ConstructType FunctionReferenceTypeConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = &constructFunctionReferenceTypeInstance;
    return ConstructTypeHost;
}

CallType FunctionReferenceTypeConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &constructFunctionReferenceTypeInstance;
    return CallTypeHost;
}
}
