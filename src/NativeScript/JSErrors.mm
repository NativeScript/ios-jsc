//
//  JSErrors.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 2/26/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "JSErrors.h"

#include "inspector/GlobalObjectInspectorController.h"
#include <JavaScriptCore/APICast.h>
#import "TNSRuntime+Private.h"
#import "TNSRuntime+Inspector.h"
#import "TNSRuntime+Diagnostics.h"
#import "JSWarnings.h"

static TNSUncaughtErrorHandler uncaughtErrorHandler;
void TNSSetUncaughtErrorHandler(TNSUncaughtErrorHandler handler) {
    uncaughtErrorHandler = handler;
}

namespace NativeScript {

using namespace JSC;

static void handleJsUncaughtErrorCallback(ExecState* execState, Exception* exception) {
    JSValue callback = execState->lexicalGlobalObject()->get(execState, Identifier::fromString(execState, "__onUncaughtError"));

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

    globalObject->inspectorController().reportAPIException(execState, exception);

    if (globalObject->debugger()) {
        warn(execState, WTF::ASCIILiteral("Fatal exception - application has been terminated."));
        while (true) {
            CFRunLoopRunInMode((CFStringRef)TNSInspectorRunLoopMode, 0.1, false);
        }
    } else {
        WTFCrash();
    }
}
}