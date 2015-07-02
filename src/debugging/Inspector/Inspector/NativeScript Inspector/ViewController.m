#import "ViewController.h"
@import AppKit;
@import WebKit;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray* arguments = [[NSProcessInfo processInfo] arguments];
    WebView* webView = (WebView*)self.view;
    webView.mainFrameURL = (NSString*)arguments[1];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationShouldReopen:) name:@"org.NativeScriptInspector.ApplicationShouldHandleReopen" object:nil];
}

- (void)applicationShouldReopen:(NSNotification*)notification {
    NSString* title = [notification.userInfo valueForKey:@"project_name"];
    [self update: title];
    
    WebView* webView = (WebView*)self.view;
    [webView reload:self];
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

@end
