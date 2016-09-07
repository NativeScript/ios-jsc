/*
 * Copyright (C) 2014 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "GlobalObjectInspectorController.h"
#include <JavaScriptCore/config.h>

#include "DomainInspectorAgent.h"
#include "GlobalObjectConsoleClient.h"
#include "GlobalObjectDebuggerAgent.h"
#include "InspectorNetworkAgent.h"
#include "InspectorPageAgent.h"
#include "InspectorTimelineAgent.h"
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/ConsoleMessage.h>
#include <JavaScriptCore/ErrorHandlingScope.h>
#include <JavaScriptCore/Exception.h>
#include <JavaScriptCore/InjectedScriptHost.h>
#include <JavaScriptCore/InjectedScriptManager.h>
#include <JavaScriptCore/InspectorAgent.h>
#include <JavaScriptCore/InspectorBackendDispatcher.h>
#include <JavaScriptCore/InspectorFrontendChannel.h>
#include <JavaScriptCore/InspectorFrontendRouter.h>
#include <JavaScriptCore/JSGlobalObject.h>
#include <JavaScriptCore/JSGlobalObjectConsoleAgent.h>
#include <JavaScriptCore/JSGlobalObjectRuntimeAgent.h>
#include <JavaScriptCore/ScriptArguments.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>
#include <wtf/Stopwatch.h>

#include <cxxabi.h>
#if OS(DARWIN) || (OS(LINUX) && !PLATFORM(GTK))
#include <dlfcn.h>
#include <execinfo.h>
#endif

#if ENABLE(REMOTE_INSPECTOR)
#include <JavaScriptCore/JSGlobalObjectDebuggable.h>
#include <JavaScriptCore/RemoteInspector.h>
#endif

using namespace JSC;
using namespace Inspector;

namespace NativeScript {
EncodedJSValue JSC_HOST_CALL registerDispatcher(ExecState* execState) {
    NativeScript::GlobalObject* globalObject = jsCast<NativeScript::GlobalObject*>(execState->lexicalGlobalObject());
    WTF::String domainIdentifier = execState->argument(0).toWTFString(execState);
    JSCell* constructorFunction = execState->argument(1).asCell();

    globalObject->inspectorController().registerDomainDispatcher(domainIdentifier, constructorFunction);

    return JSValue::encode(jsUndefined());
}

EncodedJSValue JSC_HOST_CALL sendEvent(ExecState* execState) {
    NativeScript::GlobalObject* globalObject = jsCast<NativeScript::GlobalObject*>(execState->lexicalGlobalObject());

    globalObject->inspectorController().frontendRouter().sendResponse(execState->argument(0).toWTFString(execState));

    return JSValue::encode(jsUndefined());
}

EncodedJSValue JSC_HOST_CALL inspectorTimestamp(ExecState* execState) {
    NativeScript::GlobalObject* globalObject = jsCast<NativeScript::GlobalObject*>(execState->lexicalGlobalObject());

    JSValue elapsedTime = jsNumber(globalObject->inspectorController().executionStopwatch()->elapsedTime());

    return JSValue::encode(elapsedTime);
}

GlobalObjectInspectorController::GlobalObjectInspectorController(GlobalObject& globalObject)
    : m_injectedScriptManager(std::make_unique<InjectedScriptManager>(*this, InjectedScriptHost::create()))
    , m_executionStopwatch(Stopwatch::create())
    , m_scriptDebugServer(globalObject)
    , m_frontendRouter(FrontendRouter::create())
    , m_backendDispatcher(BackendDispatcher::create(m_frontendRouter.copyRef()))
    , m_globalObject(globalObject)
    , m_agentContext({ *this, *m_injectedScriptManager, m_frontendRouter.get(), m_backendDispatcher.get() })
    , m_jsAgentContext(m_agentContext, m_globalObject)

{
    globalObject.putDirectNativeFunction(globalObject.vm(), &globalObject, Identifier::fromString(&globalObject.vm(), WTF::ASCIILiteral("__registerDomainDispatcher")), 2, &registerDispatcher, NoIntrinsic, DontEnum);
    globalObject.putDirectNativeFunction(globalObject.vm(), &globalObject, Identifier::fromString(&globalObject.vm(), WTF::ASCIILiteral("__inspectorTimestamp")), 0, &inspectorTimestamp, NoIntrinsic, DontEnum);
    globalObject.putDirectNativeFunction(globalObject.vm(), &globalObject, Identifier::fromString(&globalObject.vm(), WTF::ASCIILiteral("__inspectorSendEvent")), 1, &sendEvent, NoIntrinsic, DontEnum);
    globalObject.putDirectNativeFunction(globalObject.vm(), &globalObject, JSC::Identifier::fromString(&globalObject.vm(), WTF::ASCIILiteral("__startProfile")), 1, &startProfile, JSC::NoIntrinsic, JSC::DontEnum);
    globalObject.putDirectNativeFunction(globalObject.vm(), &globalObject, JSC::Identifier::fromString(&globalObject.vm(), WTF::ASCIILiteral("__stopProfile")), 1, &stopProfile, JSC::NoIntrinsic, JSC::DontEnum);

    auto inspectorAgent = std::make_unique<InspectorAgent>(m_jsAgentContext);
    auto runtimeAgent = std::make_unique<JSGlobalObjectRuntimeAgent>(m_jsAgentContext);
    auto consoleAgent = std::make_unique<JSGlobalObjectConsoleAgent>(m_jsAgentContext);
    auto debuggerAgent = std::make_unique<GlobalObjectDebuggerAgent>(m_jsAgentContext, consoleAgent.get());
    auto pageAgent = std::make_unique<InspectorPageAgent>(m_jsAgentContext);
    auto timelineAgent = std::make_unique<InspectorTimelineAgent>(m_jsAgentContext);
    auto networkAgent = std::make_unique<InspectorNetworkAgent>(m_jsAgentContext);

    m_inspectorAgent = inspectorAgent.get();
    m_debuggerAgent = debuggerAgent.get();
    m_consoleAgent = consoleAgent.get();
    m_consoleClient = std::make_unique<GlobalObjectConsoleClient>(m_consoleAgent);

    m_agents.append(WTF::move(inspectorAgent));
    m_agents.append(WTF::move(timelineAgent));
    m_agents.append(WTF::move(pageAgent));
    m_agents.append(WTF::move(runtimeAgent));
    m_agents.append(WTF::move(consoleAgent));
    m_agents.append(WTF::move(debuggerAgent));
    m_agents.append(WTF::move(networkAgent));

    m_executionStopwatch->start();
}

GlobalObjectInspectorController::~GlobalObjectInspectorController() {
}

void GlobalObjectInspectorController::registerDomainDispatcher(WTF::String domainIdentifier, JSC::JSCell* constructorFunction) {
    std::unique_ptr<DomainInspectorAgent> domainInspectorAgent = std::make_unique<DomainInspectorAgent>(domainIdentifier, constructorFunction, this->m_jsAgentContext);

    appendExtraAgent(WTF::move(domainInspectorAgent));
}

void GlobalObjectInspectorController::globalObjectDestroyed() {
    disconnectAllFrontends();

    m_injectedScriptManager->disconnect();
}

void GlobalObjectInspectorController::connectFrontend(FrontendChannel* frontendChannel, bool isAutomaticInspection) {
    ASSERT_ARG(frontendChannel, frontendChannel);

    m_isAutomaticInspection = isAutomaticInspection;

    bool connectedFirstFrontend = !m_frontendRouter->hasFrontends();
    m_frontendRouter->connectFrontend(frontendChannel);

    if (!connectedFirstFrontend)
        return;

    m_agents.didCreateFrontendAndBackend(m_frontendRouter.ptr(), m_backendDispatcher.ptr());

#if ENABLE(INSPECTOR_ALTERNATE_DISPATCHERS)
    m_inspectorAgent->activateExtraDomains(m_agents.extraDomains());

    if (m_augmentingClient)
        m_augmentingClient->inspectorConnected();
#endif
}

void GlobalObjectInspectorController::disconnectFrontend(FrontendChannel* frontendChannel) {
    ASSERT_ARG(frontendChannel, frontendChannel);

    // FIXME: change this to notify agents which frontend has disconnected (by id).
    m_agents.willDestroyFrontendAndBackend(DisconnectReason::InspectorDestroyed);

    m_frontendRouter->disconnectFrontend(frontendChannel);

    m_isAutomaticInspection = false;

    bool disconnectedLastFrontend = !m_frontendRouter->hasFrontends();
    if (!disconnectedLastFrontend)
        return;

#if ENABLE(INSPECTOR_ALTERNATE_DISPATCHERS)
    if (m_augmentingClient)
        m_augmentingClient->inspectorDisconnected();
#endif
}

void GlobalObjectInspectorController::disconnectAllFrontends() {
    // FIXME: change this to notify agents which frontend has disconnected (by id).
    m_agents.willDestroyFrontendAndBackend(DisconnectReason::InspectedTargetDestroyed);

    m_frontendRouter->disconnectAllFrontends();

    m_isAutomaticInspection = false;

#if ENABLE(INSPECTOR_ALTERNATE_DISPATCHERS)
    if (m_augmentingClient)
        m_augmentingClient->inspectorDisconnected();
#endif
}

void GlobalObjectInspectorController::dispatchMessageFromFrontend(const String& message) {
    m_backendDispatcher->dispatch(message);
}

void GlobalObjectInspectorController::pause() {
    ErrorString dummyError;
    m_debuggerAgent->enable(dummyError);
    m_debuggerAgent->pause(dummyError);
}

void GlobalObjectInspectorController::appendAPIBacktrace(ScriptCallStack* callStack) {
#if OS(DARWIN) || (OS(LINUX) && !PLATFORM(GTK))
    static const int framesToShow = 31;
    static const int framesToSkip = 3; // WTFGetBacktrace, appendAPIBacktrace, reportAPIException.

    void* samples[framesToShow + framesToSkip];
    int frames = framesToShow + framesToSkip;
    WTFGetBacktrace(samples, &frames);

    void** stack = samples + framesToSkip;
    int size = frames - framesToSkip;
    for (int i = 0; i < size; ++i) {
        const char* mangledName = nullptr;
        char* cxaDemangled = nullptr;
        Dl_info info;
        if (dladdr(stack[i], &info) && info.dli_sname)
            mangledName = info.dli_sname;
        if (mangledName)
            cxaDemangled = abi::__cxa_demangle(mangledName, nullptr, nullptr, nullptr);
        if (mangledName || cxaDemangled)
            callStack->append(ScriptCallFrame(cxaDemangled ? cxaDemangled : mangledName, ASCIILiteral("[native code]"), 0, 0));
        else
            callStack->append(ScriptCallFrame(ASCIILiteral("?"), ASCIILiteral("[native code]"), 0, 0));
        free(cxaDemangled);
    }
#else
    UNUSED_PARAM(callStack);
#endif
}

void GlobalObjectInspectorController::reportAPIException(ExecState* exec, Exception* exception) {
    if (isTerminatedExecutionException(exception))
        return;

    ErrorHandlingScope errorScope(exec->vm());

    RefPtr<ScriptCallStack> callStack = createScriptCallStackFromException(exec, exception, ScriptCallStack::maxCallStackSizeToCapture);
    if (includesNativeCallStackWhenReportingExceptions())
        appendAPIBacktrace(callStack.get());

    // FIXME: <http://webkit.org/b/115087> Web Inspector: Should not evaluate JavaScript handling exceptions
    // If this is a custom exception object, call toString on it to try and get a nice string representation for the exception.
    String errorMessage = exception->value().toString(exec)->value(exec);
    exec->clearException();

    if (GlobalObjectConsoleClient::logToSystemConsole()) {
        if (callStack->size()) {
            const ScriptCallFrame& callFrame = callStack->at(0);
            ConsoleClient::printConsoleMessage(MessageSource::JS, MessageType::Log, MessageLevel::Error, errorMessage, callFrame.sourceURL(), callFrame.lineNumber(), callFrame.columnNumber());
        } else
            ConsoleClient::printConsoleMessage(MessageSource::JS, MessageType::Log, MessageLevel::Error, errorMessage, String(), 0, 0);
    }

    m_consoleAgent->addMessageToConsole(std::make_unique<ConsoleMessage>(MessageSource::JS, MessageType::Log, MessageLevel::Error, errorMessage, callStack));
}

bool GlobalObjectInspectorController::developerExtrasEnabled() const {
#if ENABLE(REMOTE_INSPECTOR)
    if (!RemoteInspector::singleton().enabled())
        return false;

    if (!m_globalObject.inspectorDebuggable().remoteDebuggingAllowed())
        return false;
#endif

    return true;
}

InspectorFunctionCallHandler GlobalObjectInspectorController::functionCallHandler() const {
    return JSC::call;
}

InspectorEvaluateHandler GlobalObjectInspectorController::evaluateHandler() const {
    return JSC::evaluate;
}

void GlobalObjectInspectorController::frontendInitialized() {
#if ENABLE(REMOTE_INSPECTOR)
    if (m_isAutomaticInspection)
        m_globalObject.inspectorDebuggable().unpauseForInitializedInspector();
#endif
}

Ref<Stopwatch> GlobalObjectInspectorController::executionStopwatch() {
    return m_executionStopwatch.copyRef();
}

Inspector::ScriptDebugServer& GlobalObjectInspectorController::scriptDebugServer() {
    return m_scriptDebugServer;
}

JSC::VM& GlobalObjectInspectorController::vm() {
    return m_globalObject.vm();
}

#if ENABLE(INSPECTOR_ALTERNATE_DISPATCHERS)
void GlobalObjectInspectorController::appendExtraAgent(std::unique_ptr<InspectorAgentBase> agent) {
    String domainName = agent->domainName();

    // FIXME: change this to notify agents which frontend has connected (by id).
    agent->didCreateFrontendAndBackend(nullptr, nullptr);

    m_agents.appendExtraAgent(WTF::move(agent));

    m_inspectorAgent->activateExtraDomain(domainName);
}
#endif

} // namespace Inspector
