#import "InspectorFrontendHost.h"
#import <Foundation/Foundation.h>

@implementation InspectorFrontendHost

- (void)bringToFront {
}

- (NSString *)platform {
  return @"mac";
}

- (NSString *)localizedStringsURL {
  return @"";
}

- (NSString *)debuggableType {
  return @"web";
}

- (NSString *)backendCommandsURL {
  return @"";
}

- (NSString *)zoomFactor {
  return @"";
}

- (unsigned)inspectionLevel {
  return 1;
}

- (void)connect:(NSString *)socketPath
     readHandler:(InspectorReadHandler)read_handler
    errorHandler:(InspectorErrorHandler)errorHandler {
  self->communication_channel =
      [[TNSCommunicationChannel alloc] initWithSocketPath:socketPath
                                              readHandler:read_handler
                                             errorHandler:errorHandler];
}

- (void)disconnect {
  if (self->communication_channel) {
    self->communication_channel = nil;
  }
}

- (void)loaded {
}

- (void)inspectedURLChanged {
}

- (void)startWindowDrag {
  [[NSApp mainWindow] performWindowDragWithEvent:[NSApp currentEvent]];
}

- (void)sendMessageToBackend:(NSString *)message {
  if (self->communication_channel) {
    NSUInteger length =
        [message lengthOfBytesUsingEncoding:NSUTF16LittleEndianStringEncoding];

    NSMutableData *buffer = [NSMutableData dataWithLength:length];
    [message getBytes:buffer.mutableBytes
             maxLength:length
            usedLength:NULL
              encoding:NSUTF16LittleEndianStringEncoding
               options:0
                 range:NSMakeRange(0, message.length)
        remainingRange:NULL];

    [self->communication_channel sendMessage:length
                                     message:buffer.mutableBytes];
  }
}

- (void)showContextMenu {
}

- (void)setZoomFactor:(NSString *)factor {
}

- (void)openInNewTab {
}

- (NSString *)userInterfaceLayoutDirection {
  return @"ltr";
}

@end
