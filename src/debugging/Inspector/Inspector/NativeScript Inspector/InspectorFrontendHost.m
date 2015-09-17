#import <Foundation/Foundation.h>
#import "InspectorFrontendHost.h"

@implementation InspectorFrontendHost

- (void)bringToFront {
}

- (NSString*)platform {
    return @"mac";
}

- (NSString*)localizedStringsURL {
    return @"";
}

- (NSString*)debuggableType {
    return @"web";
}

- (void)connect:(NSString*)socketPath readHandler:(InspectorReadHandler)read_handler errorHandler:(InspectorErrorHandler)errorHandler {
    self->communication_channel = [[TNSCommunicationChannel alloc] initWithSocketPath:socketPath readHandler:read_handler errorHandler:errorHandler];
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

- (void)sendMessageToBackend:(NSString*)message {
    if (self->communication_channel) {
        uint32_t length = [message lengthOfBytesUsingEncoding:NSUTF16LittleEndianStringEncoding];

        void* buffer = malloc(length);
        [message getBytes:buffer maxLength:length usedLength:NULL encoding:NSUTF16LittleEndianStringEncoding options:0 range:NSMakeRange(0, message.length) remainingRange:NULL];

        [self->communication_channel sendMessage:length message:buffer];
    }
}

@end