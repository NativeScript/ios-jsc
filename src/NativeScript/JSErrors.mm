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
#import "JSWorkerGlobalObject.h"
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

void reportFatalErrorBeforeShutdown(ExecState* execState, Exception* exception, bool callUncaughtErrorCallbacks) {
    GlobalObject* globalObject = static_cast<GlobalObject*>(execState->lexicalGlobalObject());

    NakedPtr<Exception> errorCallbackException;
    bool errorCallbackResult = false;
    if (callUncaughtErrorCallbacks) {
        errorCallbackResult = globalObject->callJsUncaughtErrorCallback(execState, exception, errorCallbackException);
        if (uncaughtErrorHandler) {
            uncaughtErrorHandler(toRef(execState), toRef(execState, exception->value()));
        }
    }

    JSWorkerGlobalObject* workerGlobalObject = jsDynamicCast<JSWorkerGlobalObject*>(globalObject->vm(), globalObject);
    bool isWorker = workerGlobalObject != nullptr;

    WTF::ASCIILiteral closingMessage(isWorker ? "Fatal JavaScript exception on worker thread - worker thread has been terminated." : "Fatal JavaScript exception - application has been terminated.");

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

        if (isWorker) {
            if (!errorCallbackResult) {
                const Inspector::ScriptCallFrame* frame = callStack->firstNonNativeCallFrame();
                String message = exception->value().toString(globalObject->globalExec())->value(globalObject->globalExec());
                if (frame != nullptr) {
                    workerGlobalObject->uncaughtErrorReported(message, frame->sourceURL(), frame->lineNumber(), frame->columnNumber());
                } else {
                    workerGlobalObject->uncaughtErrorReported(message);
                }
                if (errorCallbackException)
                    reportFatalErrorBeforeShutdown(execState, errorCallbackException, false);
            }
        } else {
            *(int*)(uintptr_t)0xDEADDEAD = 0;
            __builtin_trap();
        }
    }
}
}
