//
//  TNSInputMessageStream.m
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/27/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import "TNSInputMessageStream.h"

@interface TNSInputMessageStream () <NSStreamDelegate>

@property (nonatomic, strong) NSInputStream* stream;

@end

typedef NS_ENUM(NSInteger, TNSSizePrefixedReadingState) {
  TNSSizePrefixedReadingStateReadSize,
  TNSSizePrefixedReadingStateReadBody
};

@implementation TNSInputMessageStream {
    void * _bufferData;
    unsigned int _bufferRead;
    unsigned int _bufferSize;

    TNSSizePrefixedReadingState _readState;
}

- (instancetype) initWithStream:(NSInputStream *)stream {
    self = [super init];
    if (self) {
        self->_bufferSize = sizeof(UInt8[4]);
        self->_bufferData = malloc(self->_bufferSize);
        self->_bufferRead = 0;

        self->_readState = TNSSizePrefixedReadingStateReadSize;

        self.stream = stream;
        self.stream.delegate = self;
    }

    return self;
}

- (void) open {
    [self.stream open];
}

- (void) close {
    [self.stream close];
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
    [self.stream scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode {
    [self.stream removeFromRunLoop:aRunLoop forMode:mode];
}

int tns_UInt32_fromBigEndianBuffer(UInt8 data[4]) {
    return (data[0] << 24) | (data[1] << 16) | (data[2] << 8) | data[3];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (eventCode & NSStreamEventHasBytesAvailable) {
        BOOL hasPendingData = YES;
        NSString* message;
        while(hasPendingData) {
            self->_bufferRead += [self.stream read:(self->_bufferData + self->_bufferRead) maxLength:(self->_bufferSize - self->_bufferRead)];
            if (self->_bufferRead == self->_bufferSize) {
                switch (self->_readState) {
                    case TNSSizePrefixedReadingStateReadSize:
                        self->_bufferSize = tns_UInt32_fromBigEndianBuffer(self->_bufferData);
                        free(self->_bufferData);
                        self->_bufferRead = 0;
                        self->_bufferData = malloc(self->_bufferSize);
                        self->_readState = TNSSizePrefixedReadingStateReadBody;
                        break;
                    case TNSSizePrefixedReadingStateReadBody:
                        message = [[NSString alloc] initWithBytes: self->_bufferData length:self->_bufferSize encoding:NSUTF16LittleEndianStringEncoding];
                        free(_bufferData);
                        self->_bufferRead = 0;
                        self->_bufferSize = sizeof(UInt8[4]);
                        _bufferData = malloc(self->_bufferSize);
                        [self.delegate receivedMessage:message from:self];
                        self->_readState = TNSSizePrefixedReadingStateReadSize;
                        break;
                    default:
                        break;
                }
            } else {
                hasPendingData = NO;
            }
        }
    }

    if (eventCode & NSStreamEventErrorOccurred || eventCode & NSStreamEventEndEncountered) {
        [self.delegate closed: self];
    }
}

@end
