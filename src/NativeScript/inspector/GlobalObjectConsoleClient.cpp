#include "GlobalObjectConsoleClient.h"
#include <JavaScriptCore/ConsoleMessage.h>
#include <JavaScriptCore/InspectorConsoleAgent.h>
#include <JavaScriptCore/ScriptArguments.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>
#include <JavaScriptCore/ScriptValue.h>
#include "InspectorTimelineAgent.h"
#include "GlobalObjectInspectorController.h"

namespace NativeScript {
#if !LOG_DISABLED
static bool sLogToSystemConsole = true;
#else
static bool sLogToSystemConsole = false;
#endif

bool GlobalObjectConsoleClient::logToSystemConsole() {
    return sLogToSystemConsole;
}

void GlobalObjectConsoleClient::setLogToSystemConsole(bool shouldLog) {
    sLogToSystemConsole = shouldLog;
}

GlobalObjectConsoleClient::GlobalObjectConsoleClient(Inspector::InspectorConsoleAgent* consoleAgent)
    : ConsoleClient()
    , m_consoleAgent(consoleAgent) {
}

void GlobalObjectConsoleClient::messageWithTypeAndLevel(MessageType type, MessageLevel level, JSC::ExecState* exec, RefPtr<Inspector::ScriptArguments>&& arguments) {
    if (GlobalObjectConsoleClient::logToSystemConsole()) {
        if (type == JSC::MessageType::Dir) {
            WTF::String message = this->getDirMessage(exec, arguments);
            ConsoleClient::printConsoleMessage(MessageSource::ConsoleAPI, MessageType::Dir, MessageLevel::Log, message, WTF::emptyString(), 0, 0);
        } else {
            ConsoleClient::printConsoleMessageWithArguments(MessageSource::ConsoleAPI, type, level, exec, arguments.copyRef());
        }
    }

    String message;
    arguments->getFirstArgumentAsString(message);
    m_consoleAgent->addMessageToConsole(std::make_unique<Inspector::ConsoleMessage>(MessageSource::ConsoleAPI, type, level, message, WTF::move(arguments), exec));
}

void GlobalObjectConsoleClient::count(JSC::ExecState* exec, RefPtr<Inspector::ScriptArguments>&& arguments) {
    m_consoleAgent->count(exec, arguments);
}

void GlobalObjectConsoleClient::profile(JSC::ExecState* execState, const String&) {
    NativeScript::GlobalObject* globalObject = JSC::jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    Inspector::InspectorTimelineAgent* timelineAgent = globalObject->inspectorController().timelineAgent();
    if (timelineAgent) {
        Inspector::ErrorString unused;
        timelineAgent->start(unused, nullptr);
    }
}

void GlobalObjectConsoleClient::profileEnd(JSC::ExecState* execState, const String&) {
    NativeScript::GlobalObject* globalObject = JSC::jsCast<NativeScript::GlobalObject*>(execState->lexicalGlobalObject());
    Inspector::InspectorTimelineAgent* timelineAgent = globalObject->inspectorController().timelineAgent();
    if (timelineAgent) {
        Inspector::ErrorString unused;
        timelineAgent->stop(unused);
    }
}

void GlobalObjectConsoleClient::time(JSC::ExecState*, const String& title) {
    m_consoleAgent->startTiming(title);
}

void GlobalObjectConsoleClient::timeEnd(JSC::ExecState* exec, const String& title) {
    RefPtr<Inspector::ScriptCallStack> callStack(Inspector::createScriptCallStackForConsole(exec, 1));
    m_consoleAgent->stopTiming(title, WTF::move(callStack));
}

void GlobalObjectConsoleClient::timeStamp(JSC::ExecState*, RefPtr<Inspector::ScriptArguments>&&) {
    // FIXME: JSContext inspection needs a timeline.
    warnUnimplemented(ASCIILiteral("console.timeStamp"));
}

void GlobalObjectConsoleClient::warnUnimplemented(const String& method) {
    String message = method + " is currently ignored in JavaScript context inspection.";
    m_consoleAgent->addMessageToConsole(std::make_unique<Inspector::ConsoleMessage>(MessageSource::ConsoleAPI, MessageType::Log, MessageLevel::Warning, message, nullptr, nullptr));
}

WTF::String GlobalObjectConsoleClient::getDirMessage(JSC::ExecState* exec, RefPtr<Inspector::ScriptArguments>& arguments) {
    JSC::JSValue argumentValue = arguments->argumentAt(0).jsValue();
    StringBuilder output;
    output.append(argumentValue.toWTFString(exec).utf8().data());

    if (argumentValue.isObject()) {
        output.append("\n{ ");

        JSC::JSObject* jsObject = argumentValue.getObject();
        JSC::PropertyNameArray propertyNames(exec);
        JSC::EnumerationMode mode;
        jsObject->getPropertyNames(jsObject, exec, propertyNames, mode);

        for (size_t i = 0; i < propertyNames.size(); ++i) {
            if (i)
                output.append(",\n");
            const JSC::PropertyName& propertyName = propertyNames[i];
            JSC::JSValue value = argumentValue.get(exec, propertyName);
            output.append(WTF::String::format("%s: %s", propertyName.uid()->utf8().data(), value.toWTFString(exec).utf8().data()));
        }

        output.append(" }");
    }

    return output.toString();
}
}