@import AppKit;
@import WebKit;

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

        WebView* webView = [[WebView alloc] initWithFrame:frame];

        webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        webView.mainFrameURL = @(argv[1]);
        
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
