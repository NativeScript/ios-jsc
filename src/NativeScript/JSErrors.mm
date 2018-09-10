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
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>

static TNSUncaughtErrorHandler uncaughtErrorHandler;
void TNSSetUncaughtErrorHandler(TNSUncaughtErrorHandler handler) {
    uncaughtErrorHandler = handler;
}

namespace NativeScript {

using namespace JSC;

void reportErrorIfAny(JSC::ExecState* execState, JSC::CatchScope& scope) {
    if (JSC::Exception* exception = scope.exception()) {
        scope.clearException();
        id discardExceptionsValue = [[TNSRuntime current] appPackageJson][@"discardUncaughtJsExceptions"];
        bool discardExceptions = [discardExceptionsValue boolValue];

        reportFatalErrorBeforeShutdown(execState, exception, true, discardExceptions);
    }
}

void reportFatalErrorBeforeShutdown(ExecState* execState, Exception* exception, bool callUncaughtErrorCallbacks, bool dontCrash) {
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

        std::stringstream jsCallstack;
        RefPtr<Inspector::ScriptCallStack> callStack = Inspector::createScriptCallStackFromException(execState, exception, Inspector::ScriptCallStack::maxCallStackSizeToCapture);
        for (size_t i = 0; i < callStack->size(); ++i) {
            Inspector::ScriptCallFrame frame = callStack->at(i);
            jsCallstack << std::setw(4) << std::left << std::setfill(' ') << (i + 1) << frame.functionName().utf8().data() << "@" << frame.sourceURL().utf8().data();
            if (frame.lineNumber() && frame.columnNumber()) {
                jsCallstack << ":" << frame.lineNumber() << ":" << frame.columnNumber();
            }
            jsCallstack << std::endl;
        }

        NSLog(@"JavaScript stack trace:");
        NSLog(@"%s", jsCallstack.str().c_str());

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
            if (dontCrash) {
                NSLog(@"NativeScript discarding uncaught JS exception!");
            } else {
                String message = exception->value().toString(globalObject->globalExec())->value(globalObject->globalExec());
                NSException* objcException = [NSException exceptionWithName:[NSString stringWithFormat:@"NativeScript encountered a fatal error: %s\n at \n%s",
                                                                                                       message.utf8().data(),
                                                                                                       jsCallstack.str().c_str()]
                                                                     reason:nil
                                                                   userInfo:nil];
                @throw objcException;
            }
        }
    }
}
}
