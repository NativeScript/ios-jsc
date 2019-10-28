//
//  PointerPrototype.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/17/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "PointerPrototype.h"
#include "Interop.h"
#include "PointerInstance.h"
#include "WTF/HexNumber.h"

namespace NativeScript {
using namespace JSC;
using namespace WTF;

const ClassInfo PointerPrototype::s_info = { "Pointer", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(PointerPrototype) };

static EncodedJSValue JSC_HOST_CALL pointerProtoFuncAdd(ExecState* execState) {
    void* value = jsCast<PointerInstance*>(execState->thisValue())->data();
    ptrdiff_t offset = execState->argument(0).toUInt32(execState);
    void* newValue = reinterpret_cast<void*>(reinterpret_cast<char*>(value) + offset);

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    JSValue result = globalObject->interop()->pointerInstanceForPointer(execState, newValue);
    return JSValue::encode(result);
}

static EncodedJSValue JSC_HOST_CALL pointerProtoFuncSubtract(ExecState* execState) {
    void* value = jsCast<PointerInstance*>(execState->thisValue())->data();
    ptrdiff_t offset = execState->argument(0).toUInt32(execState);
    void* newValue = reinterpret_cast<void*>(reinterpret_cast<char*>(value) - offset);

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    JSValue result = globalObject->interop()->pointerInstanceForPointer(execState, newValue);
    return JSValue::encode(result);
}

static EncodedJSValue JSC_HOST_CALL pointerProtoFuncToString(ExecState* execState) {
    PointerInstance* pointer = jsCast<PointerInstance*>(execState->thisValue());
    auto value = reinterpret_cast<intptr_t>(pointer->data());
    JSValue result = jsString(execState, makeString("<", PointerInstance::info()->className, ": 0x", hex(value, HexConversionMode::Uppercase), ">"));
    return JSValue::encode(result);
}

static EncodedJSValue JSC_HOST_CALL pointerProtoFuncToHexString(ExecState* execState) {
    PointerInstance* pointer = jsCast<PointerInstance*>(execState->thisValue());
    auto value = reinterpret_cast<intptr_t>(pointer->data());
    JSValue result = jsString(execState, makeString("0x", hex(value, HexConversionMode::Uppercase)));
    return JSValue::encode(result);
}

static EncodedJSValue JSC_HOST_CALL pointerProtoFuncToDecimalString(ExecState* execState) {
    PointerInstance* pointer = jsCast<PointerInstance*>(execState->thisValue());
    const void* value = pointer->data();
    JSValue result = jsString(execState, makeString(static_cast<intptr_t>(reinterpret_cast<size_t>(value))));
    return JSValue::encode(result);
}

static EncodedJSValue JSC_HOST_CALL pointerProtoFuncToNumber(ExecState* execState) {
    PointerInstance* pointer = jsCast<PointerInstance*>(execState->thisValue());
    const void* value = pointer->data();
    JSValue result = jsNumber(reinterpret_cast<size_t>(value));
    return JSValue::encode(result);
}

void PointerPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->add, 1, pointerProtoFuncAdd, NoIntrinsic, PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(globalObject->globalExec(), "subtract"), 1, pointerProtoFuncSubtract, NoIntrinsic, PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->toString, 0, pointerProtoFuncToString, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum));
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(globalObject->globalExec(), "toNumber"), 0, pointerProtoFuncToNumber, NoIntrinsic, PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(globalObject->globalExec(), "toHexString"), 0, pointerProtoFuncToHexString, NoIntrinsic, PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(globalObject->globalExec(), "toDecimalString"), 0, pointerProtoFuncToDecimalString, NoIntrinsic, PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
}
} // namespace NativeScript
