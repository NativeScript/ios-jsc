#import "ViewController.h"
@import AppKit;
@import WebKit;
@import JavaScriptCore;
#import "InspectorFrontendHost.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationShouldReopen:) name:@"org.NativeScriptInspector.ApplicationShouldHandleReopen" object:nil];

    self->frontendHost = [[InspectorFrontendHost alloc] init];
    [self setupWebView];

    NSArray* arguments = [[NSProcessInfo processInfo] arguments];
    NSString* socket_path = @"";

    if (arguments.count >= 4) {
        socket_path = arguments[3];
    }

    [self connect:socket_path];
}

- (void)applicationShouldReopen:(NSNotification*)notification {
    [self->frontendHost disconnect];
    self.view = [[WebView alloc] initWithFrame:self.view.frame];
    [self setupWebView];

    NSString* title = [notification.userInfo valueForKey:@"project_name"];
    [self update:title];

    NSString* socket_path = [notification.userInfo valueForKey:@"socket_path"];
    [self connect:socket_path];
}

- (void)setupWebView {
    WebView* webView = (WebView*)self.view;

    JSContext* context = webView.mainFrame.javaScriptContext;

    context[@"InspectorFrontendHost"] = self->frontendHost;
    context[@"WebInspector"] = [JSValue valueWithNewObjectInContext:context];
    context[@"WebInspector"][@"dontLocalizeUserInterface"] = @(true);

    NSArray* arguments = [[NSProcessInfo processInfo] arguments];
    webView.mainFrameURL = (NSString*)arguments[1];
}

- (void)viewWillAppear {
    [super viewWillAppear];

    NSArray* arguments = [[NSProcessInfo processInfo] arguments];

    [self update:(NSString*)arguments[2]];
    self.view.window.titlebarAppearsTransparent = YES;
}

- (void)update:(NSString*)title {
    self.view.window.title = [NSString stringWithFormat:@"NativeScript Inspector - %@", title];
}

- (void)connect:(NSString*)socket_path {
    InspectorReadHandler read_handler = ^(dispatch_data_t data) {
      NSString* payload = [[NSString alloc] initWithData:(NSData*)data encoding:NSUTF16LittleEndianStringEncoding];

      WebView* webView = (WebView*)self.view;
      [webView.mainFrame.javaScriptContext[@"InspectorBackend"] invokeMethod:@"dispatch" withArguments:@[ payload ]];
    };

    InspectorErrorHandler error_handler = ^(NSError* error) {
      [self->frontendHost disconnect];
      [self.view presentError:error];
    };

    [self->frontendHost connect:socket_path readHandler:read_handler errorHandler:error_handler];
}

@end
