#import <Foundation/Foundation.h>
#import "InspectorFrontendHostProtocol.h"
@import AppKit;

@interface InspectorFrontendHost : NSObject <InspectorFrontendHostProtocol>

@property dispatch_io_t channel;
@property NSResponder *responder;

- (NSString *)platform;
- (NSString *)localizedStringsURL;
- (NSString *)debuggableType;
- (void)loaded;
- (void)bringToFront;
- (void)sendMessageToBackend:(NSString *)message;
- (void)inspectedURLChanged;

@end