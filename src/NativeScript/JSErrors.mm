//
//  JSErrors.mm
//  NativeScript
//
//  Created by Jason Zhekov on 2/26/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "JSErrors.h"

#include <iomanip>
#include <iostream>

#import "JSWarnings.h"
#import "TNSRuntime+Diagnostics.h"
#import "TNSRuntime+Inspector.h"
#import "TNSRuntime+Private.h"
#include "inspector/GlobalObjectConsoleClient.h"
#include "inspector/GlobalObjectInspectorController.h"
#include <JavaScriptCore/APICast.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>

static TNSUncaughtErrorHandler uncaughtErrorHandler;
void TNSSetUncaughtErrorHandler(TNSUncaughtErrorHandler handler) {
    uncaughtErrorHandler = handler;
}

namespace NativeScript {

using namespace JSC;

static void handleJsUncaughtErrorCallback(ExecState* execState, Exception* exception) {
    JSValue callback = execState->lexicalGlobalObject()->get(execState, Identifier::fromString(execState, "__onUncaughtError")); // Keep in sync with TNSExceptionHandler.h

    CallData callData;
    CallType callType = getCallData(callback, callData);
    if (callType == CallTypeNone) {
        return;
    }

    MarkedArgumentBuffer uncaughtErrorArguments;
    uncaughtErrorArguments.append(exception->value());

    WTF::NakedPtr<Exception> outException;
    call(execState, callback, callType, callData, jsUndefined(), uncaughtErrorArguments, outException);

    if (outException) {
        warn(execState, outException->value().toWTFString(execState));
    }
}

void reportFatalErrorBeforeShutdown(ExecState* execState, Exception* exception) {
    GlobalObject* globalObject = static_cast<GlobalObject*>(execState->lexicalGlobalObject());

    handleJsUncaughtErrorCallback(execState, exception);

    if (uncaughtErrorHandler) {
        uncaughtErrorHandler(toRef(execState), toRef(execState, exception->value()));
    }

    WTF::ASCIILiteral closingMessage("Fatal JavaScript exception - application has been terminated.");

    if (globalObject->debugger()) {
        warn(execState, closingMessage);

        ASSERT(!globalObject->inspectorController().includesNativeCallStackWhenReportingExceptions());
        globalObject->inspectorController().reportAPIException(execState, exception);

        while (true) {
            CFRunLoopRunInMode((CFStringRef)TNSInspectorRunLoopMode, 0.1, false);
        }
    } else {
        std::cerr << "***** " << closingMessage << " *****\n";

        std::cerr << "Native stack trace:\n";
        WTFReportBacktrace();

        std::cerr << "JavaScript stack trace:\n";
        RefPtr<Inspector::ScriptCallStack> callStack = Inspector::createScriptCallStackFromException(execState, exception, Inspector::ScriptCallStack::maxCallStackSizeToCapture);
        for (size_t i = 0; i < callStack->size(); ++i) {
            Inspector::ScriptCallFrame frame = callStack->at(i);
            std::cerr << std::setw(4) << std::left << std::setfill(' ') << (i + 1) << frame.functionName().utf8().data() << "@" << frame.sourceURL().utf8().data();
            if (frame.lineNumber() && frame.columnNumber()) {
                std::cerr << ":" << frame.lineNumber() << ":" << frame.columnNumber();
            }
            std::cerr << "\n";
        }

        std::cerr << "JavaScript error:\n";
        // System logs are disabled in release app builds, but we want the error to be printed in crash logs
        GlobalObjectConsoleClient::setLogToSystemConsole(true);
        globalObject->inspectorController().reportAPIException(execState, exception);

        *(int*)(uintptr_t)0xDEADDEAD = 0;
        __builtin_trap();
    }
}
}