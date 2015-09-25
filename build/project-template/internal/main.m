//
// Any changes in this file will be removed after you update your platform!
//

#include <Foundation/Foundation.h>
#include <JavaScriptCore/JavaScriptCore.h>
#include <NativeScript.h>

#ifndef NDEBUG
#include <TNSDebugging.h>
#endif

TNSRuntime *runtime = nil;
extern char startOfMetadataSection __asm("section$start$__DATA$__TNSMetadata");

int main(int argc, char *argv[]) {
  @autoreleasepool {
    NSString *applicationPath = [[NSBundle mainBundle] bundlePath];

#ifndef NDEBUG
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(
        NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *liveSyncPath =
        [NSString pathWithComponents:
                      @[ libraryPath, @"Application Support", @"LiveSync" ]];
    NSString *appFolderPath =
        [NSString pathWithComponents:@[ liveSyncPath, @"app" ]];

    NSArray *appContents =
        [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appFolderPath
                                                            error:nil];
    if (appContents.count > 0) {
      applicationPath = liveSyncPath;
    }
#endif

    [TNSRuntime initializeMetadata:&startOfMetadataSection];
    runtime = [[TNSRuntime alloc] initWithApplicationPath:applicationPath];
    [runtime scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSRunLoopCommonModes];

#ifndef NDEBUG
    [TNSRuntimeInspector setLogsToSystemConsole:YES];
    TNSEnableRemoteInspector(argc, argv);
#endif

    [runtime executeModule:@"./"];

    return 0;
  }
}