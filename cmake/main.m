#import <NativeScript.h>

#if DEBUG
  #include <TNSDebugging.h>
  static id debuggingServer;
#endif

int main(int argc, char *argv[]) {
  @autoreleasepool {
    TNSRuntime *runtime = [[TNSRuntime alloc]
        initWithApplicationPath:[NSBundle mainBundle].bundlePath];
    TNSRuntimeInspector.logsToSystemConsole = YES;

    #ifdef DEBUG
      debuggingServer = [runtime enableDebuggingWithName:[NSBundle mainBundle].bundleIdentifier];
    #endif

    [runtime executeModule:@"./"];

    return 0;
  }
}
