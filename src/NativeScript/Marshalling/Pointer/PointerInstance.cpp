//
//  PointerInstance.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 8/19/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "PointerInstance.h"
#include "FFIType.h"

namespace NativeScript {
using namespace JSC;

EncodedJSValue JSC_HOST_CALL readFromPointer(ExecState* execState) {
    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    if (execState->argumentCount() < 1) {
        return throwVMError(execState, scope, createError(execState, WTF::ASCIILiteral("At least one argument is expected.")));
    }

    JSValue arg = execState->uncheckedArgument(0);
    if (!arg.isCell()) {
        return throwVMError(execState, scope, createError(execState, WTF::ASCIILiteral("Invalid first argument. Pointer expected.")));
    }

    PointerInstance* pointer = jsCast<PointerInstance*>(arg.asCell());
    JSCell* typeObject = execState->callee();

    const FFITypeMethodTable* methodTable;
    if (tryGetFFITypeMethodTable(JSValue(typeObject), &methodTable)) {
        JSValue value = methodTable->read(execState, pointer->data(), typeObject);
        return JSValue::encode(value);
    }

    RELEASE_ASSERT_NOT_REACHED();
}

const ClassInfo PointerInstance::s_info = { "Pointer", &Base::s_info, 0, CREATE_METHOD_TABLE(PointerInstance) };

void PointerInstance::finishCreation(VM& vm, void* value) {
    Base::finishCreation(vm);
    this->preventExtensions(this, vm.topCallFrame);
    this->_data = value;
}

PointerInstance::~PointerInstance() {
    if (this->_isAdopted) {
        free(this->_data);
        this->_data = nullptr;
    }
}
};
