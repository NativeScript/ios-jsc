//
//  JSWorkerPrototype.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 7/5/16.
//
//

#include <JavaScriptCore/runtime/Lookup.h>
#include "JSWorkerPrototype.h"
#include "JSWorkerInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo JSWorkerPrototype::s_info = { "WorkerPrototype", &Base::s_info, 0, CREATE_METHOD_TABLE(JSWorkerPrototype) };

// TODO: Since JSWorkerInstance is no longer an EventTarget it should somehow dispatch event and call attached eventListeners when a message arrives
EncodedJSValue jsWorkerOnmessage(ExecState* state, JSObject* slotBase, EncodedJSValue thisValue, PropertyName) {
    // TODO: Provide implemention
    return JSValue::encode(jsNull());
}

void setJSWorkerOnmessage(ExecState* state, JSObject* baseObject, EncodedJSValue thisValue, EncodedJSValue encodedValue) {
    // TODO: Provide implemention
}

EncodedJSValue jsWorkerOnerror(ExecState* state, JSObject* slotBase, EncodedJSValue thisValue, PropertyName) {
    // TODO: Provide implemention
    return JSValue::encode(jsNull());
}

void setJSWorkerOnerror(ExecState* state, JSObject* baseObject, EncodedJSValue thisValue, EncodedJSValue encodedValue) {
    // TODO: Provide implemention
}

EncodedJSValue JSC_HOST_CALL jsWorkerPrototypeFunctionPostMessage(ExecState* state) {
    /* TODO: Provide implementation. It should validate/prepare all arguments and call castedThis->postMessage()
    JSValue thisValue = state->thisValue();
    JSWorkerInstance* castedThis = jsDynamicCast<JSWorkerInstance*>(thisValue);
    if (UNLIKELY(!castedThis))
        return throwVMError(state, createTypeError(state, makeString("Can only call Worker.postMessage, on instances of Worker")));
    return JSValue::encode(castedThis->postMessage(*state));
     */
    return JSValue::encode(jsNull());
}

EncodedJSValue JSC_HOST_CALL jsWorkerPrototypeFunctionTerminate(ExecState* state) {
    JSValue thisValue = state->thisValue();
    JSWorkerInstance* castedThis = jsDynamicCast<JSWorkerInstance*>(thisValue);
    if (UNLIKELY(!castedThis))
        return throwVMError(state, createTypeError(state, makeString("Can only call Worker.terminate, on instances of Worker")));
    castedThis->terminate();
    return JSValue::encode(jsUndefined());
}

static const HashTableValue JSWorkerPrototypeTableValues[] = {
    { "onmessage", CustomAccessor, NoIntrinsic, { (intptr_t) static_cast<PropertySlot::GetValueFunc>(jsWorkerOnmessage), (intptr_t) static_cast<PutPropertySlot::PutValueFunc>(setJSWorkerOnmessage) } },
    { "onerror", CustomAccessor, NoIntrinsic, { (intptr_t) static_cast<PropertySlot::GetValueFunc>(jsWorkerOnerror), (intptr_t) static_cast<PutPropertySlot::PutValueFunc>(setJSWorkerOnerror) } },
    { "postMessage", JSC::Function, NoIntrinsic, { (intptr_t) static_cast<NativeFunction>(jsWorkerPrototypeFunctionPostMessage), (intptr_t)(1) } },
    { "terminate", JSC::Function, NoIntrinsic, { (intptr_t) static_cast<NativeFunction>(jsWorkerPrototypeFunctionTerminate), (intptr_t)(0) } },
};

void JSWorkerPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);
    reifyStaticProperties(vm, JSWorkerPrototypeTableValues, *this);
}
}