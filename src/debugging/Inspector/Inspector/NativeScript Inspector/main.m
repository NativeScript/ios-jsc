#import <Cocoa/Cocoa.h>

int main(int argc, const char* argv[]) {
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"WebKitDeveloperExtras"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return NSApplicationMain(argc, argv);
}
