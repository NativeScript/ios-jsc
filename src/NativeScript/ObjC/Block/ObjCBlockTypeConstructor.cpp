//
//  ObjCBlockTypeConstructor.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 11/3/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCBlockTypeConstructor.h"
#include "ObjCBlockType.h"
#include "TypeFactory.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCBlockTypeConstructor::s_info = { "BlockType", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCBlockTypeConstructor) };

void ObjCBlockTypeConstructor::finishCreation(VM& vm, JSObject* objCBlockTypePrototype) {
    Base::finishCreation(vm, this->classInfo()->className);

    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, objCBlockTypePrototype, PropertyAttribute::DontEnum | PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
}

EncodedJSValue JSC_HOST_CALL ObjCBlockTypeConstructor::constructObjCBlockTypeConstructor(ExecState* execState) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    if (execState->argumentCount() < 1) {
        return throwVMError(execState, scope, createError(execState, "ObjCBlockTypeConstructor constructor expects at least one argument."_s));
    }

    JSValue returnType = execState->uncheckedArgument(0);

    const FFITypeMethodTable* methodTable;
    if (!tryGetFFITypeMethodTable(vm, returnType, &methodTable)) {
        return throwVMError(execState, scope, createError(execState, "Not a valid type object is passed as return type of block type."_s));
    }

    WTF::Vector<JSCell*> parametersTypes;
    for (size_t i = 1; i < execState->argumentCount(); i++) {
        JSValue currentParameter = execState->uncheckedArgument(i);
        if (!tryGetFFITypeMethodTable(vm, currentParameter, &methodTable)) {
            return throwVMError(execState, scope, createError(execState, "Not a valid type object is passed as parameter of block type."_s));
        }
        parametersTypes.append(currentParameter.asCell());
    }

    return JSValue::encode(globalObject->typeFactory()->getObjCBlockType(globalObject, returnType.asCell(), parametersTypes));
}

} // namespace NativeScript
