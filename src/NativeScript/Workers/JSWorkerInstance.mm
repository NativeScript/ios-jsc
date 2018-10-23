//
//  JSWorkerInstance.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 7/5/16.
//
//

#include "JSWorkerInstance.h"
#include "JSErrors.h"
#include "WorkerMessagingProxy.h"
#include <JavaScriptCore/JSONObject.h>

namespace NativeScript {
using namespace JSC;

const ClassInfo JSWorkerInstance::s_info = { "Worker", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(JSWorkerInstance) };

void JSWorkerInstance::postMessage(ExecState* exec, JSValue message, JSArray* transferList) {
    UNUSED_PARAM(transferList);
    auto scope = DECLARE_THROW_SCOPE(exec->vm());
    String strMessage = JSONStringify(exec, message, 0);
    if (scope.exception())
        return;
    _workerMessagingProxy->parentPostMessageToWorkerThread(strMessage);
}

void JSWorkerInstance::onmessage(JSC::ExecState* exec, JSC::JSValue message) {
    JSValue onMessageCallback = this->get(exec, _onmessageIdentifier);

    CallData callData;
    CallType callType = JSC::getCallData(exec->vm(), onMessageCallback, callData);
    if (callType == JSC::CallType::None) {
        return;
    }

    JSGlobalObject* globalObject = exec->lexicalGlobalObject();
    Structure* emptyObjectStructure = exec->vm().structureCache.emptyObjectStructureForPrototype(globalObject, globalObject->objectPrototype(), JSFinalObject::defaultInlineCapacity());
    JSFinalObject* onMessageEvent = JSFinalObject::create(exec, emptyObjectStructure);
    onMessageEvent->putDirect(exec->vm(), Identifier::fromString(&exec->vm(), "data"), message);

    MarkedArgumentBuffer onMessageArguments;
    onMessageArguments.append(onMessageEvent);

    call(exec, onMessageCallback, callType, callData, jsUndefined(), onMessageArguments);
}

void JSWorkerInstance::onerror(ExecState* execState, JSObject* error) {
    JSValue onErrorCallback = this->get(execState, _onerrorIdentifier);

    CallData callData;
    CallType callType = JSC::getCallData(execState->vm(), onErrorCallback, callData);
    if (callType == JSC::CallType::None) {
        return;
    }

    MarkedArgumentBuffer onErrorArguments;
    onErrorArguments.append(error);

    call(execState, onErrorCallback, callType, callData, jsUndefined(), onErrorArguments);
}

void JSWorkerInstance::terminate() {
    _workerMessagingProxy->parentTerminateWorkerThread();
}

void JSWorkerInstance::finishCreation(JSC::VM& vm, const WTF::String& applicationPath, const WTF::String& entryModuleId, const WTF::String referrer) {
    Base::finishCreation(vm);

    _onmessageIdentifier = Identifier::fromString(&vm, "onmessage");
    _onerrorIdentifier = Identifier::fromString(&vm, "onerror");

    _applicationPath = applicationPath;
    _entryModuleId = entryModuleId;
    _referrer = referrer;
    _workerMessagingProxy = std::make_shared<WorkerMessagingProxy>(this);
    _workerMessagingProxy->parentStartWorkerThread(applicationPath, entryModuleId, referrer);
}
}
