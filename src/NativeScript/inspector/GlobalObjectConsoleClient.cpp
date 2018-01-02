#include "GlobalObjectConsoleClient.h"
#include "GlobalObjectInspectorController.h"
#include "InspectorTimelineAgent.h"
#include <JavaScriptCore/ConsoleMessage.h>
#include <JavaScriptCore/InspectorConsoleAgent.h>
#include <JavaScriptCore/ScriptArguments.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>
#include <JavaScriptCore/ScriptValue.h>
#include <wtf/text/StringBuilder.h>

namespace NativeScript {
#if !LOG_DISABLED
static bool sLogToSystemConsole = true;
#else
static bool sLogToSystemConsole = false;
#endif

static void appendURLAndPosition(StringBuilder& builder, const String& url, unsigned lineNumber, unsigned columnNumber) {
    if (url.isEmpty())
        return;

    builder.append(url);

    if (lineNumber > 0) {
        builder.append(':');
        builder.appendNumber(lineNumber);
    }

    if (columnNumber > 0) {
        builder.append(':');
        builder.appendNumber(columnNumber);
    }
}

bool GlobalObjectConsoleClient::logToSystemConsole() {
    return sLogToSystemConsole;
}

void GlobalObjectConsoleClient::setLogToSystemConsole(bool shouldLog) {
    sLogToSystemConsole = shouldLog;
}

GlobalObjectConsoleClient::GlobalObjectConsoleClient(Inspector::InspectorConsoleAgent* consoleAgent, Inspector::InspectorLogAgent* logAgent)
    : ConsoleClient()
    , m_consoleAgent(consoleAgent)
    , m_logAgent(logAgent) {
}

void GlobalObjectConsoleClient::messageWithTypeAndLevel(MessageType type, MessageLevel level, JSC::ExecState* exec, RefPtr<Inspector::ScriptArguments>&& arguments) {
    if (GlobalObjectConsoleClient::logToSystemConsole()) {
        if (type != JSC::MessageType::Trace) {
            this->printConsoleMessageWithArguments(MessageSource::ConsoleAPI, type, level, exec, arguments.copyRef());
        } else {
            ConsoleClient::printConsoleMessageWithArguments(MessageSource::ConsoleAPI, type, level, exec, arguments.copyRef());
        }
    }

    String message;
    arguments->getFirstArgumentAsString(message);

    m_logAgent->addMessageToConsole(std::make_unique<Inspector::ConsoleMessage>(MessageSource::ConsoleAPI, type, level, message, WTF::emptyString(), 0, 0, exec));
    m_consoleAgent->addMessageToConsole(std::make_unique<Inspector::ConsoleMessage>(MessageSource::ConsoleAPI, type, level, message, WTFMove(arguments), exec));
}

void GlobalObjectConsoleClient::printConsoleMessageWithArguments(MessageSource source, MessageType type, MessageLevel level, JSC::ExecState* exec, RefPtr<Inspector::ScriptArguments>&& arguments) {
    RefPtr<Inspector::ScriptCallStack> callStack(Inspector::createScriptCallStackForConsole(exec, 1));
    const Inspector::ScriptCallFrame& lastCaller = callStack->size() > 0 ? callStack->at(0) : Inspector::ScriptCallFrame("", "", JSC::noSourceID, 0, 0);

    StringBuilder builder;

    if (!lastCaller.sourceURL().isEmpty()) {
        appendURLAndPosition(builder, lastCaller.sourceURL(), lastCaller.lineNumber(), lastCaller.columnNumber());
        builder.appendLiteral(": ");
    }

    if (type == JSC::MessageType::Dir) {
        JSC::JSValue argumentValue = arguments->argumentAt(0).jsValue();
        builder.append(this->getDirMessage(exec, argumentValue));
    } else {
        for (size_t i = 0; i < arguments->argumentCount(); ++i) {
            String argAsString = arguments->argumentAt(i).toString(arguments->globalState());
            if (i > 0) {
                builder.append(' ');
            }
            builder.append(argAsString);
        }
    }

    ConsoleClient::printConsoleMessage(source, type, level, builder.toString(), WTF::emptyString(), 0, 0);
}

void GlobalObjectConsoleClient::count(JSC::ExecState* exec, RefPtr<Inspector::ScriptArguments>&& arguments) {
    m_consoleAgent->count(exec, arguments);
}

void GlobalObjectConsoleClient::profile(JSC::ExecState* execState, const String& title) {
    NativeScript::GlobalObject* globalObject = JSC::jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    Inspector::InspectorTimelineAgent* timelineAgent = globalObject->inspectorController().timelineAgent();
    if (timelineAgent) {
        timelineAgent->startFromConsole(execState, title);
    }
}

void GlobalObjectConsoleClient::profileEnd(JSC::ExecState* execState, const String& title) {
    NativeScript::GlobalObject* globalObject = JSC::jsCast<NativeScript::GlobalObject*>(execState->lexicalGlobalObject());
    Inspector::InspectorTimelineAgent* timelineAgent = globalObject->inspectorController().timelineAgent();
    if (timelineAgent) {
        timelineAgent->stopFromConsole(execState, title);
    }
}

void GlobalObjectConsoleClient::takeHeapSnapshot(JSC::ExecState*, const String& title) {
    m_consoleAgent->takeHeapSnapshot(title);
}

void GlobalObjectConsoleClient::time(JSC::ExecState*, const String& title) {
    std::unique_ptr<Inspector::ConsoleMessage> startMsg = m_consoleAgent->startTiming(title);
    if (startMsg) {
        ConsoleClient::printConsoleMessage(startMsg->source(), startMsg->type(), startMsg->level(), startMsg->message(), startMsg->url(), startMsg->line(), startMsg->column());
    }
}

void GlobalObjectConsoleClient::timeEnd(JSC::ExecState* exec, const String& title) {
    Ref<Inspector::ScriptCallStack> callStack(Inspector::createScriptCallStackForConsole(exec, 1));
    std::unique_ptr<Inspector::ConsoleMessage> stopMsg = m_consoleAgent->stopTiming(title, WTFMove(callStack));
    if (stopMsg) {
        ConsoleClient::printConsoleMessage(stopMsg->source(), stopMsg->type(), stopMsg->level(), stopMsg->message(), stopMsg->url(), stopMsg->line(), stopMsg->column());
    }
}

void GlobalObjectConsoleClient::timeStamp(JSC::ExecState*, RefPtr<Inspector::ScriptArguments>&&) {
    // FIXME: JSContext inspection needs a timeline.
    warnUnimplemented(ASCIILiteral("console.timeStamp"));
}

void GlobalObjectConsoleClient::warnUnimplemented(const String& method) {
    String message = method + " is currently ignored in JavaScript context inspection.";
    m_consoleAgent->addMessageToConsole(std::make_unique<Inspector::ConsoleMessage>(MessageSource::ConsoleAPI, MessageType::Log, MessageLevel::Warning, message, nullptr, nullptr));
}

WTF::String GlobalObjectConsoleClient::getDirMessage(JSC::ExecState* exec, JSC::JSValue argument) {
    StringBuilder output;
    output.append(argument.toWTFString(exec));

    if (argument.isObject()) {
        output.append("\n");

        JSC::JSObject* jsObject = argument.getObject();
        JSC::PropertyNameArray propertyNames(exec, JSC::PropertyNameMode::Strings);
        JSC::EnumerationMode mode;
        jsObject->getPropertyNames(jsObject, exec, propertyNames, mode);

        for (JSC::PropertyName propertyName : propertyNames) {
            JSC::JSValue value = argument.get(exec, propertyName);
            output.append(WTF::String(propertyName.uid()));
            output.append(": ");
            output.append(value.toWTFString(exec));
            output.append("\n");
        }
    }

    return output.toString();
}
}
