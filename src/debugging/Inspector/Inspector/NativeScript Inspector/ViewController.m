#import "ViewController.h"
@import AppKit;
@import WebKit;
@import JavaScriptCore;
//#import <WebKit/WebPreferencesPrivate.h>
#import "InspectorFrontendHost.h"
#import "Communication.h"

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  NSArray *arguments = [[NSProcessInfo processInfo] arguments];
  WebView *webView = (WebView *)self.view;
  //    [[WebPreferences standardPreferences] setDeveloperExtrasEnabled:YES];

  self->frontendHost = [[InspectorFrontendHost alloc] init];
  self->frontendHost.responder = self.view;

  JSContext *context = webView.mainFrame.javaScriptContext;
  context[@"WebInspector"] = [JSValue valueWithNewObjectInContext:context];
  context[@"WebInspector"][@"dontLocalizeUserInterface"] = @(true);

  context[@"InspectorFrontendHost"] = self->frontendHost;
  webView.mainFrameURL = (NSString *)arguments[1];
}

- (void)awakeFromNib {
  [super awakeFromNib];

  [[NSDistributedNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(applicationShouldReopen:)
             name:@"org.NativeScriptInspector.ApplicationShouldHandleReopen"
           object:nil];
}

- (void)applicationShouldReopen:(NSNotification *)notification {
  NSString *title = [notification.userInfo valueForKey:@"project_name"];
  [self update:title];

  WebView *webView = (WebView *)self.view;
  [webView reload:self];

  NSString *socket_path = [notification.userInfo valueForKey:@"socket_path"];
  [self connect:socket_path];
}

- (void)viewWillAppear {
  [super viewWillAppear];

  NSArray *arguments = [[NSProcessInfo processInfo] arguments];
  NSString *socket_path;

  if (arguments.count == 4) {
    socket_path = arguments[3];
  }

  [self connect:socket_path];

  [self update:(NSString *)arguments[2]];
  self.view.window.titlebarAppearsTransparent = YES;
}

- (void)update:(NSString *)title {
  self.view.window.title =
      [NSString stringWithFormat:@"NativeScript Inspector - %@", title];
}

- (void)connect:(NSString *)socket_path {
  InspectorReadHandler read_handler = ^(dispatch_data_t data) {
    NSString *payload =
        [[NSString alloc] initWithData:(NSData *)data
                              encoding:NSUTF16LittleEndianStringEncoding];

    WebView *webView = (WebView *)self.view;
    [webView.mainFrame.javaScriptContext[@"InspectorBackend"]
         invokeMethod:@"dispatch"
        withArguments:@[ payload ]];
  };

  InspectorErrorHandler error_handler = ^(NSError *error) {
    [self.view presentError:error];
    self->frontendHost.channel = nil;
  };

  self->frontendHost.channel = setup_communication_channel(
      [socket_path UTF8String], read_handler, error_handler);
}

@end
