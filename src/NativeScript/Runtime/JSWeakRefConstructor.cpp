//
//  JSWeakRefConstructor.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 02.10.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "JSWeakRefConstructor.h"
#include "JSWeakRefInstance.h"
#include "JSWeakRefPrototype.h"

namespace NativeScript {
using namespace JSC;

static EncodedJSValue JSC_HOST_CALL construct(ExecState* execState) {
    JSValue argument = execState->argument(0);
    if (!argument.isObject()) {
        return JSValue::encode(execState->vm().throwException(execState, createTypeError(execState, WTF::ASCIILiteral("Argument must be an object."))));
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    JSWeakRefInstance* weakRef = JSWeakRefInstance::create(execState->vm(), globalObject->weakRefInstanceStructure(), argument.toObject(execState));
    return JSValue::encode(weakRef);
}

const ClassInfo JSWeakRefConstructor::s_info = { "WeakRef", &Base::s_info, 0, CREATE_METHOD_TABLE(JSWeakRefConstructor) };

JSWeakRefConstructor::JSWeakRefConstructor(VM& vm, Structure* structure)
    : Base(vm, structure) {
}

void JSWeakRefConstructor::finishCreation(VM& vm, JSWeakRefPrototype* prototype) {
    Base::finishCreation(vm, WTF::ASCIILiteral("WeakRef"));

    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, prototype, DontEnum | DontDelete | ReadOnly);
    this->putDirectWithoutTransition(vm, vm.propertyNames->length, jsNumber(1), ReadOnly | DontEnum | DontDelete);
}

ConstructType JSWeakRefConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = construct;
    return ConstructTypeHost;
}

CallType JSWeakRefConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = construct;
    return CallTypeHost;
}
}