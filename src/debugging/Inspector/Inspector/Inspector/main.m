
#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"NativeScript Inspector Process"];
    task.arguments = @[ @(argv[1]), @(argv[2]) ];
    task.environment = @{
        @"DYLD_FRAMEWORK_PATH": [[NSBundle mainBundle] privateFrameworksPath]
    };
    [task launch];
    
    return 0;
}
