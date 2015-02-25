//
//  TNSMultiChannel.m
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/29/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import "TNSMultiChannel.h"

@interface TNSMultiChannel () <TNSDebugMessagingChannelDelegate>

@property(strong, nonatomic) NSArray* subChannels;
@property(strong, nonatomic) id<TNSDebugMessagingChannel> connectedChannel;

@end

@implementation TNSMultiChannel

- (instancetype)initWithSubchannels:(id<TNSDebugMessagingChannel>)firstChannel,
                                    ... {
    self = [super init];
    if (self) {
        NSMutableArray* array = [[NSMutableArray alloc] init];
        va_list args;
        va_start(args, firstChannel);
        for (id<TNSDebugMessagingChannel> channel = firstChannel; channel != nil;
             channel = va_arg(args, id<TNSDebugMessagingChannel>)) {
            [array addObject:channel];
            channel.delegate = self;
        }
        va_end(args);
        self.subChannels = [array copy];
    }

    return self;
}

- (void)send:(NSString*)message {
    [self.connectedChannel send:message];
}

- (void)open {
    for (id channel in self.subChannels) {
        [channel open];
    }
}

- (void)close {
    for (id channel in self.subChannels) {
        [channel close];
    }
}

- (void)connected:(id)connectedChannel {
    for (id channel in self.subChannels) {
        if (channel != connectedChannel) {
            [channel close];
        }
    }
    self.connectedChannel = connectedChannel;
    [self.delegate connected:self];
}

- (void)disconnected:(id)disconnectedChannel {
    [self.delegate disconnected:self];
    self.connectedChannel = nil;
}

- (void)received:(NSString*)message onChannel:(id)channel {
    [self.delegate received:message onChannel:self];
}

@end
