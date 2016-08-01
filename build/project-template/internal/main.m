//
// Any changes in this file will be removed after you update your platform!
//

#include <Foundation/Foundation.h>
#include <JavaScriptCore/JavaScriptCore.h>
#include <NativeScript/NativeScript.h>
#include <TNSExceptionHandler.h>

#if DEBUG
#include <TNSDebugging.h>
#endif

TNSRuntime *runtime;

int main(int argc, char *argv[]) {
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

    runtime = [[TNSRuntime alloc] initWithApplicationPath:applicationPath];
    [runtime scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSRunLoopCommonModes];

#if DEBUG
    [TNSRuntimeInspector setLogsToSystemConsole:YES];
    TNSEnableRemoteInspector(argc, argv);
#endif

    TNSInstallExceptionHandler();

    [runtime executeModule:@"./"];

    return 0;
  }
}
