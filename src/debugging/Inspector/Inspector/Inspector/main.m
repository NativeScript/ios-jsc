#import <Cocoa/Cocoa.h>

int main(int argc, const char *argv[]) {
  NSBundle *applicationBundle = [NSBundle
      bundleWithPath:[[NSBundle mainBundle] pathForAuxiliaryExecutable:
                                                @"NativeScript Inspector.app"]];
  NSArray *runningApplications = [NSRunningApplication
      runningApplicationsWithBundleIdentifier:[applicationBundle
                                                  bundleIdentifier]];

  NSString *main_file_path = @(argv[1]);
  NSString *project_name = @(argv[2]);
  NSString *socket_path = @"";

  if (argc >= 4) {
    socket_path = @(argv[3]);
  }

  NSLog(@"Inspector socket path %@", socket_path);
  if (runningApplications.count > 0) {
    NSDictionary *innerArguments =
        @{@"project_name" : project_name, @"socket_path" : socket_path};

    [[NSDistributedNotificationCenter defaultCenter]
        postNotificationName:
            @"org.NativeScriptInspector.ApplicationShouldHandleReopen"
                      object:nil
                    userInfo:innerArguments];
    [runningApplications[0]
        activateWithOptions:NSApplicationActivateIgnoringOtherApps];
  } else {
    NSDictionary *configuration = [[NSMutableDictionary alloc] init];
    [configuration setValue:@[ main_file_path, project_name, socket_path ]
                     forKey:NSWorkspaceLaunchConfigurationArguments];

    // Check: Starting with High Sierra some internal APIs
    // used by WebKit are not present. We resort to compat libraries
    // instead of using our own until we upgrade to the latest WebKit version.
    NSProcessInfo *pInfo = [NSProcessInfo processInfo];
    NSOperatingSystemVersion version = {.majorVersion = 10, .minorVersion = 13};

    if (![pInfo isOperatingSystemAtLeastVersion:version]) {
      [configuration setValue:@{
        @"DYLD_FRAMEWORK_PATH" : [[NSBundle mainBundle] privateFrameworksPath]
      }
                       forKey:NSWorkspaceLaunchConfigurationEnvironment];
    }

    [[NSWorkspace sharedWorkspace]
        launchApplicationAtURL:applicationBundle.bundleURL
                       options:0
                 configuration:configuration
                         error:nil];
  }

  return 0;
}
