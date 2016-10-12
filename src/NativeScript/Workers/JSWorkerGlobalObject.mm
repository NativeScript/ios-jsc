#include "JSWorkerGlobalObject.h"
#include "WorkerMessagingProxy.h"
#include "JSErrors.h"

#include <JavaScriptCore/runtime/JSJob.h>
#include <JavaScriptCore/runtime/JSONObject.h>

using namespace JSC;

namespace NativeScript {

static EncodedJSValue JSC_HOST_CALL jsWorkerGlobalObjectClose(ExecState* execState) {
    JSWorkerGlobalObject* globalObject = jsCast<JSWorkerGlobalObject*>(execState->lexicalGlobalObject());
    globalObject->close();
    return JSValue::encode(jsUndefined());
}

static EncodedJSValue JSC_HOST_CALL jsWorkerGlobalObjectPostMessage(ExecState* exec) {
    JSWorkerGlobalObject* globalObject = jsCast<JSWorkerGlobalObject*>(exec->lexicalGlobalObject());

    if (exec->argumentCount() < 1)
        return throwVMError(exec, createError(exec, WTF::ASCIILiteral("postMessage function expects at least one argument.")));

    JSValue message = exec->argument(0);
    JSArray* transferList = nullptr;

    if (exec->argumentCount() >= 2 && !exec->argument(1).isUndefinedOrNull()) {
        JSValue arg2 = exec->argument(1);
        if (!arg2.isCell() || !(transferList = jsDynamicCast<JSArray*>(arg2.asCell()))) {
            return throwVMError(exec, createError(exec, WTF::ASCIILiteral("The second parameter of postMessage must be array, null or undefined.")));
        }
    }

    globalObject->postMessage(exec, message, transferList);
    return JSValue::encode(jsUndefined());
}

const ClassInfo JSWorkerGlobalObject::s_info = { "NativeScriptWorkerGlobal", &Base::s_info, 0, CREATE_METHOD_TABLE(JSWorkerGlobalObject) };

void JSWorkerGlobalObject::finishCreation(VM& vm, WTF::String applicationPath) {
    Base::finishCreation(applicationPath, vm);

    _onmessageIdentifier = Identifier::fromString(&vm, "onmessage");

    this->putDirect(vm, Identifier::fromString(&vm, "self"), this->globalExec()->globalThisValue(), DontEnum | ReadOnly | DontDelete);
    this->putDirectNativeFunction(vm, this, vm.propertyNames->close, 0, jsWorkerGlobalObjectClose, NoIntrinsic, DontEnum | DontDelete | ReadOnly);
    this->putDirectNativeFunction(vm, this, vm.propertyNames->postMessage, 2, jsWorkerGlobalObjectPostMessage, NoIntrinsic, DontEnum | DontDelete | ReadOnly);
}

void JSWorkerGlobalObject::postMessage(JSC::ExecState* exec, JSC::JSValue message, JSC::JSArray* transferList) {
    UNUSED_PARAM(transferList);
    String strMessage = JSONStringify(exec, message, 0);
    if (exec->hadException())
        return;
    _workerMessagingProxy->workerPostMessageToParent(strMessage);
}

void JSWorkerGlobalObject::onmessage(ExecState* exec, JSValue message) {
    JSValue onMessageCallback = this->get(exec, _onmessageIdentifier);

    CallData callData;
    CallType callType = JSC::getCallData(onMessageCallback, callData);
    if (callType == CallTypeNone) {
        return;
    }

    Structure* emptyObjectStructure = exec->vm().prototypeMap.emptyObjectStructureForPrototype(exec->lexicalGlobalObject()->objectPrototype(), JSFinalObject::defaultInlineCapacity());
    JSFinalObject* onMessageEvent = JSFinalObject::create(exec, emptyObjectStructure);
    onMessageEvent->putDirect(exec->vm(), Identifier::fromString(&exec->vm(), "data"), message);

    MarkedArgumentBuffer onMessageArguments;
    onMessageArguments.append(onMessageEvent);

    call(exec, onMessageCallback, callType, callData, jsUndefined(), onMessageArguments);
}

void JSWorkerGlobalObject::close() {
    _workerMessagingProxy->workerClose();
}

WorkerMessagingProxy* JSWorkerGlobalObject::workerMessagingProxy() {
    return _workerMessagingProxy.get();
}

void JSWorkerGlobalObject::uncaughtErrorReported(const WTF::String& message, const WTF::String& filename, int lineNumber, int colNumber) {
    this->workerMessagingProxy()->workerPostException(message, filename, lineNumber, colNumber);
}
}
