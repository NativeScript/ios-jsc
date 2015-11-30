#import <Foundation/Foundation.h>
#import <JavaScriptCore/JSExport.h>

@protocol InspectorFrontendHostProtocol <JSExport>

- (NSString *)platform;
- (NSString *)localizedStringsURL;
- (NSString *)debuggableType;
- (unsigned)inspectionLevel;
- (void)loaded;
- (void)bringToFront;
- (void)sendMessageToBackend:(NSString *)message;
- (void)inspectedURLChanged;
- (void)startWindowDrag;

@end