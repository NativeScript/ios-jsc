#import <Foundation/Foundation.h>
#import "InspectorFrontendHost.h"
#import "Communication.h"

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

- (void)loaded {
}

- (void)inspectedURLChanged {
}

- (void)sendMessageToBackend:(NSString *)message {

  if (self.channel) {
    uint32_t length =
        [message lengthOfBytesUsingEncoding:NSUTF16LittleEndianStringEncoding];
    InspectorWriteHandler write_handler = ^(void *buffer) {
      [message getBytes:&buffer[sizeof(uint32_t)]
               maxLength:length
              usedLength:NULL
                encoding:NSUTF16LittleEndianStringEncoding
                 options:0
                   range:NSMakeRange(0, message.length)
          remainingRange:NULL];
    };

    InspectorErrorHandler error_handler = ^(NSError *error) {
      [self.responder presentError:error];
      self.channel = nil;
    };

    send_message(self.channel, length, write_handler, error_handler);
  }
}

@end