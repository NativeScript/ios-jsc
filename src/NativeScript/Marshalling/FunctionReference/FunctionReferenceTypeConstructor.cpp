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

const ClassInfo FunctionReferenceTypeConstructor::s_info = { "FunctionReferenceType", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(FunctionReferenceTypeConstructor) };

void FunctionReferenceTypeConstructor::finishCreation(VM& vm, JSObject* functionReferenceTypePrototype) {
    Base::finishCreation(vm, this->classInfo()->className);

    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, functionReferenceTypePrototype, DontEnum | DontDelete | ReadOnly);
}

static EncodedJSValue JSC_HOST_CALL constructFunctionReferenceTypeInstance(ExecState* execState) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    if (execState->argumentCount() < 1) {
        return throwVMError(execState, scope, createError(execState, WTF::ASCIILiteral("FunctionReferenceType constructor expects at least one argument.")));
    }

    JSValue returnType = execState->uncheckedArgument(0);

    const FFITypeMethodTable* methodTable;
    if (!tryGetFFITypeMethodTable(vm, returnType, &methodTable)) {
        return throwVMError(execState, scope, createError(execState, WTF::ASCIILiteral("Not a valid type object is passed as return type of function reference.")));
    }

    WTF::Vector<JSCell*> parametersTypes;
    for (size_t i = 1; i < execState->argumentCount(); i++) {
        JSValue currentParameter = execState->uncheckedArgument(i);
        if (!tryGetFFITypeMethodTable(vm, currentParameter, &methodTable)) {
            return throwVMError(execState, scope, createError(execState, WTF::ASCIILiteral("Not a valid type object is passed as parameter of function reference.")));
        }
        parametersTypes.append(currentParameter.asCell());
    }

    return JSValue::encode(globalObject->typeFactory()->getFunctionReferenceTypeInstance(globalObject, returnType.asCell(), parametersTypes));
}

ConstructType FunctionReferenceTypeConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = &constructFunctionReferenceTypeInstance;
    return ConstructType::Host;
}

CallType FunctionReferenceTypeConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &constructFunctionReferenceTypeInstance;
    return CallType::Host;
}
} // namespace NativeScript
