#import <NativeScript.h>
#import <TNSExceptionHandler.h>

#ifndef NDEBUG
#include <TNSDebugging.h>
#endif

extern char startOfMetadataSection __asm("section$start$__DATA$__TNSMetadata");

int main(int argc, char* argv[]) {
    @autoreleasepool {
        [TNSRuntime initializeMetadata:&startOfMetadataSection];
        TNSRuntime* runtime = [[TNSRuntime alloc]
            initWithApplicationPath:[NSString stringWithUTF8String:[NSBundle mainBundle].resourceURL.fileSystemRepresentation]];
        [runtime scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSRunLoopCommonModes];
        TNSRuntimeInspector.logsToSystemConsole = YES;

        TNSInstallExceptionHandler();

#ifndef NDEBUG
        TNSEnableRemoteInspector(argc, argv, runtime);
#endif

        [runtime executeModule:@"./"];

        return 0;
    }
}
