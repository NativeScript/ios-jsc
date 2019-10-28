//
//  ReferencePrototype.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/17/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ReferencePrototype.h"
#include "ReferenceInstance.h"
#include "WTF/HexNumber.h"

namespace NativeScript {
using namespace JSC;
using namespace WTF;

const ClassInfo ReferencePrototype::s_info = { "Reference", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ReferencePrototype) };

static EncodedJSValue JSC_HOST_CALL referenceProtoFuncGetValue(ExecState* execState) {
    ReferenceInstance* reference = jsCast<ReferenceInstance*>(execState->thisValue());
    if (!reference->data()) {
        return JSValue::encode(jsUndefined());
    }

    JSValue result = reference->ffiTypeMethodTable().read(execState, reference->data(), reference->innerType());
    return JSValue::encode(result);
}

static EncodedJSValue JSC_HOST_CALL referenceProtoFuncSetValue(ExecState* execState) {
    ReferenceInstance* reference = jsCast<ReferenceInstance*>(execState->thisValue());
    reference->ffiTypeMethodTable().write(execState, execState->argument(0), reference->data(), reference->innerType());
    return JSValue::encode(jsUndefined());
}

static EncodedJSValue JSC_HOST_CALL referenceProtoFuncToString(ExecState* execState) {
    ReferenceInstance* reference = jsCast<ReferenceInstance*>(execState->thisValue());
    WTF::String toString = makeString("<", ReferenceInstance::info()->className, ": 0x", hex(reinterpret_cast<intptr_t>(reference->data()), HexConversionMode::Uppercase), ">");
    return JSValue::encode(jsString(execState, toString));
}

void ReferencePrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->toString, 0, referenceProtoFuncToString, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum));

    PropertyDescriptor descriptor;
    descriptor.setEnumerable(true);

    descriptor.setGetter(JSFunction::create(vm, globalObject, 0, WTF::emptyString(), &referenceProtoFuncGetValue));
    descriptor.setSetter(JSFunction::create(vm, globalObject, 1, WTF::emptyString(), &referenceProtoFuncSetValue));

    Base::defineOwnProperty(this, globalObject->globalExec(), vm.propertyNames->value, descriptor, false);
}
} // namespace NativeScript
