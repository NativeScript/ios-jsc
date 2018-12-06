//
//  JSWorkerPrototype.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 7/5/16.
//
//

#include "JSWorkerPrototype.h"
#include "JSWorkerInstance.h"
#include <JavaScriptCore/runtime/Lookup.h>

namespace NativeScript {
using namespace JSC;

const ClassInfo JSWorkerPrototype::s_info = { "WorkerPrototype", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(JSWorkerPrototype) };

static EncodedJSValue JSC_HOST_CALL jsWorkerProtoFuncPostMessage(ExecState* exec) {
    JSValue thisValue = exec->thisValue();
    JSWorkerInstance* workerInstance = jsDynamicCast<JSWorkerInstance*>(exec->vm(), thisValue);
    auto scope = DECLARE_THROW_SCOPE(exec->vm());
    if (UNLIKELY(!workerInstance))
        return throwVMError(exec, scope, createTypeError(exec, makeString("Can only call Worker.postMessage, on instances of Worker")));

    if (exec->argumentCount() < 1)
        return throwVMError(exec, scope, createError(exec, "postMessage function expects at least one argument."_s));

    JSValue message = exec->argument(0);
    JSArray* transferList = nullptr;

    if (exec->argumentCount() >= 2 && !exec->argument(1).isUndefinedOrNull()) {
        JSValue arg2 = exec->argument(1);
        if (!arg2.isCell() || !(transferList = jsDynamicCast<JSArray*>(exec->vm(), arg2.asCell()))) {
            return throwVMError(exec, scope, createError(exec, "The second parameter of postMessage must be array, null or undefined."_s));
        }
    }

    workerInstance->postMessage(exec, message, transferList);
    return JSValue::encode(jsUndefined());
}

static EncodedJSValue JSC_HOST_CALL jsWorkerProtoFuncTerminate(ExecState* state) {
    JSValue thisValue = state->thisValue();
    JSWorkerInstance* castedThis = jsDynamicCast<JSWorkerInstance*>(state->vm(), thisValue);
    auto scope = DECLARE_THROW_SCOPE(state->vm());
    if (UNLIKELY(!castedThis))
        return throwVMError(state, scope, createTypeError(state, makeString("Can only call Worker.terminate, on instances of Worker")));
    castedThis->terminate();
    return JSValue::encode(jsUndefined());
}

void JSWorkerPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, "postMessage"_s), 2, jsWorkerProtoFuncPostMessage, NoIntrinsic, PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, "terminate"_s), 0, jsWorkerProtoFuncTerminate, NoIntrinsic, PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
}
} // namespace NativeScript
