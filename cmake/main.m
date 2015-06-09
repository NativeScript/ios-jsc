#import <NativeScript.h>

#ifndef NDEBUG
#include <TNSDebugging.h>
#endif

TNSRuntime *runtime = nil;

int main(int argc, char *argv[]) {
  @autoreleasepool {
    runtime = [[TNSRuntime alloc]
        initWithApplicationPath:[NSBundle mainBundle].bundlePath];
    TNSRuntimeInspector.logsToSystemConsole = YES;

#ifndef NDEBUG
    enableDebugging(argc, argv);
#endif

    CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopCommonModes,
                          ^{ [runtime executeModule:@"./"]; });
    CFRunLoopRun();

    return 0;
  }
}
