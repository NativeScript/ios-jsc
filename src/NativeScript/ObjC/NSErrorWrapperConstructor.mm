//
//  NSErrorWrapperConstructor.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 30.12.15 г..
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "NSErrorWrapperConstructor.h"
#include "JSErrors.h"
#include "ObjCTypes.h"
#include <JavaScriptCore/ErrorPrototype.h>

namespace NativeScript {
using namespace JSC;

const ClassInfo NSErrorWrapperConstructor::s_info = { "NSErrorWrapper", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(NSErrorWrapperConstructor) };

void NSErrorWrapperConstructor::destroy(JSCell* cell) {
    static_cast<NSErrorWrapperConstructor*>(cell)->~NSErrorWrapperConstructor();
}

void NSErrorWrapperConstructor::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm, "NSError"_s);

    ErrorPrototype* prototype = ErrorPrototype::create(vm, globalObject, ErrorPrototype::createStructure(vm, globalObject, globalObject->errorPrototype()));
    prototype->putDirect(vm, vm.propertyNames->constructor, this);
    this->putDirect(vm, vm.propertyNames->prototype, prototype);
    prototype->putDirect(vm, vm.propertyNames->name, jsString(&vm, "NSErrorWrapper"_s));

    this->_errorStructure.set(vm, this, ErrorInstance::createStructure(vm, globalObject, prototype));
}

void NSErrorWrapperConstructor::visitChildren(JSCell* cell, SlotVisitor& slotVisitor) {
    Base::visitChildren(cell, slotVisitor);

    NSErrorWrapperConstructor* self = jsCast<NSErrorWrapperConstructor*>(cell);
    slotVisitor.append(self->_errorStructure);
}

ErrorInstance* NSErrorWrapperConstructor::createError(ExecState* execState, NSError* error) const {
    ErrorInstance* wrappedError = ErrorInstance::create(execState, this->errorStructure(), jsString(execState, error.localizedDescription));
    wrappedError->putDirect(execState->vm(), Identifier::fromString(execState, "error"), NativeScript::toValue(execState, error));

    return wrappedError;
}

EncodedJSValue JSC_HOST_CALL NSErrorWrapperConstructor::constructErrorWrapper(ExecState* execState) {
    NS_TRY {
        NSErrorWrapperConstructor* self = jsCast<NSErrorWrapperConstructor*>(execState->callee().asCell());
        NSError* error = NativeScript::toObject(execState, execState->argument(0));

        if (!error || ![error isKindOfClass:[NSError class]]) {
            JSC::VM& vm = execState->vm();
            auto scope = DECLARE_THROW_SCOPE(vm);

            return throwVMTypeError(execState, scope);
        }

        return JSValue::encode(self->createError(execState, error));
    }
    NS_CATCH_THROW_TO_JS(execState)

    return JSValue::encode(jsUndefined());
}
}
