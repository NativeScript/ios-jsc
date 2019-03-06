#include "GlobalObjectConsoleClient.h"
#include "GlobalObjectInspectorController.h"
#include "InspectorTimelineAgent.h"
#include <GlobalObject.h>
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/ConsoleMessage.h>
#include <JavaScriptCore/Exception.h>
#include <JavaScriptCore/InspectorConsoleAgent.h>
#include <JavaScriptCore/ScriptArguments.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>
#include <JavaScriptCore/ScriptValue.h>
#include <runtime/JSONObject.h>
#include <wtf/text/StringBuilder.h>

namespace NativeScript {
using namespace JSC;
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

static WTF::String smartStringifyObject(ExecState* exec, JSC::JSValue value) {
    JSC::CallData smartStringifyCallData;
    NativeScript::GlobalObject* globalObject = JSC::jsCast<GlobalObject*>(exec->lexicalGlobalObject());
    CallType callType = globalObject->smartStringifyFunction()->getCallData(globalObject->smartStringifyFunction(), smartStringifyCallData);
    JSC::MarkedArgumentBuffer argumentBuffer;
    argumentBuffer.append(value);
    JSC::JSValue smartStringifyResult = JSC::call(exec, globalObject->smartStringifyFunction(), callType, smartStringifyCallData, exec->lexicalGlobalObject(), argumentBuffer);
    return smartStringifyResult.toWTFString(exec);
}

static WTF::String getStringRepresentationOfObject(JSC::ExecState* exec, JSC::JSValue value) {
    if (value.isFunction(exec->vm())) {
        return "()";
    } else if (value.inherits(exec->vm(), JSC::JSArray::info())) {
        JSC::JSArray* arrayValue = jsCast<JSC::JSArray*>(value);
        StringBuilder output;
        output.append("[");
        for (unsigned i = 0; i < arrayValue->length(); i++) {
            JSC::JSValue item = arrayValue->JSArray::getIndex(exec, i);
            if (item.isObject()) {
                output.append(smartStringifyObject(exec, item));
            } else {
                output.append(getStringRepresentationOfObject(exec, item));
            }
            if (i < arrayValue->length() - 1) {
                output.append(", ");
            }
        }
        output.append("]");
        return output.toString();
    } else if (value.isObject()) {
        String valueAsString = value.toWTFString(exec);
        if (valueAsString.contains("[object Object]")) {
            return smartStringifyObject(exec, value);
        } else {
            return valueAsString;
        }
    }

    return value.toWTFString(exec);
}

static WTF::String getDirMessageForObject(JSC::ExecState* exec, JSC::JSValue object) {
    JSC::JSObject* jsObject = object.getObject();
    JSC::PropertyNameArray propertyNames(&exec->vm(), JSC::PropertyNameMode::Strings, JSC::PrivateSymbolMode::Include);
    JSC::EnumerationMode mode;
    jsObject->getPropertyNames(jsObject, exec, propertyNames, mode);
    StringBuilder output;

    for (JSC::PropertyName propertyName : propertyNames) {
        JSC::JSValue value = object.get(exec, propertyName);
        output.append(WTF::String(propertyName.uid()));
        output.append(": ");
        output.append(getStringRepresentationOfObject(exec, value));
        output.append("\n");
    }

    return output.toString();
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

void GlobalObjectConsoleClient::messageWithTypeAndLevel(MessageType type, MessageLevel level, JSC::ExecState* exec, Ref<Inspector::ScriptArguments>&& arguments) {

    String message = this->createMessageFromArguments(type, exec, arguments.copyRef());
    if (GlobalObjectConsoleClient::logToSystemConsole()) {
        GlobalObjectConsoleClient::printConsoleMessage(MessageSource::ConsoleAPI, type, level, message, WTF::emptyString(), 0, 0);
    }

    std::unique_ptr<Inspector::ConsoleMessage> consoleMessage = std::make_unique<Inspector::ConsoleMessage>(MessageSource::ConsoleAPI, type, level, message, WTF::emptyString(), 0, 0, exec);
    this->addMessageToAgentsConsole(WTFMove(consoleMessage), WTFMove(arguments), exec);
}

void GlobalObjectConsoleClient::count(JSC::ExecState* exec, Ref<Inspector::ScriptArguments>&& arguments) {
    m_consoleAgent->count(exec, WTFMove(arguments));
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

void GlobalObjectConsoleClient::time(JSC::ExecState* exec, const String& title) {
    std::unique_ptr<Inspector::ConsoleMessage> startMsg = m_consoleAgent->startTiming(title);
    if (startMsg) {
        ConsoleClient::printConsoleMessage(startMsg->source(), startMsg->type(), startMsg->level(), startMsg->message(), startMsg->url(), startMsg->line(), startMsg->column());

        this->addMessageToAgentsConsole(WTFMove(startMsg));
    }
}

void GlobalObjectConsoleClient::timeEnd(JSC::ExecState* exec, const String& title) {
    Ref<Inspector::ScriptCallStack> callStack(Inspector::createScriptCallStackForConsole(exec, 1));
    std::unique_ptr<Inspector::ConsoleMessage> stopMsg = m_consoleAgent->stopTiming(title, WTFMove(callStack));
    if (stopMsg) {
        ConsoleClient::printConsoleMessage(stopMsg->source(), stopMsg->type(), stopMsg->level(), stopMsg->message(), stopMsg->url(), stopMsg->line(), stopMsg->column());
        this->addMessageToAgentsConsole(WTFMove(stopMsg));
    }
}

void GlobalObjectConsoleClient::timeStamp(JSC::ExecState*, Ref<Inspector::ScriptArguments>&&) {
    // FIXME: JSContext inspection needs a timeline.
    warnUnimplemented("console.timeStamp"_s);
}

void GlobalObjectConsoleClient::warnUnimplemented(const String& method) {
    String message = method + " is currently ignored in JavaScript context inspection.";
    std::unique_ptr<Inspector::ConsoleMessage> consoleMessage = std::make_unique<Inspector::ConsoleMessage>(MessageSource::ConsoleAPI, MessageType::Log, MessageLevel::Warning, message);
    this->addMessageToAgentsConsole(WTFMove(consoleMessage));
}

WTF::String GlobalObjectConsoleClient::getDirMessage(JSC::ExecState* exec, JSC::JSValue argument) {
    StringBuilder output;

    if (argument.isObject()) {
        output.append("\n");
        output.append("==== object dump start ====");
        output.append("\n");
        output.append(getDirMessageForObject(exec, argument));
        output.append("==== object dump end ====");
        output.append("\n");
    } else {
        output.append(argument.toWTFString(exec));
    }

    return output.toString();
}

void GlobalObjectConsoleClient::record(ExecState*, Ref<Inspector::ScriptArguments>&&) {
}

void GlobalObjectConsoleClient::recordEnd(ExecState*, Ref<Inspector::ScriptArguments>&&) {
}

WTF::String GlobalObjectConsoleClient::createMessageFromArguments(MessageType type, JSC::ExecState* exec, Ref<Inspector::ScriptArguments>&& arguments) {

    RefPtr<Inspector::ScriptCallStack> callStack(Inspector::createScriptCallStackForConsole(exec, 1));
    const Inspector::ScriptCallFrame& lastCaller = callStack->size() > 0 ? callStack->at(0) : Inspector::ScriptCallFrame("", "", JSC::noSourceID, 0, 0);

    StringBuilder builder;

    if (!lastCaller.sourceURL().isEmpty()) {
        appendURLAndPosition(builder, lastCaller.sourceURL(), lastCaller.lineNumber(), lastCaller.columnNumber());
        builder.appendLiteral(": ");
    }

    if (type == JSC::MessageType::Dir) {
        // don't enumerate args as console.dir supports only one argument
        JSC::JSValue argumentValue = arguments->argumentAt(0);
        builder.append(this->getDirMessage(exec, argumentValue));
    } else {
        for (size_t i = 0; i < arguments->argumentCount(); ++i) {
            String argAsString = arguments->argumentAt(i).toWTFString(arguments->globalState());
            if (i > 0) {
                builder.append(' ');
            }
            if (argAsString.contains("[object Object]")) {
                builder.append(smartStringifyObject(exec, arguments->argumentAt(i)));
            } else {
                builder.append(argAsString);
            }
        }
    }
    return builder.toString();
}

void GlobalObjectConsoleClient::addMessageToAgentsConsole(std::unique_ptr<Inspector::ConsoleMessage>&& message) {
    m_logAgent->addMessageToConsole(std::make_unique<Inspector::ConsoleMessage>(*message.get()));

    m_consoleAgent->addMessageToConsole(WTFMove(message));
}

void GlobalObjectConsoleClient::addMessageToAgentsConsole(std::unique_ptr<Inspector::ConsoleMessage>&& message, Ref<Inspector::ScriptArguments>&& arguments, JSC::ExecState* exec) {

    auto consoleMessage = std::make_unique<Inspector::ConsoleMessage>(message->source(), message->type(), message->level(),
                                                                      message->message(), WTFMove(arguments), exec);

    m_logAgent->addMessageToConsole(WTFMove(message));
    m_consoleAgent->addMessageToConsole(WTFMove(consoleMessage));
}
} // namespace NativeScript
