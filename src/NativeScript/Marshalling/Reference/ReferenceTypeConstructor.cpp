//
//  ReferenceTypeConstructor.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 11/3/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ReferenceTypeConstructor.h"
#include "Interop.h"
#include "PointerInstance.h"
#include "ReferenceTypeInstance.h"
#include "TypeFactory.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ReferenceTypeConstructor::s_info = { "ReferenceType", &Base::s_info, 0, CREATE_METHOD_TABLE(ReferenceTypeConstructor) };

void ReferenceTypeConstructor::finishCreation(VM& vm, JSObject* referenceTypePrototype) {
    Base::finishCreation(vm, this->classInfo()->className);

    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, referenceTypePrototype, DontEnum | DontDelete | ReadOnly);
}

static EncodedJSValue JSC_HOST_CALL constructReferenceType(ExecState* execState) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    if (execState->argumentCount() != 1) {
        return throwVMError(execState, createError(execState, WTF::ASCIILiteral("ReferenceType constructor expects one argument.")));
    }

    JSValue type = execState->uncheckedArgument(0);
    const FFITypeMethodTable* methodTable;
    if (!tryGetFFITypeMethodTable(type, &methodTable)) {
        return throwVMError(execState, createError(execState, WTF::ASCIILiteral("Not a valid type object is passed as parameter.")));
    }

    return JSValue::encode(globalObject->typeFactory()->getReferenceType(globalObject, type.asCell()));
}

ConstructType ReferenceTypeConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = &constructReferenceType;
    return ConstructTypeHost;
}

CallType ReferenceTypeConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &constructReferenceType;
    return CallTypeHost;
}
}