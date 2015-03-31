//
//  main.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 7/29/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#import <JavaScriptCore/JavaScript.h>
#import <NativeScript/NativeScript.h>
#import "Utilities.h"
#import "TNSTestCases.h"

#if DEBUG
#include <TNSDebugging/TNSDebugging.h>
id debuggingServer;
#endif

static void PrintError(JSContextRef ctx, JSValueRef error) {
    NSLog(@"%@", toString(ctx, error));
    JSStringRef stackRef = JSStringCreateWithUTF8CString("stack");
    NSLog(@"Stack: \n%@", toString(ctx, JSObjectGetProperty(ctx, (JSObjectRef)error, stackRef, 0)));
    JSStringRelease(stackRef);
}

int main(int argc, char *argv[]) {
    NSLog(@"Application Start!");

    // this cheats the linker into including those symbols into the test build.
    if (argc == -256) {
        TNSGetOutput();
        TNSLog(nil);
        TNSClearOutput();
        TNSRunScript(nil);
        TNSSaveResults(nil);

        CFArrayCreateWithString(nil);
        NSLog(@"%@", TNSConstant);

        TNSFunctionWithCFTypeRefArgument(nil);
        TNSFunctionWithSimpleCFTypeRefReturn();
        TNSFunctionWithCreateCFTypeRefReturn();

        functionWithChar(0);
        functionWithShort(0);
        functionWithInt(0);
        functionWithLong(0);
        functionWithLongLong(0);
        functionWithUChar(0);
        functionWithUShort(0);
        functionWithUInt(0);
        functionWithULong(0);
        functionWithULongLong(0);
        functionWithFloat(0);
        functionWithDouble(0);
        functionWithBool(0);
        functionWithBool2(0);
        functionWithBool3(0);
        functionWithSelector(0);
        functionWithClass(Nil);
        functionWithProtocol(nil);
        functionWithNull(nil);
        functionWithUnichar(0);

        functionWith_VoidPtr(0);
        functionWith_BoolPtr(NULL);
        functionWithUCharPtr(NULL);
        functionWithUShortPtr(NULL);
        functionWithUIntPtr(NULL);
        functionWithULongPtr(NULL);
        functionWithULongLongPtr(NULL);
        functionWithCharPtr(NULL);
        functionWithShortPtr(NULL);
        functionWithIntPtr(NULL);
        functionWithLongPtr(NULL);
        functionWithLongLongPtr(NULL);
        functionWithFloatPtr(NULL);
        functionWithDoublePtr(NULL);
        functionWithStructPtr(NULL);
        functionWithIdPointer(NULL);
        functionWithIntIncompleteArray(NULL);
        functionWithIntConstantArray(NULL);
        functionWithIntConstantArray2(NULL);
        functionWithDoubleCharPtr(NULL);
        functionWithNullPointer(NULL);
        functionWithIdToVoidPointer(NULL);
        functionReturningFunctionPtrAsVoidPtr();

        functionWhichReturnsSimpleFunctionPointer();
        functionWithSimpleFunctionPointer(NULL);
        functionWithComplexFunctionPointer(NULL);
    }

    @autoreleasepool {
        TNSRuntime *runtime = [[TNSRuntime alloc] initWithApplicationPath:NSBundle.mainBundle.bundlePath];
        TNSRuntimeInspector.logsToSystemConsole = YES;

        JSValueRef exception = NULL;
        JSGlobalContextRef contextRef = runtime.globalContext;

#if DEBUG
        debuggingServer = [runtime enableDebuggingWithName:[NSBundle mainBundle].bundleIdentifier];
#endif

        TNSSetUncaughtErrorHandler(&PrintError);

        if (!getenv("STANDALONE_TEST")) {
            [runtime executeModule:@"./bootstrap"];
        } else {
            NSString *script = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Test"
                                                                                                  ofType:@"js"
                                                                                             inDirectory:@"app"]
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil];

            JSStringRef scriptRef = JSStringCreateWithUTF8CString(script.UTF8String);
            JSStringRef sourceURLRef = JSStringCreateWithUTF8CString("Test.js");
            JSObjectRef globalObjectRef = JSContextGetGlobalObject(contextRef);
            JSEvaluateScript(runtime.globalContext, scriptRef, globalObjectRef, sourceURLRef, 0, &exception);
            JSStringRelease(sourceURLRef);
            JSStringRelease(scriptRef);

            NSLog(@"%@", TNSGetOutput());
        }

        if (exception) {
            PrintError(runtime.globalContext, exception);
            return -1;
        }

        return 0;
    }
}
