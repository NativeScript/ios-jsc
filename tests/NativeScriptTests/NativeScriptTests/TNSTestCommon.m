//
//  TNSTestCommon.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/21/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSTestCommon.h"

#import <JavaScriptCore/JavaScript.h>
#import <NativeScript/NativeScript.h>
#import "Utilities.h"

#include <dispatch/dispatch.h>

static NSMutableString *TNSTestOutput;

NSMutableString *TNSGetOutput() {
    if (TNSTestOutput == nil) {
        TNSTestOutput = [NSMutableString new];
    }

    return TNSTestOutput;
}

void TNSLog(NSString *message) {
    [TNSGetOutput() appendString:message];
}

void TNSClearOutput() {
    TNSTestOutput = nil;
}

void TNSSaveResults(NSString *result) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [[[fileManager URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask] lastObject] path];
    NSString *path = [[documentsDirectory stringByAppendingPathComponent:@"junit-result"] stringByAppendingPathExtension:@"xml"];

    [fileManager removeItemAtPath:path
                            error:nil];

    NSError *error = nil;
    [result writeToFile:path
             atomically:YES
               encoding:NSUTF8StringEncoding
                  error:&error];
    if (error) {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:error.localizedDescription
                                     userInfo:nil];
    }
}

void TNSRunScript(NSString *script) {
    __block BOOL hasError = NO;

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        TNSRuntime *runtime = [[TNSRuntime alloc] initWithApplicationPath:NSBundle.mainBundle.bundlePath];
        TNSRuntimeInspector.logsToSystemConsole = YES;
        JSValueRef error = NULL;
        JSStringRef scriptRef = JSStringCreateWithUTF8CString(script.UTF8String);
        JSEvaluateScript(runtime.globalContext, scriptRef, NULL, NULL, 0, &error);
        JSStringRelease(scriptRef);
        hasError = !!error;
    });

    assert(!hasError);
}
