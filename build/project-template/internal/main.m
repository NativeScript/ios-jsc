//
// Any changes in this file will be removed after you update your platform!
//

#include <Foundation/Foundation.h>
#include <JavaScriptCore/JavaScriptCore.h>
#include <NativeScript.h>
#include <TNSExceptionHandler.h>

#if DEBUG
#include <TNSDebugging.h>
#include <TKLiveSync.h>
#endif

TNSRuntime *runtime = nil;
extern char startOfMetadataSection __asm("section$start$__DATA$__TNSMetadata");

int main(int argc, char *argv[]) {
  @autoreleasepool {
    NSString *applicationPath = [[NSBundle mainBundle] bundlePath];

#if DEBUG
      applicationPath = [TKLiveSync initAppFolder];
#endif

    [TNSRuntime initializeMetadata:&startOfMetadataSection];
    TNSInstallExceptionHandler();

    runtime = [[TNSRuntime alloc] initWithApplicationPath:applicationPath];
    [runtime scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSRunLoopCommonModes];

#if DEBUG
    [TNSRuntimeInspector setLogsToSystemConsole:YES];
    TNSEnableRemoteInspector(argc, argv);
#endif

    [runtime executeModule:@"./"];

    return 0;
  }
}