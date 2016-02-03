//
//  NativeErrorWrapperConstructor.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 30.12.15 г..
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "NativeErrorWrapperConstructor.h"
#include "ObjCTypes.h"
#include <JavaScriptCore/ErrorPrototype.h>

namespace NativeScript {
using namespace JSC;

const ClassInfo NativeErrorWrapperConstructor::s_info = { "NativeException", &Base::s_info, 0, CREATE_METHOD_TABLE(NativeErrorWrapperConstructor) };

void NativeErrorWrapperConstructor::destroy(JSCell* cell) {
    jsCast<NativeErrorWrapperConstructor*>(cell)->~NativeErrorWrapperConstructor();
}

void NativeErrorWrapperConstructor::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm, WTF::ASCIILiteral("NativeException"));

    ErrorPrototype* prototype = ErrorPrototype::create(vm, globalObject, ErrorPrototype::createStructure(vm, globalObject, globalObject->errorPrototype()));
    prototype->putDirect(vm, vm.propertyNames->constructor, this);
    this->putDirect(vm, vm.propertyNames->prototype, prototype);
    prototype->putDirect(vm, vm.propertyNames->name, jsString(&vm, WTF::ASCIILiteral("NativeException")));

    this->_errorStructure.set(vm, this, ErrorInstance::createStructure(vm, globalObject, prototype));
}

void NativeErrorWrapperConstructor::visitChildren(JSCell* cell, SlotVisitor& slotVisitor) {
    Base::visitChildren(cell, slotVisitor);

    NativeErrorWrapperConstructor* self = jsCast<NativeErrorWrapperConstructor*>(cell);
    slotVisitor.append(&self->_errorStructure);
}

ErrorInstance* NativeErrorWrapperConstructor::createError(ExecState* execState, NSError* error) const {
    ErrorInstance* wrappedError = ErrorInstance::create(execState, this->errorStructure(), jsString(execState, error.localizedDescription));
    wrappedError->putDirect(execState->vm(), Identifier::fromString(execState, "nativeException"), NativeScript::toValue(execState, error));
    return wrappedError;
}

ErrorInstance* NativeErrorWrapperConstructor::createError(ExecState* execState, NSException* exception) const {
    ErrorInstance* wrappedError = ErrorInstance::create(execState, this->errorStructure(), jsString(execState, exception.reason));
    wrappedError->putDirect(execState->vm(), Identifier::fromString(execState, "nativeException"), NativeScript::toValue(execState, exception));
    return wrappedError;
}

static EncodedJSValue JSC_HOST_CALL constructErrorWrapper(ExecState* execState) {
    NativeErrorWrapperConstructor* self = jsCast<NativeErrorWrapperConstructor*>(execState->callee());
    NSError* error = NativeScript::toObject(execState, execState->argument(0));

    if (!error || ![error isKindOfClass:[NSError class]]) {
        return throwVMTypeError(execState);
    }

    return JSValue::encode(self->createError(execState, error));
}

ConstructType NativeErrorWrapperConstructor::getConstructData(JSCell*, ConstructData& constructData) {
    constructData.native.function = &constructErrorWrapper;
    return ConstructTypeHost;
}

CallType NativeErrorWrapperConstructor::getCallData(JSCell*, CallData& callData) {
    callData.native.function = &constructErrorWrapper;
    return CallTypeHost;
}
}