//
//  main.m
//  TNSBridgeApp
//
//  Created by Yavor Georgiev on 07.03.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <NativeScript/NativeScript.h>
#if WAIT_FOR_INSPECTOR
#include <TNSDebugging/TNSDebugging.h>
#endif

int main(int argc, char* argv[]) {
    @autoreleasepool {
        TNSRuntime* runtime = [[TNSRuntime alloc] initWithApplicationPath:[[NSBundle mainBundle] bundlePath]];
        [TNSRuntimeInspector setLogsToSystemConsole:YES];

#if WAIT_FOR_INSPECTOR
        id server = [runtime startWebSocketServerOnPort:8080];
        CFRunLoopRun();
#endif

        JSValueRef error = NULL;
        [runtime executeModule:@"./bootstrap"
                         error:&error];

        if (error) {
            return -1;
        } else {
            return 0;
        }
    }
}
