//
// Any changes in this file will be removed after you update your platform!
//

#include <Foundation/Foundation.h>
#include <JavaScriptCore/JavaScriptCore.h>
#include <NativeScript/NativeScript.h>
#include <TNSExceptionHandler.h>

#if DEBUG
#include <TKLiveSync.h>
#include <TNSDebugging.h>
#endif

int main(int argc, char* argv[]) {
    @autoreleasepool {
        TNSRuntime* runtime = [TNSRuntimeInstrumentation profile:@"main"
                                                       withBlock:^{
                                                         __block NSString* applicationPath = [NSBundle mainBundle].bundlePath;

#if DEBUG
                                                         [TNSRuntimeInstrumentation profile:@"Debug: Lifesync & Syslog"
                                                                                  withBlock:^{
                                                                                    TNSInitializeLiveSync();
                                                                                    if (getenv("TNSApplicationPath")) {
                                                                                        applicationPath = @(getenv("TNSApplicationPath"));
                                                                                    }
                                                                                    [TNSRuntimeInstrumentation initWithApplicationPath:applicationPath];
                                                                                    [TNSRuntimeInspector setLogsToSystemConsole:YES];
                                                                                    return (id)nil;
                                                                                  }];
#endif

                                                         extern char startOfMetadataSection __asm("section$start$__DATA$__TNSMetadata");
                                                         [TNSRuntime initializeMetadata:&startOfMetadataSection];
                                                         TNSRuntime* runtime = [[TNSRuntime alloc] initWithApplicationPath:applicationPath];
                                                         [runtime scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

#if DEBUG
                                                         [TNSRuntimeInstrumentation profile:@"Debug: Wait for JavaScript debugger"
                                                                                  withBlock:^{
                                                                                    TNSEnableRemoteInspector(argc, argv, runtime);
                                                                                    return (id)nil;
                                                                                  }];
#endif

                                                         TNSInstallExceptionHandler();
                                                         return runtime;
                                                       }];

#if DEBUG
        // Load inspector pages modules in advance. Loading them asynchronously on inspector client connection
        // can sporadically break application startup due to the common dependencies between
        // the application and inspector modules.
        [runtime executeModule:@"inspector_modules.js"];
#endif

        [runtime executeModule:@"./"];

        return 0;
    }
}
