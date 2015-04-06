//  main.m
//  Gameraww
//
//  Created by Yavor Georgiev on 17.01.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <JavaScriptCore/JavaScriptCore.h>
#include <NativeScript/NativeScript.h>

#ifdef NATIVESCRIPT_DEBUGGING
#include <TNSDebugging/TNSDebugging.h>
static id debuggingServer;
#endif

int main(int argc, char *argv[]) {
    @autoreleasepool {
        TNSRuntime *runtime = [[TNSRuntime alloc] initWithApplicationPath:[[NSBundle mainBundle] bundlePath]];
        [TNSRuntimeInspector setLogsToSystemConsole:YES];

#ifdef NATIVESCRIPT_DEBUGGING
        debuggingServer = [runtime enableDebuggingWithName:[NSBundle mainBundle].bundleIdentifier];
#endif

        [runtime executeModule:@"./bootstrap"];

        return 0;
    }
}
