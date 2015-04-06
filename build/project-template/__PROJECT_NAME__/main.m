//
//  main.m
//  TNSBridgeApp
//
//  Created by Yavor Georgiev on 07.03.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include <Foundation/Foundation.h>
#include <JavaScriptCore/JavaScriptCore.h>
#include <NativeScript/NativeScript.h>

#ifdef DEBUG
#include <TNSDebugging/TNSDebugging.h>

static id debuggingServer;
#endif

int main(int argc, char* argv[]) {
    @autoreleasepool {
        TNSRuntime* runtime = [[TNSRuntime alloc] initWithApplicationPath:[NSBundle mainBundle].bundlePath];
        [TNSRuntimeInspector setLogsToSystemConsole:YES];

#ifdef DEBUG
        debuggingServer = [runtime enableDebuggingWithName:[NSBundle mainBundle].bundleIdentifier];
#endif

        [runtime executeModule:@"./"];

        return 0;
    }
}
