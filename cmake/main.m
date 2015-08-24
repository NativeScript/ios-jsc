#import <NativeScript.h>

#ifndef NDEBUG
#include <TNSDebugging.h>
#endif

TNSRuntime *runtime = nil;
extern char startOfMetadataSection __asm("section$start$__DATA$__TNSMetadata");

int main(int argc, char *argv[]) {
  @autoreleasepool {
    [TNSRuntime initializeMetadata:&startOfMetadataSection];
    runtime = [[TNSRuntime alloc]
        initWithApplicationPath:[NSBundle mainBundle].bundlePath];
    TNSRuntimeInspector.logsToSystemConsole = YES;

#ifndef NDEBUG
    TNSEnableRemoteInspector(argc, argv);
#endif

    [runtime executeModule:@"./"];

    return 0;
  }
}
