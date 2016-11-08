//
//  TNSTestCommon.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/21/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSTestCommon.h"

#ifdef DEBUG
bool TNSIsConfigurationDebug = true;
#else
bool TNSIsConfigurationDebug = false;
#endif

static NSMutableString* TNSTestOutput;

// TODO: Thread safe
NSString* TNSGetOutput() {
    if (TNSTestOutput == nil) {
        TNSTestOutput = [NSMutableString new];
    }

    return TNSTestOutput;
}

void TNSLog(NSString* message) {
    [(NSMutableString*)TNSGetOutput() appendFormat:@"%@", message];
}

void TNSClearOutput() {
    TNSTestOutput = nil;
}

void TNSSaveResults(NSString* result) {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* documentsDirectory = [[[fileManager URLsForDirectory:NSDocumentDirectory
                                                         inDomains:NSUserDomainMask] lastObject] path];
    NSString* path = [[documentsDirectory stringByAppendingPathComponent:@"junit-result"] stringByAppendingPathExtension:@"xml"];

    [fileManager removeItemAtPath:path
                            error:nil];

    NSError* error = nil;
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
