#import <Cocoa/Cocoa.h>

int main(int argc, const char *argv[]) {
  NSBundle *applicationBundle = [NSBundle
      bundleWithPath:[[NSBundle mainBundle] pathForAuxiliaryExecutable:
                                                @"NativeScript Inspector.app"]];
  NSArray *runningApplications = [NSRunningApplication
      runningApplicationsWithBundleIdentifier:[applicationBundle
                                                  bundleIdentifier]];

  if (runningApplications.count > 0) {
    NSDictionary *innerArguments = @{
      @"project_name" : @(argv[2]),
      @"socket_path" : @(argv[3])
    };
    [[NSDistributedNotificationCenter defaultCenter]
        postNotificationName:
            @"org.NativeScriptInspector.ApplicationShouldHandleReopen"
                      object:nil
                    userInfo:innerArguments];
    [runningApplications[0]
        activateWithOptions:NSApplicationActivateIgnoringOtherApps];
  } else {
    NSDictionary *configuration = @{
      NSWorkspaceLaunchConfigurationArguments :
          @[ @(argv[1]), @(argv[2]), @(argv[3]) ],
      NSWorkspaceLaunchConfigurationEnvironment : @{
        @"DYLD_FRAMEWORK_PATH" : [[NSBundle mainBundle] privateFrameworksPath]
      }
    };

    [[NSWorkspace sharedWorkspace]
        launchApplicationAtURL:applicationBundle.bundleURL
                       options:0
                 configuration:configuration
                         error:nil];
  }

  return 0;
}
