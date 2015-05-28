//
//  main.m
//  __PROJECT_NAME__
//
//

#include <Foundation/Foundation.h>
#include <JavaScriptCore/JavaScriptCore.h>
#include <NativeScript.h>

#ifndef NDEBUG
#include "TNSDebugging.h"
#endif

TNSRuntime *runtime = nil;

int main(int argc, char *argv[]) {
    @autoreleasepool {
        runtime = [[TNSRuntime alloc] initWithApplicationPath:[[NSBundle mainBundle] bundlePath]];

#ifndef NDEBUG
        [TNSRuntimeInspector setLogsToSystemConsole:YES];
        TNSEnableRemoteInspector(argc, argv);
#endif

        [runtime executeModule:@"./"];

        return 0;
    }
}
