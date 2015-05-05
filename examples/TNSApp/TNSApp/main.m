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

#ifndef NDEBUG
#include <TNSDebugging.h>
#endif

TNSRuntime *runtime = nil;

int main(int argc, char *argv[]) {
    @autoreleasepool {
        runtime = [[TNSRuntime alloc] initWithApplicationPath:[[NSBundle mainBundle] bundlePath]];

#ifndef NDEBUG
        [TNSRuntimeInspector setLogsToSystemConsole:YES];
        enableDebugging(argc, argv);
#endif

        [runtime executeModule:@"./"];

        return 0;
    }
}
