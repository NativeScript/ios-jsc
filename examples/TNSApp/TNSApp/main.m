//
//  main.m
//  TNSApp
//
//  Created by Panayot Cankov on 7/30/14.
//  Copyright (c) 2014 TNS. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <JavaScriptCore/JavaScriptCore.h>
#include <NativeScript/NativeScript.h>

#ifdef NATIVESCRIPT_DEBUGGING
#include <TNSDebugging/TNSDebugging.h>
#endif

int main(int argc, char *argv[]) {
    @autoreleasepool {
        TNSRuntime *runtime = [[TNSRuntime alloc] initWithApplicationPath:[[NSBundle mainBundle] bundlePath]];
        [TNSRuntimeInspector setLogsToSystemConsole:YES];

#ifdef NATIVESCRIPT_DEBUGGING
        id debuggingServer = [runtime enableDebuggingWithName:[NSBundle mainBundle].bundleIdentifier];
#endif
        
        JSValueRef error = NULL;
        [runtime executeModule:@"./bootstrap" error:&error];

        if (error) {
            return -1;
        } else {
            return 0;
        }
    }
}
