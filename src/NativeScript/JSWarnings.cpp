//
//  JSWarnings.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 9/16/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include <JavaScriptCore/ConsoleClient.h>
#include <JavaScriptCore/JSGlobalObjectConsoleClient.h>
#include <JavaScriptCore/ScriptArguments.h>
#include <JavaScriptCore/ScriptValue.h>

namespace NativeScript {
using namespace JSC;

void warn(ExecState* execState, const WTF::String& message) {
    bool restoreLogToSystemConsole = false;
    if (!execState->vm().topCallFrame && Inspector::JSGlobalObjectConsoleClient::logToSystemConsole()) {
        WTFLogAlways("CONSOLE WARN %s", message.utf8().data());
        Inspector::JSGlobalObjectConsoleClient::setLogToSystemConsole(false);
        restoreLogToSystemConsole = true;
    } else {
        WTF::Vector<Deprecated::ScriptValue> arguments{ Deprecated::ScriptValue(execState->vm(), jsString(execState, message)) };
        execState->lexicalGlobalObject()->consoleClient()->logWithLevel(execState, Inspector::ScriptArguments::create(execState, arguments), MessageLevel::Warning);
    }

    if (restoreLogToSystemConsole) {
        Inspector::JSGlobalObjectConsoleClient::setLogToSystemConsole(true);
    }
}
}