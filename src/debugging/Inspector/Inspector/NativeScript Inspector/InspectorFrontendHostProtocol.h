#import <Foundation/Foundation.h>
#import <JavaScriptCore/JSExport.h>

@protocol InspectorFrontendHostProtocol <JSExport>

- (NSString *)platform;
- (NSString *)localizedStringsURL;
- (NSString *)debuggableType;
- (void)loaded;
- (void)bringToFront;
- (void)sendMessageToBackend:(NSString *)message;
- (void)inspectedURLChanged;

@end
