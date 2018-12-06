#include "DomainBackendDispatcher.h"
#include "GlobalObjectInspectorController.h"
#include "SuppressAllPauses.h"
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/InspectorAgentBase.h>
#include <JavaScriptCore/inspector/InspectorBackendDispatchers.h>
#include <JavaScriptCore/inspector/InspectorFrontendDispatchers.h>
#include <JavaScriptCore/runtime/Exception.h>
#include <JavaScriptCore/runtime/JSONObject.h>
#include <stdio.h>

namespace NativeScript {
using namespace JSC;

Ref<DomainBackendDispatcher> DomainBackendDispatcher::create(WTF::String domain, JSCell* constructorFunction, Inspector::JSAgentContext& context) {
    return adoptRef(*new DomainBackendDispatcher(domain, constructorFunction, context));
}

DomainBackendDispatcher::DomainBackendDispatcher(WTF::String domain, JSCell* constructorFunction, Inspector::JSAgentContext& context)
    : SupplementalBackendDispatcher(context.backendDispatcher)
    , m_globalObject(context.inspectedGlobalObject) {
    ConstructData constructData;
    ConstructType constructType = JSC::getConstructData(m_globalObject.vm(), constructorFunction, constructData);
    MarkedArgumentBuffer constructArgs;

    JSObject* domainDispatcher = construct(m_globalObject.globalExec(), constructorFunction, constructType, constructData, constructArgs);
    m_domainDispatcher = Strong<JSObject>(m_globalObject.vm(), domainDispatcher);

    const HashMap<String, SupplementalBackendDispatcher*>& dispatchers = m_backendDispatcher->dispatchers();
    auto result = dispatchers.find(domain);
    if (result != dispatchers.end()) {
        m_duplicatedDispatcher = result->value;
    }
    m_backendDispatcher->registerDispatcherForDomain(domain, this);
}

void DomainBackendDispatcher::dispatch(long callId, const String& method, Ref<JSON::Object>&& message) {
    ExecState* globalExec = m_globalObject.globalExec();
    MarkedArgumentBuffer dispatchArguments;

    RefPtr<JSON::Object> paramsContainer;
    message->getObject("params"_s, paramsContainer);
    if (paramsContainer) {
        dispatchArguments.append(JSONParse(globalExec, paramsContainer->toJSONString()));
    }

    JSValue functionValue = m_domainDispatcher->get(globalExec, Identifier::fromString(&m_globalObject.vm(), method));
    if (functionValue.isUndefined()) {
        if (m_duplicatedDispatcher) {
            m_duplicatedDispatcher.get()->dispatch(callId, method, WTFMove(message));

            return;
        }

        m_backendDispatcher->reportProtocolError(Inspector::BackendDispatcher::InvalidRequest, WTF::String::format("No implementation for method %s found", method.utf8().data()));
        return;
    }

    CallData dispatchCallData;
    CallType dispatchCallType = getCallData(globalExec->vm(), functionValue, dispatchCallData);
    WTF::NakedPtr<Exception> exception;
    JSValue dispatchResult;

    {
        SuppressAllPauses suppressAllPauses(m_globalObject);
        dispatchResult = call(globalExec, functionValue, dispatchCallType, dispatchCallData, m_domainDispatcher.get(), dispatchArguments, exception);
    }

    RefPtr<JSON::Object> messageObject = JSON::Object::create();
    Inspector::ErrorString error;
    if (exception) {
        error = exception->value().toString(globalExec)->value(globalExec);
    }

    WTF::String resultMessage = JSONStringify(globalExec, dispatchResult, 0);
    if (!resultMessage.isEmpty()) {
        RefPtr<JSON::Value> parsedMessage;
        if (!JSON::Value::parseJSON(resultMessage, parsedMessage)) {
            m_backendDispatcher->reportProtocolError(Inspector::BackendDispatcher::ParseError, "Message must be in JSON format"_s);
            return;
        }

        if (!parsedMessage->asObject(messageObject)) {
            m_backendDispatcher->reportProtocolError(Inspector::BackendDispatcher::InvalidRequest, "Message must be a JSONified object"_s);
            return;
        }
    }

    m_backendDispatcher->sendResponse(callId, WTFMove(messageObject));
}
} // namespace NativeScript
