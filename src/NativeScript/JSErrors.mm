//
//  JSErrors.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 2/26/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "JSErrors.h"

#include <JavaScriptCore/JSGlobalObjectInspectorController.h>
#include <JavaScriptCore/APICast.h>
#import "TNSRuntime+Private.h"
#import "TNSRuntime+Inspector.h"
#import "TNSRuntime+Diagnostics.h"

static TNSUncaughtErrorHandler uncaughtErrorHandler;
void TNSSetUncaughtErrorHandler(TNSUncaughtErrorHandler handler) {
    uncaughtErrorHandler = handler;
}

namespace NativeScript {

using namespace JSC;

void reportFatalErrorBeforeShutdown(ExecState* execState, JSValue error) {
    GlobalObject* globalObject = static_cast<GlobalObject*>(execState->lexicalGlobalObject());
    globalObject->inspectorController().reportAPIException(execState, error);

    if (uncaughtErrorHandler) {
        uncaughtErrorHandler(toRef(execState), toRef(execState, error));
    }

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