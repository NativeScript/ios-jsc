#import <Cocoa/Cocoa.h>

int main(int argc, const char* argv[]) {
    NSBundle* applicationBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForAuxiliaryExecutable:@"NativeScript Inspector.app"]];
    NSArray* runningApplications = [NSRunningApplication runningApplicationsWithBundleIdentifier:[applicationBundle bundleIdentifier]];

    NSString* main_file_path = @(argv[1]);
    NSString* project_name = @(argv[2]);
    NSString* socket_path = @"";

    if (argc >= 4) {
        socket_path = @(argv[3]);
    }

    NSLog(@"Inspector socket path %@", socket_path);
    if (runningApplications.count > 0) {
        NSDictionary* innerArguments = @{ @"project_name" : project_name,
                                          @"socket_path" : socket_path };

        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"org.NativeScriptInspector.ApplicationShouldHandleReopen" object:nil userInfo:innerArguments];
        [runningApplications[0] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    } else {
        NSDictionary* configuration = @{
            NSWorkspaceLaunchConfigurationArguments : @[ main_file_path, project_name, socket_path ],
            NSWorkspaceLaunchConfigurationEnvironment : @{ @"DYLD_FRAMEWORK_PATH" : [[NSBundle mainBundle] privateFrameworksPath] }
        };

        [[NSWorkspace sharedWorkspace] launchApplicationAtURL:applicationBundle.bundleURL options:0 configuration:configuration error:nil];
    }

    return 0;
}
