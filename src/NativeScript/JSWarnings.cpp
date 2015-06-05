//
//  JSWarnings.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 9/16/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include <JavaScriptCore/ScriptValue.h>
#include <JavaScriptCore/ScriptArguments.h>
#include <JavaScriptCore/ConsoleClient.h>

namespace NativeScript {
using namespace JSC;

void warn(ExecState* execState, const WTF::String& message) {
    WTF::Vector<Deprecated::ScriptValue> arguments{ Deprecated::ScriptValue(execState->vm(), jsString(execState, message)) };
    execState->lexicalGlobalObject()->consoleClient()->logWithLevel(execState, Inspector::ScriptArguments::create(execState, arguments), MessageLevel::Warning);
}
}