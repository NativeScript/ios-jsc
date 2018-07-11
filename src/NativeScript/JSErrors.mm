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
#include <sstream>

#import "JSWarnings.h"
#import "JSWorkerGlobalObject.h"
#import "TNSRuntime+Diagnostics.h"
#import "TNSRuntime+Inspector.h"
#import "TNSRuntime+Private.h"
#include "inspector/GlobalObjectConsoleClient.h"
#include "inspector/GlobalObjectInspectorController.h"
#include <JavaScriptCore/APICast.h>
#include <JavaScriptCore/Interpreter.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>

static TNSUncaughtErrorHandler uncaughtErrorHandler;
void TNSSetUncaughtErrorHandler(TNSUncaughtErrorHandler handler) {
    uncaughtErrorHandler = handler;
}

namespace NativeScript {

using namespace WTF;
using namespace JSC;
using namespace Inspector;

void reportErrorIfAny(JSC::ExecState* execState, JSC::CatchScope& scope) {
    if (JSC::Exception* exception = scope.exception()) {
        NSMutableDictionary* threadData = [[NSThread currentThread] threadDictionary];
        NSNumber* zeroRecursionForThread = threadData[NS_EXCEPTION_SCOPE_ZERO_RECURSION_KEY];
        unsigned zeroRecursion = zeroRecursionForThread != nil ? [zeroRecursionForThread unsignedIntValue] : 0;
        NativeScript::GlobalObject* globalObject = JSC::jsCast<GlobalObject*>(execState->lexicalGlobalObject());

        bool treatExceptionsAsUncaught = scope.recursionDepth() == zeroRecursion
                                         || globalObject->isUIApplicationMainAtTopOfCallstack();

        if (treatExceptionsAsUncaught) {
            scope.clearException();
            reportFatalErrorBeforeShutdown(execState, exception);
        }
    }
}

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
        NSLog(@"***** %s *****\n", closingMessage.operator const char*());

        NSLog(@"Native stack trace:");
        WTFReportBacktrace();

        NSLog(@"JavaScript stack trace:");
        Ref<Inspector::ScriptCallStack> callStack = Inspector::createScriptCallStackFromException(execState, exception, Inspector::ScriptCallStack::maxCallStackSizeToCapture);
        dumpJsCallStack(callStack.get());

        NSLog(@"JavaScript error:");
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

void dumpExecJsCallStack(ExecState* execState) {
    dumpJsCallStack(createScriptCallStack(execState).get());
}

void dumpJsCallStack(const Inspector::ScriptCallStack& frames) {
    for (size_t i = 0; i < frames.size(); ++i) {
        std::stringstream callstackLine;
        Inspector::ScriptCallFrame frame = frames.at(i);
        callstackLine << std::setw(4) << std::left << std::setfill(' ') << (i + 1) << frame.functionName().utf8().data() << "@" << frame.sourceURL().utf8().data();
        if (frame.lineNumber() && frame.columnNumber()) {
            callstackLine << ":" << frame.lineNumber() << ":" << frame.columnNumber();
        }
        NSLog(@"%s", callstackLine.str().c_str());
    }
}
}
