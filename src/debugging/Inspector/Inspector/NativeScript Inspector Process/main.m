#import <Foundation/Foundation.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>
@import WebKit;

@interface WKPreferences (WKPrivate)
@property (nonatomic, setter=_setAllowFileAccessFromFileURLs:) BOOL _allowFileAccessFromFileURLs;
@end

@interface InspectorApplicationDelegate : NSObject <NSApplicationDelegate>
-(BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)sender;
@end

@implementation InspectorApplicationDelegate

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender;
 {
    return YES;
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        InspectorApplicationDelegate* applicationDelegate = [[InspectorApplicationDelegate alloc] init];
        NSApplication* app = [NSApplication sharedApplication];
        [app setDelegate:applicationDelegate];
        [app activateIgnoringOtherApps:YES];
        
        NSRect frame = NSMakeRect(60.0, 200.0, 750.0, 650.0);
        WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
        configuration.preferences._allowFileAccessFromFileURLs = YES;
        
        WKWebView* webView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
        webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:@(argv[1])]]];
        
        NSWindow* window = [[NSWindow alloc]
                            initWithContentRect: frame
                            styleMask: NSTitledWindowMask | NSMiniaturizableWindowMask | NSClosableWindowMask | NSResizableWindowMask | NSFullSizeContentViewWindowMask
                            backing: NSBackingStoreBuffered
                            defer: NO];
        window.title = [NSString stringWithFormat:@"WebInspector - %s", argv[2]];
        window.titlebarAppearsTransparent = YES;
        window.contentView = webView;
        
        [window center];
        [window makeKeyAndOrderFront:app];
        
        [app run];
    }
    return 0;
}
