//
//  JSWorkerConstructor.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 7/5/16.
//
//

#include "JSWorkerConstructor.h"
#include <JavaScriptCore/CodeBlock.h>
#include "JSWorkerInstance.h"
#include "JSWorkerPrototype.h"

namespace NativeScript {
using namespace JSC;

static EncodedJSValue JSC_HOST_CALL constructJSWorker(ExecState* exec) {
    auto scope = DECLARE_THROW_SCOPE(exec->vm());
    if (exec->argumentCount() < 1)
        return throwVMError(exec, scope, createNotEnoughArgumentsError(exec));

    if (exec->argumentCount() > 1)
        return throwVMError(exec, scope, createError(exec, "Too much arguments passed."));

    if (!exec->argument(0).isString())
        return throwVMError(exec, scope, createError(exec, "The first argument must be string."));

    String entryModule = exec->argument(0).toString(exec)->value(exec);
    if (scope.exception())
        return JSValue::encode(JSValue());

    GlobalObject* globalObject = jsCast<GlobalObject*>(exec->lexicalGlobalObject());
    WTF::String applicationPath = globalObject->applicationPath();

    CallFrame* frame = exec;
    while (frame->codeBlock() == nullptr) {
        frame = frame->callerFrame();
    }
    const WTF::String& currentSourceUrl = frame->codeBlock()->ownerScriptExecutable()->sourceURL();
    ASSERT(currentSourceUrl.startsWith("file:///"));
    const WTF::String relativeFilePath = currentSourceUrl.substring(7);
    WTF::String referrer = applicationPath;
    referrer.append(relativeFilePath);

    JSWorkerInstance* worker = JSWorkerInstance::create(exec->vm(), globalObject->workerInstanceStructure(), applicationPath, entryModule, referrer);
    return JSValue::encode(worker);
}

static EncodedJSValue JSC_HOST_CALL callJSWorker(ExecState* exec) {
    auto scope = DECLARE_THROW_SCOPE(exec->vm());
    return throwVMError(exec, scope, createError(exec, "Worker function must be called as a constructor."));
}

const ClassInfo JSWorkerConstructor::s_info = { "WorkerConstructor", &Base::s_info, 0, CREATE_METHOD_TABLE(JSWorkerConstructor) };

void JSWorkerConstructor::finishCreation(VM& vm, JSWorkerPrototype* prototype) {
    Base::finishCreation(vm, WTF::ASCIILiteral("Worker"));

    this->putDirect(vm, vm.propertyNames->prototype, prototype, DontEnum | DontDelete | ReadOnly);
    this->putDirect(vm, vm.propertyNames->length, jsNumber(1), ReadOnly | DontEnum);
}

ConstructType JSWorkerConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = constructJSWorker;
    return ConstructType::Host;
}

CallType JSWorkerConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = callJSWorker;
    return CallType::Host;
}
}
