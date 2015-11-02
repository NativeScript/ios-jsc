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

#ifndef GlobalObjectInspectorController_h
#define GlobalObjectInspectorController_h

#include <JavaScriptCore/InspectorAgentRegistry.h>
#include <JavaScriptCore/InspectorEnvironment.h>
#include <wtf/Forward.h>
#include <wtf/Noncopyable.h>
#include <wtf/text/WTFString.h>

#if ENABLE(INSPECTOR_ALTERNATE_DISPATCHERS)
#include <JavaScriptCore/AugmentableInspectorController.h>
#endif

namespace Inspector {
class BackendDispatcher;
class FrontendChannel;
class InjectedScriptManager;
class InspectorAgent;
class InspectorConsoleAgent;
class InspectorDebuggerAgent;
class InspectorTimelineAgent;
class JSGlobalObjectConsoleClient;
class ScriptCallStack;
}

namespace WTF {
class Stopwatch;
}

namespace JSC {
class JSGlobalObjectConsole;
class ConsoleClient;
class Exception;
class ExecState;
class JSGlobalObject;
class JSValue;
}

namespace NativeScript {

JSC::EncodedJSValue JSC_HOST_CALL registerDispatcher(JSC::ExecState* execState);

class GlobalObjectInspectorController final
    : public Inspector::InspectorEnvironment
#if ENABLE(INSPECTOR_ALTERNATE_DISPATCHERS)
      ,
      public Inspector::AugmentableInspectorController
#endif
      {
    WTF_MAKE_NONCOPYABLE(GlobalObjectInspectorController);
    WTF_MAKE_FAST_ALLOCATED;

public:
    GlobalObjectInspectorController(GlobalObject&);
    ~GlobalObjectInspectorController();

    void connectFrontend(Inspector::FrontendChannel*, bool isAutomaticInspection);
    void disconnectFrontend(Inspector::DisconnectReason);
    void dispatchMessageFromFrontend(const String&);

    void globalObjectDestroyed();
    void registerDomainDispatcher(WTF::String domainIdentifier, JSC::JSCell* constructorFunction);

    bool includesNativeCallStackWhenReportingExceptions() const { return m_includeNativeCallStackWithExceptions; }
    void setIncludesNativeCallStackWhenReportingExceptions(bool includesNativeCallStack) { m_includeNativeCallStackWithExceptions = includesNativeCallStack; }

    void pause();
    void reportAPIException(JSC::ExecState*, JSC::Exception*);

    JSC::ConsoleClient* consoleClient() const {
        return m_consoleClient.get();
    }

    Inspector::InspectorTimelineAgent* timelineAgent() const {
        return m_timelineAgent;
    }

    virtual bool developerExtrasEnabled() const override;
    virtual bool canAccessInspectedScriptState(JSC::ExecState*) const override { return true; }
    virtual Inspector::InspectorFunctionCallHandler functionCallHandler() const override;
    virtual Inspector::InspectorEvaluateHandler evaluateHandler() const override;
    virtual void willCallInjectedScriptFunction(JSC::ExecState*, const String&, int) override {}
    virtual void didCallInjectedScriptFunction(JSC::ExecState*) override {}
    virtual void frontendInitialized() override;
    virtual Ref<WTF::Stopwatch> executionStopwatch() override;

#if ENABLE(INSPECTOR_ALTERNATE_DISPATCHERS)
    virtual Inspector::AugmentableInspectorControllerClient* augmentableInspectorControllerClient() const override { return m_augmentingClient; }
    virtual void setAugmentableInspectorControllerClient(Inspector::AugmentableInspectorControllerClient* client) override { m_augmentingClient = client; }

    virtual Inspector::FrontendChannel* frontendChannel() const override { return m_frontendChannel; }
    virtual void appendExtraAgent(std::unique_ptr<Inspector::InspectorAgentBase>) override;
#endif

private:
    void appendAPIBacktrace(Inspector::ScriptCallStack* callStack);

    GlobalObject& m_globalObject;
    std::unique_ptr<Inspector::InjectedScriptManager> m_injectedScriptManager;
    std::unique_ptr<JSC::ConsoleClient> m_consoleClient;
    Inspector::InspectorAgent* m_inspectorAgent;
    Inspector::InspectorConsoleAgent* m_consoleAgent;
    Inspector::InspectorDebuggerAgent* m_debuggerAgent;
    Inspector::InspectorTimelineAgent* m_timelineAgent;
    Inspector::AgentRegistry m_agents;
    Inspector::FrontendChannel* m_frontendChannel;
    RefPtr<Inspector::BackendDispatcher> m_backendDispatcher;
    Ref<WTF::Stopwatch> m_executionStopwatch;
    bool m_includeNativeCallStackWithExceptions;
    bool m_isAutomaticInspection;

#if ENABLE(INSPECTOR_ALTERNATE_DISPATCHERS)
    Inspector::AugmentableInspectorControllerClient* m_augmentingClient;
#endif
};

} // namespace Inspector

#endif // !defined(GlobalObjectInspectorController_h)
