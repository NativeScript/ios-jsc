//
//  TNSExceptionHandler.h
//  NativeScript
//
//  Created by Jason Zhekov on 2/1/16.
//  Copyright © 2016 Telerik. All rights reserved.
//

#ifndef TNSExceptionHandler_h
#define TNSExceptionHandler_h

#import <JavaScriptCore/JavaScriptCore.h>
#import <NativeScript.h>

TNSRuntime* runtime;

static NSUncaughtExceptionHandler* oldExceptionHandler = NULL;

static void TNSObjectiveCUncaughtExceptionHandler(NSException* currentException) {
    JSGlobalContextRef context = runtime.globalContext;
    JSObjectRef globalObject = JSContextGetGlobalObject(context);

    JSStringRef uncaughtPropertyName = JSStringCreateWithUTF8CString("__onUncaughtError"); // Keep in sync with JSErrors.mm
    JSValueRef uncaughtCallback = JSObjectGetProperty(context, globalObject, uncaughtPropertyName, NULL);
    JSStringRelease(uncaughtPropertyName);

    if (!JSValueIsUndefined(context, uncaughtCallback)) {
        JSStringRef reason = JSStringCreateWithUTF8CString(currentException.reason.UTF8String);
        JSObjectRef error = JSObjectMakeError(
            context, 1, (JSValueRef[]){ JSValueMakeString(context, reason) }, NULL);
        JSStringRelease(reason);

        JSValueRef wrappedException = [runtime convertObject:currentException];
        JSStringRef nativeExceptionPropertyName = JSStringCreateWithUTF8CString("nativeException");
        JSObjectSetProperty(context, error, nativeExceptionPropertyName,
                            wrappedException, kJSPropertyAttributeNone, NULL);
        JSStringRelease(nativeExceptionPropertyName);

        JSValueRef callError = NULL;
        JSObjectCallAsFunction(context, (JSObjectRef)uncaughtCallback, NULL, 1,
                               (JSValueRef[]){ error }, &callError);
        if (callError) {
            JSStringRef callErrorMessage = JSValueToStringCopy(context, callError, NULL);
            NSLog(@"Error executing uncaught error handler: %@",
                  CFBridgingRelease(JSStringCopyCFString(CFAllocatorGetDefault(),
                                                         callErrorMessage)));
            JSStringRelease(callErrorMessage);
        }
    }

    NSLog(@"*** JavaScript call stack:\n(\n%@\n)", [runtime getCurrentStack]);

    if (oldExceptionHandler) {
        oldExceptionHandler(currentException);
    }
}

static void TNSInstallExceptionHandler() {
    oldExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(TNSObjectiveCUncaughtExceptionHandler);
}

#endif /* TNSExceptionHandler_h */
