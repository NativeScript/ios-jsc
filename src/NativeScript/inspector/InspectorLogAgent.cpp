#include "InspectorLogAgent.h"
#include "GlobalObjectInspectorController.h"
#include <JavaScriptCore/InjectedScriptManager.h>
#include <JavaScriptCore/InspectorProtocolObjects.h>
#include <JavaScriptCore/ScriptCallFrame.h>
#include <JavaScriptCore/ScriptCallStack.h>

namespace Inspector {
static const unsigned maximumConsoleMessages = 100;
static const int expireConsoleMessagesStep = 10;

static Inspector::Protocol::Log::LogEntry::Source messageSourceValue(MessageSource source) {
    switch (source) {
    case MessageSource::XML:
        return Inspector::Protocol::Log::LogEntry::Source::XML;
    case MessageSource::JS:
        return Inspector::Protocol::Log::LogEntry::Source::JavaScript;
    case MessageSource::Network:
        return Inspector::Protocol::Log::LogEntry::Source::Network;
    case MessageSource::Storage:
        return Inspector::Protocol::Log::LogEntry::Source::Storage;
    case MessageSource::AppCache:
        return Inspector::Protocol::Log::LogEntry::Source::Appcache;
    case MessageSource::Rendering:
        return Inspector::Protocol::Log::LogEntry::Source::Rendering;
    case MessageSource::Security:
        return Inspector::Protocol::Log::LogEntry::Source::Security;
    case MessageSource::ConsoleAPI:
    case MessageSource::ContentBlocker:
    case MessageSource::CSS:
    case MessageSource::WebRTC:
    case MessageSource::Media:
    case MessageSource::Other:
        return Inspector::Protocol::Log::LogEntry::Source::Other;
    }
    return Inspector::Protocol::Log::LogEntry::Source::Other;
}

static Inspector::Protocol::Log::LogEntry::Level messageLevelValue(MessageLevel level) {
    switch (level) {
    case MessageLevel::Log:
    case MessageLevel::Info:
        return Inspector::Protocol::Log::LogEntry::Level::Info; // https://codereview.chromium.org/2646033003/
    case MessageLevel::Warning:
        return Inspector::Protocol::Log::LogEntry::Level::Warning;
    case MessageLevel::Error:
        return Inspector::Protocol::Log::LogEntry::Level::Error;
    case MessageLevel::Debug:
        return Inspector::Protocol::Log::LogEntry::Level::Verbose;
    }
    return Inspector::Protocol::Log::LogEntry::Level::Info;
}

static Ref<Inspector::Protocol::Console::CallFrame> buildInspectorObject(const ScriptCallFrame& callFrame) {
    return Inspector::Protocol::Console::CallFrame::create()
        .setFunctionName(callFrame.functionName())
        .setUrl(callFrame.sourceURL())
        .setScriptId(String::number(callFrame.sourceID()))
        .setLineNumber(callFrame.lineNumber() - 1)
        .setColumnNumber(callFrame.columnNumber())
        .release();
}

InspectorLogAgent::InspectorLogAgent(Inspector::JSAgentContext& context)
    : InspectorAgentBase("Log"_s)
    , m_injectedScriptManager(context.injectedScriptManager)
    , m_globalObject(*JSC::jsCast<NativeScript::GlobalObject*>(&context.inspectedGlobalObject)) {

    this->m_frontendDispatcher = std::make_unique<LogFrontendDispatcher>(context.frontendRouter);
    this->m_backendDispatcher = LogBackendDispatcher::create(context.backendDispatcher, this);
}

void InspectorLogAgent::didCreateFrontendAndBackend(FrontendRouter* frontendDispatcher, BackendDispatcher* backendDispatcher) {
}

void InspectorLogAgent::willDestroyFrontendAndBackend(DisconnectReason) {
    String errorString;
    disable(errorString);
}

void InspectorLogAgent::enable(ErrorString&) {
    if (m_enabled)
        return;

    m_enabled = true;

    if (m_expiredConsoleMessageCount) {
        ConsoleMessage expiredMessage(MessageSource::Other, MessageType::Log, MessageLevel::Warning, makeString(m_expiredConsoleMessageCount, " console messages are not shown."));
        addMessageToFrontend(&expiredMessage);
    }

    size_t messageCount = m_consoleMessages.size();
    for (size_t i = 0; i < messageCount; ++i)
        addMessageToFrontend(m_consoleMessages[i].get());
}

void InspectorLogAgent::disable(ErrorString&) {
    if (!m_enabled)
        return;

    m_enabled = false;
}

void InspectorLogAgent::clear(ErrorString&) {
    m_consoleMessages.clear();
    m_expiredConsoleMessageCount = 0;
}

void InspectorLogAgent::startViolationsReport(ErrorString&, const JSON::Array& in_config) {
}

void InspectorLogAgent::stopViolationsReport(ErrorString&) {
}

void InspectorLogAgent::addMessageToConsole(std::unique_ptr<ConsoleMessage> consoleMessage) {
    UNUSED_PARAM(m_injectedScriptManager);
    ASSERT(m_injectedScriptManager.inspectorEnvironment().developerExtrasEnabled());
    ASSERT_ARG(consoleMessage, consoleMessage);

    if (m_enabled) {
        addMessageToFrontend(consoleMessage.get());
    }

    m_consoleMessages.append(WTFMove(consoleMessage));

    if (m_consoleMessages.size() >= maximumConsoleMessages) {
        m_expiredConsoleMessageCount += expireConsoleMessagesStep;
        m_consoleMessages.remove(0, expireConsoleMessagesStep);
    }
}

void InspectorLogAgent::addMessageToFrontend(ConsoleMessage* consoleMessage) {
    Ref<Inspector::Protocol::Log::LogEntry> jsonObj = Inspector::Protocol::Log::LogEntry::create()
                                                          .setSource(messageSourceValue(consoleMessage->source()))
                                                          .setLevel(messageLevelValue(consoleMessage->level()))
                                                          .setText(consoleMessage->message())
                                                          .setTimestamp(m_globalObject.inspectorController().executionStopwatch()->elapsedTime().value())
                                                          .release();

    jsonObj->setLineNumber(static_cast<int>(consoleMessage->line()) - 1);
    jsonObj->setUrl(consoleMessage->url());

    if (consoleMessage->callStack()) {
        Ref<JSON::ArrayOf<Inspector::Protocol::Console::CallFrame>> callFrames = JSON::ArrayOf<Inspector::Protocol::Console::CallFrame>::create();

        for (size_t i = 0; i < consoleMessage->callStack()->size(); i++) {
            callFrames->addItem(buildInspectorObject(consoleMessage->callStack()->at(i)));
        }

        Ref<Inspector::Protocol::Log::StackTrace> stackTrace = Inspector::Protocol::Log::StackTrace::create()
                                                                   .setCallFrames(WTFMove(callFrames))
                                                                   .release();

        jsonObj->setStackTrace(WTFMove(stackTrace));
    }
    m_frontendDispatcher->entryAdded(WTFMove(jsonObj));
}
} // namespace Inspector
