//
//  TNSOutputMessageStream.m
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/27/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import "TNSOutputMessageStream.h"

@interface TNSOutputMessageStream () <NSStreamDelegate>

@property(nonatomic, strong) NSOutputStream* stream;

@end

@implementation TNSOutputMessageStream

- (instancetype)initWithStream:(NSOutputStream*)stream {
    self = [super init];
    if (self) {
        self.stream = stream;
        self.stream.delegate = self;
    }

    return self;
}

void tns_bigEndianBuffer_fromUInt32(UInt32 data, UInt8 buffer[4]) {
    buffer[3] = (UInt8)data;
    buffer[2] = (UInt8)(((uint)data >> 8) & 0xFF);
    buffer[1] = (UInt8)(((uint)data >> 16) & 0xFF);
    buffer[0] = (UInt8)(((uint)data >> 24) & 0xFF);
}

- (void)send:(NSString*)message {
    NSData* data = [[NSData alloc] initWithData:[message dataUsingEncoding:NSUTF16LittleEndianStringEncoding]];

    // TRICKY: Make sure we do not mix little and big endians on the other end...
    UInt8 sizeBytes[4];
    tns_bigEndianBuffer_fromUInt32(data.length, sizeBytes);
    [self.stream write:sizeBytes maxLength:4];

    [self.stream write:[data bytes] maxLength:[data length]];
}

- (void)open {
    [self.stream open];
}

- (void)close {
    [self.stream close];
}

- (void)scheduleInRunLoop:(NSRunLoop*)aRunLoop forMode:(NSString*)mode {
    [self.stream scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop*)aRunLoop forMode:(NSString*)mode {
    [self.stream removeFromRunLoop:aRunLoop forMode:mode];
}

- (void)stream:(NSStream*)aStream handleEvent:(NSStreamEvent)eventCode {
    if (eventCode & NSStreamEventErrorOccurred || eventCode & NSStreamEventEndEncountered) {
        [self.delegate closed:self];
    }
}

@end