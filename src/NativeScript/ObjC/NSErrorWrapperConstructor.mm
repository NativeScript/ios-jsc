//
//  NSErrorWrapperConstructor.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 30.12.15 г..
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "NSErrorWrapperConstructor.h"
#include "ObjCTypes.h"
#include <JavaScriptCore/ErrorPrototype.h>

namespace NativeScript {
using namespace JSC;

const ClassInfo NSErrorWrapperConstructor::s_info = { "NSErrorWrapper", &Base::s_info, 0, CREATE_METHOD_TABLE(NSErrorWrapperConstructor) };

void NSErrorWrapperConstructor::destroy(JSCell* cell) {
    jsCast<NSErrorWrapperConstructor*>(cell)->~NSErrorWrapperConstructor();
}

void NSErrorWrapperConstructor::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm, WTF::ASCIILiteral("NSError"));

    ErrorPrototype* prototype = ErrorPrototype::create(vm, globalObject, ErrorPrototype::createStructure(vm, globalObject, globalObject->errorPrototype()));
    prototype->putDirect(vm, vm.propertyNames->constructor, this);
    this->putDirect(vm, vm.propertyNames->prototype, prototype);
    prototype->putDirect(vm, vm.propertyNames->name, jsString(&vm, WTF::ASCIILiteral("NSErrorWrapper")));

    this->_errorStructure.set(vm, this, ErrorInstance::createStructure(vm, globalObject, prototype));
}

void NSErrorWrapperConstructor::visitChildren(JSCell* cell, SlotVisitor& slotVisitor) {
    Base::visitChildren(cell, slotVisitor);

    NSErrorWrapperConstructor* self = jsCast<NSErrorWrapperConstructor*>(cell);
    slotVisitor.append(&self->_errorStructure);
}

ErrorInstance* NSErrorWrapperConstructor::createError(ExecState* execState, NSError* error) const {
    ErrorInstance* wrappedError = ErrorInstance::create(execState, this->errorStructure(), jsString(execState, error.localizedDescription));
    wrappedError->putDirect(execState->vm(), Identifier::fromString(execState, "error"), NativeScript::toValue(execState, error));

    return wrappedError;
}

static EncodedJSValue JSC_HOST_CALL constructErrorWrapper(ExecState* execState) {
    NSErrorWrapperConstructor* self = jsCast<NSErrorWrapperConstructor*>(execState->callee());
    NSError* error = NativeScript::toObject(execState, execState->argument(0));

    if (!error || ![error isKindOfClass:[NSError class]]) {
        return throwVMTypeError(execState);
    }

    return JSValue::encode(self->createError(execState, error));
}

ConstructType NSErrorWrapperConstructor::getConstructData(JSCell*, ConstructData& constructData) {
    constructData.native.function = &constructErrorWrapper;
    return ConstructTypeHost;
}

CallType NSErrorWrapperConstructor::getCallData(JSCell*, CallData& callData) {
    callData.native.function = &constructErrorWrapper;
    return CallTypeHost;
}
}