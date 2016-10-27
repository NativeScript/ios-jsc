#import "ViewController.h"
@import AppKit;
@import WebKit;
@import JavaScriptCore;
#import <WebKit/WebPreferencesPrivate.h>
#import "InspectorFrontendHost.h"

@implementation ViewController {
    NSString* _mainFileName;
    NSString* _projectName;
    NSString* _socketPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray* arguments = [[NSProcessInfo processInfo] arguments];
    self->_mainFileName = arguments[1];
    self->_projectName = arguments[2];
    if (arguments.count >= 4) {
        self->_socketPath = arguments[3];
    }

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationShouldReopen:) name:@"org.NativeScriptInspector.ApplicationShouldHandleReopen" object:nil];

    self->frontendHost = [[InspectorFrontendHost alloc] init];
    [self setupWebView];

    [self connect:self->_socketPath];
}

- (void)applicationShouldReopen:(NSNotification*)notification {
    [self->frontendHost disconnect];
    self.view = [[WebView alloc] initWithFrame:self.view.frame];
    [self setupWebView];

    self->_projectName = [notification.userInfo valueForKey:@"project_name"];
    [self update:self->_projectName];

    self->_socketPath= [notification.userInfo valueForKey:@"socket_path"];
    [self connect:self->_socketPath];
}

- (void)setupWebView {
    WebView* webView = (WebView*)self.view;

    // Breakpoints are saved in window.localStorage so make them sandboxed per application
    NSString* applicationSupportPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES)[0];
    NSString* appName = [[NSBundle mainBundle].infoDictionary objectForKey:(NSString*)kCFBundleNameKey];
    NSString* localStoragePath = [NSString pathWithComponents:@[applicationSupportPath, appName, @"Local Storage", self->_projectName]];
    [webView.preferences _setLocalStorageDatabasePath:localStoragePath];
#ifndef NDEBUG
    NSLog(@"Local storage: %@", webView.preferences._localStorageDatabasePath);
#endif

    JSContext* context = webView.mainFrame.javaScriptContext;
    context[@"InspectorFrontendHost"] = self->frontendHost;

    webView.mainFrameURL = self->_mainFileName;
}

- (void)viewWillAppear {
    [super viewWillAppear];

    [self update:self->_projectName];
    self.view.window.titlebarAppearsTransparent = YES;
}

- (void)viewWillDisappear {
    [super viewWillDisappear];

    // Breakpoints are saved on pagehide event, which for some reason is not triggered when the app closes
    WebView* webView = (WebView*)self.view;
    [webView stringByEvaluatingJavaScriptFromString:
     @"var e = document.createEvent('Event');"
     @"e.initEvent('pagehide', false, false);"
     @"window.dispatchEvent(e);"
     ];
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
