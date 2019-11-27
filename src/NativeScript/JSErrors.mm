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
#include <JavaScriptCore/interpreter/Interpreter.h>
#include <JavaScriptCore/runtime/StackFrame.h>

static TNSUncaughtErrorHandler uncaughtErrorHandler;
void TNSSetUncaughtErrorHandler(TNSUncaughtErrorHandler handler) {
    uncaughtErrorHandler = handler;
}

namespace NativeScript {

using namespace WTF;
using namespace JSC;
using namespace Inspector;

bool setStackTraceProperty(JSC::ExecState* execState, JSC::Exception* exception, std::string stackTraceContent) {
    auto error = exception->value().toObject(execState);

    Identifier stackTraceName = Identifier::fromString(execState, "stackTrace");
    VM* vm = &execState->vm();
    JSString* stackTrace = jsString(vm, stackTraceContent.c_str());

    auto result = error->putDirect(*vm, stackTraceName, JSValue(stackTrace));

    return result;
}

/**
 * \brief Gets the native callstack from WTFGetBacktrace function.
 */
std::string getNativeStackTrace(JSC::ExecState* execState, JSC::Exception* exception) {
    Ref<Inspector::ScriptCallStack> nativeCallStack = ScriptCallStack::create();

    static const int framesToShow = 32;
    static const int framesToSkip = 4; // WTFGetBacktrace, getNativeStackTrace, setStackTrace, reportErrorIfAny.

    void* samples[framesToShow + framesToSkip];
    int frames = framesToShow + framesToSkip;
    WTFGetBacktrace(samples, &frames);

    void** stack = samples + framesToSkip;
    int size = frames - framesToSkip;
    for (int i = 0; i < size; ++i) {
        auto demangled = StackTrace::demangle(stack[i]);
        if (demangled) {
            nativeCallStack.get().append(ScriptCallFrame(demangled->demangledName() ? demangled->demangledName() : demangled->mangledName(), "[native code]"_s, noSourceID, 0, 0));
        } else {
            nativeCallStack.get().append(ScriptCallFrame("?"_s, "[native code]"_s, noSourceID, 0, 0));
        }
    }

    return getCallStack(nativeCallStack);
}

Boolean setStackTrace(JSC::ExecState* execState, JSC::Exception* exception) {
    Ref<Inspector::ScriptCallStack> jsCallStack = Inspector::createScriptCallStackFromException(execState, exception, Inspector::ScriptCallStack::maxCallStackSizeToCapture);
    std::string jsStackTrace = getCallStack(jsCallStack.get());

    std::string nativeStackTrace = getNativeStackTrace(execState, exception);

    return setStackTraceProperty(execState, exception, "JS:\n" + jsStackTrace + "\nNative:\n" + nativeStackTrace);
}

void reportErrorIfAny(JSC::ExecState* execState, JSC::CatchScope& scope) {
    if (JSC::Exception* exception = scope.exception()) {
        setStackTrace(execState, exception);
        NSMutableDictionary* threadData = [[NSThread currentThread] threadDictionary];
        NSNumber* zeroRecursionForThread = threadData[NS_EXCEPTION_SCOPE_ZERO_RECURSION_KEY];
        unsigned zeroRecursion = zeroRecursionForThread != nil ? [zeroRecursionForThread unsignedIntValue] : 0;
        NativeScript::GlobalObject* globalObject = JSC::jsCast<GlobalObject*>(execState->lexicalGlobalObject());

        bool treatExceptionsAsUncaught = scope.recursionDepth() == zeroRecursion
                                         || globalObject->isUIApplicationMainAtTopOfCallstack();

        if (treatExceptionsAsUncaught) {
            id discardExceptionsValue = [[TNSRuntime current] appPackageJson][@"discardUncaughtJsExceptions"];
            bool discardExceptions = [discardExceptionsValue boolValue];
            scope.clearException();
            if (discardExceptions) {
                reportDiscardedError(execState, globalObject, exception);
            } else {
                reportFatalErrorBeforeShutdown(execState, exception, true);
            }
        }
    }
}

void logJsException(ExecState* execState, GlobalObject* globalObject, NSString* message, Exception* exception) {
    NSLog(@"%@", message);
    // System logs are disabled in release app builds, but we want the error to be printed in crash logs
    GlobalObjectConsoleClient::setLogToSystemConsole(true);
    globalObject->inspectorController().reportAPIException(execState, exception);
}

void reportDiscardedError(ExecState* execState, GlobalObject* globalObject, Exception* exception) {
    NakedPtr<Exception> errorCallbackException;
    globalObject->callJsDiscardedErrorCallback(execState, exception, errorCallbackException);
    NSLog(@"NativeScript discarding uncaught JS exception!");
    if (errorCallbackException) {
        logJsException(execState, globalObject, @"Error executing __onDiscardedError callback:", errorCallbackException);
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
    // The CLI depends on `Fatal JavaScript exception - application has been terminated` in order to handle app crashed.
    // If we update this message, we also have to update it in the CLI.
    WTF::ASCIILiteral closingMessage(isWorker ? "Fatal JavaScript exception on worker thread - worker thread has been terminated."_s : "Fatal JavaScript exception - application has been terminated."_s);

    NSLog(@"***** %s *****\n", closingMessage.operator const char*());

    NSLog(@"Native stack trace:");
    WTFReportBacktrace();

    Ref<Inspector::ScriptCallStack> callStack = Inspector::createScriptCallStackFromException(execState, exception, Inspector::ScriptCallStack::maxCallStackSizeToCapture);
    NSLog(@"JavaScript stack trace:");
    std::string jsCallstack = dumpJsCallStack(callStack.get());

    logJsException(execState, globalObject, @"JavaScript error:", exception);

    if (isWorker) {
        if (!errorCallbackResult) {
            const Inspector::ScriptCallFrame* frame = callStack->firstNonNativeCallFrame();
            String message = exception->value().toString(globalObject->globalExec())->value(globalObject->globalExec());
            if (frame != nullptr) {
                workerGlobalObject->uncaughtErrorReported(message, frame->sourceURL(), frame->lineNumber(), frame->columnNumber());
            } else {
                workerGlobalObject->uncaughtErrorReported(message);
            }
            if (errorCallbackException) {
                reportFatalErrorBeforeShutdown(execState, errorCallbackException, false);
            }
        }
    } else {
        if (errorCallbackException) {
            // log first any error coming from execution of UncaughtErrorCallback
            logJsException(execState, globalObject, @"Error executing __onUncaughtError callback:", errorCallbackException);
        }

        if (globalObject->debugger()) {
            warn(execState, closingMessage);

            warn(execState, "Active debugger session detected. Blocking app to keep the session alive.");
            JSLock::DropAllLocks dropAllLocks(execState);
            while (globalObject->debugger()) {
                CFRunLoopRunInMode((CFStringRef)TNSInspectorRunLoopMode, 0.1, false);
            }
        }
        
        id discardExceptionsValue = [[TNSRuntime current] appPackageJson][@"discardUncaughtJsExceptions"];
        bool discardExceptions = [discardExceptionsValue boolValue];
        if (!discardExceptions) {
            String message = exception->value().toString(globalObject->globalExec())->value(globalObject->globalExec());
            NSException* objcException = [NSException exceptionWithName:[NSString stringWithFormat:@"NativeScript encountered a fatal error: %s\n at \n%s",
                                                                                                   message.utf8().data(),
                                                                                                   jsCallstack.c_str()]
                                                                 reason:nil
                                                               userInfo:@{ @"sender": @"reportFatalErrorBeforeShutdown" }];
            @throw objcException;
        }
    }
}

void dumpExecJsCallStack(ExecState* execState) {
    dumpJsCallStack(createScriptCallStack(execState).get());
}

std::string getExecJsCallStack(ExecState* execState) {
    return getCallStack(createScriptCallStack(execState).get());
}

std::string getCallStack(const Inspector::ScriptCallStack& frames) {
    std::stringstream resultCallstack;
    for (size_t i = 0; i < frames.size(); ++i) {
        Inspector::ScriptCallFrame frame = frames.at(i);
        auto frameString = StackFrame::formatStackFrame(frame.functionName(), frame.sourceURL(), frame.lineNumber(), frame.columnNumber());
        resultCallstack << (i > 0 ? "at " : "") << frameString.utf8().data();
        resultCallstack << std::endl;
    }

    return resultCallstack.str();
}

std::string dumpJsCallStack(const Inspector::ScriptCallStack& frames) {
    std::string jsCallstack = getCallStack(frames);

    NSLog(@"%s", jsCallstack.c_str());

    return jsCallstack;
}
} // namespace NativeScript
