//
// Any changes in this file will be removed after you update your platform!
//

#include <Foundation/Foundation.h>
#include <JavaScriptCore/JavaScriptCore.h>
#include <NativeScript/NativeScript.h>
#include <TNSExceptionHandler.h>

#if DEBUG
#include <TNSDebugging.h>
#include <TKLiveSync.h>
#endif

int main(int argc, char *argv[]) {
#if DEBUG
  TNSInitializeLiveSync();
#endif

  @autoreleasepool {
    extern char startOfMetadataSection __asm(
        "section$start$__DATA$__TNSMetadata");
    [TNSRuntime initializeMetadata:&startOfMetadataSection];

    NSString *applicationPath;
    if (getenv("TNSApplicationPath")) {
      applicationPath = @(getenv("TNSApplicationPath"));
    } else {
      applicationPath = [NSBundle mainBundle].bundlePath;
    }

    TNSRuntime *runtime =
        [[TNSRuntime alloc] initWithApplicationPath:applicationPath];
    [runtime scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSRunLoopCommonModes];

#if DEBUG
    [TNSRuntimeInspector setLogsToSystemConsole:YES];
    TNSEnableRemoteInspector(argc, argv, runtime);
#endif

    TNSInstallExceptionHandler();

    [runtime executeModule:@"./"];

    return 0;
  }
}
