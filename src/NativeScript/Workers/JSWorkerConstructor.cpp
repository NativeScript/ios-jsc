//
//  JSWorkerConstructor.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 7/5/16.
//
//

#include "JSWorkerConstructor.h"
#include "JSWorkerInstance.h"
#include "JSWorkerPrototype.h"

namespace NativeScript {
using namespace JSC;

static EncodedJSValue JSC_HOST_CALL constructJSWorker(ExecState* exec) {
    if (!exec->argumentCount())
        return throwVMError(exec, createNotEnoughArgumentsError(exec));

    String scriptURL = exec->argument(0).toString(exec)->value(exec);
    if (exec->hadException())
        return JSValue::encode(JSValue());

    GlobalObject* globalObject = jsCast<GlobalObject*>(exec->lexicalGlobalObject());
    JSWorkerInstance* worker = JSWorkerInstance::create(exec->vm(), globalObject->workerInstanceStructure(), scriptURL);
    return JSValue::encode(worker);
}

const ClassInfo JSWorkerConstructor::s_info = { "WorkerConstructor", &Base::s_info, 0, CREATE_METHOD_TABLE(JSWorkerConstructor) };

JSWorkerConstructor::JSWorkerConstructor(VM& vm, Structure* structure)
    : Base(vm, structure) {
}

void JSWorkerConstructor::finishCreation(VM& vm, JSWorkerPrototype* prototype) {
    Base::finishCreation(vm, WTF::ASCIILiteral("Worker"));

    this->putDirect(vm, vm.propertyNames->prototype, prototype, DontEnum | DontDelete | ReadOnly);
    this->putDirect(vm, vm.propertyNames->length, jsNumber(1), ReadOnly | DontEnum);
}

ConstructType JSWorkerConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = constructJSWorker;
    return ConstructTypeHost;
}

CallType JSWorkerConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = constructJSWorker;
    return CallTypeHost;
}
}