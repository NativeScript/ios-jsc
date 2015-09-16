#import <Foundation/Foundation.h>
#import "InspectorFrontendHost.h"
#import "Communication.h"

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
    self->error_handler = errorHandler;
    self->communication_channel = setup_communication_channel([socketPath UTF8String], read_handler, errorHandler);
}

- (void)disconnect {
    if (self->communication_channel.connected) {
        self->communication_channel.connected = NO;
        self->error_handler = nil;
        disconnect(self->communication_channel);
    }
}

- (void)loaded {
}

- (void)inspectedURLChanged {
}

- (void)sendMessageToBackend:(NSString*)message {
    if (self->communication_channel.connected) {
        uint32_t length = [message lengthOfBytesUsingEncoding:NSUTF16LittleEndianStringEncoding];

        void* buffer = malloc(length);
        [message getBytes:buffer maxLength:length usedLength:NULL encoding:NSUTF16LittleEndianStringEncoding options:0 range:NSMakeRange(0, message.length) remainingRange:NULL];

        send_message(self->communication_channel, length, buffer, self->error_handler);
    }
}

@end