#pragma once

#include <JavaScriptCore/ConsoleMessage.h>
#include <JavaScriptCore/inspector/InspectorAgentBase.h>
#include <JavaScriptCore/inspector/InspectorBackendDispatchers.h>
#include <JavaScriptCore/inspector/InspectorFrontendDispatchers.h>
#include <map>

namespace Inspector {
class InspectorLogAgent : public InspectorAgentBase,
                          public LogBackendDispatcherHandler {
    WTF_MAKE_NONCOPYABLE(InspectorLogAgent);
    WTF_MAKE_FAST_ALLOCATED;

public:
    InspectorLogAgent(Inspector::JSAgentContext& agentContext);

    virtual void didCreateFrontendAndBackend(FrontendRouter*, BackendDispatcher*) override;
    virtual void willDestroyFrontendAndBackend(DisconnectReason) override;

    virtual void enable(ErrorString&) override;
    virtual void disable(ErrorString&) override;
    virtual void clear(ErrorString&) override;
    virtual void startViolationsReport(ErrorString&, const Inspector::InspectorArray& in_config) override;
    virtual void stopViolationsReport(ErrorString&) override;

    void addMessageToConsole(std::unique_ptr<ConsoleMessage>);

private:
    void addMessageToFrontend(ConsoleMessage* consoleMessage);

    std::unique_ptr<LogFrontendDispatcher> m_frontendDispatcher;
    RefPtr<LogBackendDispatcher> m_backendDispatcher;

    bool m_enabled{ false };
    int m_expiredConsoleMessageCount{ 0 };
    InjectedScriptManager& m_injectedScriptManager;
    NativeScript::GlobalObject& m_globalObject;
    Vector<std::unique_ptr<ConsoleMessage>> m_consoleMessages;
};
} // namespace Inspector
