#import <Foundation/Foundation.h>
#import <JavaScriptCore/JSExport.h>

@protocol InspectorFrontendHostProtocol <JSExport>

- (NSString*)platform;
- (NSString*)localizedStringsURL;
- (NSString*)debuggableType;
- (NSString*)backendCommandsURL;
- (NSString*)zoomFactor;
- (unsigned)inspectionLevel;
- (void)loaded;
- (void)bringToFront;
- (void)sendMessageToBackend:(NSString*)message;
- (void)inspectedURLChanged;
- (void)startWindowDrag;
- (void)setZoomFactor:(NSString*)factor;
- (void)showContextMenu;
- (void)openInNewTab;
- (NSString*)userInterfaceLayoutDirection;

@end
