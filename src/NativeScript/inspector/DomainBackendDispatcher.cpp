#include <stdio.h>
#include "DomainBackendDispatcher.h"
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/InspectorAgentBase.h>
#include <JavaScriptCore/Inspector/InspectorBackendDispatchers.h>
#include <JavaScriptCore/Inspector/InspectorFrontendDispatchers.h>
#include <JavaScriptCore/runtime/Exception.h>
#include <JavaScriptCore/runtime/JSONObject.h>
#include "GlobalObjectInspectorController.h"

namespace NativeScript {
using namespace JSC;

static EncodedJSValue JSC_HOST_CALL dispatchMessage(ExecState* execState) {
    NativeScript::GlobalObject* globalObject = jsCast<NativeScript::GlobalObject*>(execState->lexicalGlobalObject());

    globalObject->inspectorController().frontendRouter().sendResponse(execState->argument(0).toWTFString(execState));

    return JSValue::encode(jsUndefined());
}

Ref<DomainBackendDispatcher> DomainBackendDispatcher::create(WTF::String domain, JSCell* constructorFunction, Inspector::BackendDispatcher* backendDispatcher, NativeScript::GlobalObject& globalObject) {
    return adoptRef(*new DomainBackendDispatcher(domain, constructorFunction, *backendDispatcher, globalObject));
}

DomainBackendDispatcher::DomainBackendDispatcher(WTF::String domain, JSCell* constructorFunction, Inspector::BackendDispatcher& backendDispatcher, NativeScript::GlobalObject& globalObject)
    : SupplementalBackendDispatcher(backendDispatcher)
    , m_globalObject(globalObject) {
    ConstructData constructData;
    ConstructType constructType = getConstructData(constructorFunction, constructData);
    JSFunction* dispatchMessageFunction = JSFunction::create(m_globalObject.vm(), &m_globalObject, 0, WTF::ASCIILiteral("dispatchMessage"), &dispatchMessage);

    MarkedArgumentBuffer constructArgs;
    constructArgs.append(dispatchMessageFunction);

    JSObject* domainDispatcher = construct(m_globalObject.globalExec(), constructorFunction, constructType, constructData, constructArgs);
    m_domainDispatcher = Strong<JSObject>(m_globalObject.vm(), domainDispatcher);

    m_backendDispatcher->registerDispatcherForDomain(domain, this);
}

void DomainBackendDispatcher::dispatch(long callId, const String& method, Ref<Inspector::InspectorObject>&& message) {
    ExecState* globalExec = m_globalObject.globalExec();
    MarkedArgumentBuffer dispatchArguments;

    RefPtr<Inspector::InspectorObject> paramsContainer;
    message->getObject(ASCIILiteral("params"), paramsContainer);
    if (paramsContainer) {
        dispatchArguments.append(JSONParse(globalExec, paramsContainer->toJSONString()));
    }

    JSValue functionValue = m_domainDispatcher->get(globalExec, Identifier::fromString(&m_globalObject.vm(), method));
    if (functionValue.isUndefined()) {
        m_backendDispatcher->reportProtocolError(Inspector::BackendDispatcher::InvalidRequest, WTF::String::format("No implementation for method %s found", method.utf8().data()));
        return;
    }

    CallData dispatchCallData;
    CallType dispatchCallType = getCallData(functionValue, dispatchCallData);

    WTF::NakedPtr<Exception> exception;
    JSValue dispatchResult = call(globalExec, functionValue, dispatchCallType, dispatchCallData, m_domainDispatcher.get(), dispatchArguments, exception);

    RefPtr<Inspector::InspectorObject> messageObject = Inspector::InspectorObject::create();
    Inspector::ErrorString error;
    if (exception) {
        error = exception->value().toString(globalExec)->value(globalExec);
    }

    WTF::String resultMessage = JSONStringify(globalExec, dispatchResult, 0);
    if (!resultMessage.isEmpty()) {
        RefPtr<Inspector::InspectorValue> parsedMessage;
        if (!Inspector::InspectorValue::parseJSON(resultMessage, parsedMessage)) {
            m_backendDispatcher->reportProtocolError(Inspector::BackendDispatcher::ParseError, ASCIILiteral("Message must be in JSON format"));
            return;
        }

        if (!parsedMessage->asObject(messageObject)) {
            m_backendDispatcher->reportProtocolError(Inspector::BackendDispatcher::InvalidRequest, ASCIILiteral("Message must be a JSONified object"));
            return;
        }
    }

    m_backendDispatcher->sendResponse(callId, WTF::move(messageObject));
}
}
