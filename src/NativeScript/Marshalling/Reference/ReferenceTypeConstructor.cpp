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

const ClassInfo ReferenceTypeConstructor::s_info = { "ReferenceType", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ReferenceTypeConstructor) };

void ReferenceTypeConstructor::finishCreation(VM& vm, JSObject* referenceTypePrototype) {
    Base::finishCreation(vm, this->classInfo()->className);

    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, referenceTypePrototype, DontEnum | DontDelete | ReadOnly);
}

static EncodedJSValue JSC_HOST_CALL constructReferenceType(ExecState* execState) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    if (execState->argumentCount() != 1) {
        return throwVMError(execState, scope, createError(execState, WTF::ASCIILiteral("ReferenceType constructor expects one argument.")));
    }

    JSValue type = execState->uncheckedArgument(0);
    const FFITypeMethodTable* methodTable;
    if (!tryGetFFITypeMethodTable(vm, type, &methodTable)) {
        return throwVMError(execState, scope, createError(execState, WTF::ASCIILiteral("Not a valid type object is passed as parameter.")));
    }

    return JSValue::encode(globalObject->typeFactory()->getReferenceType(globalObject, type.asCell()));
}

ConstructType ReferenceTypeConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = &constructReferenceType;
    return ConstructType::Host;
}

CallType ReferenceTypeConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &constructReferenceType;
    return CallType::Host;
}
} // namespace NativeScript
