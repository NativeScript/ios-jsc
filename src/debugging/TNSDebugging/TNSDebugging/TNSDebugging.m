//
//  TNSDebugging.m
//  TNSDebugging
//
//  Created by Ivan Buhov on 10/10/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#import "TNSDebugging.h"

#import "TNSMultiChannel.h"
#import "TNSTCPMessagingServer.h"
#import "TNSWebSocketMessagingServer.h"

#import "TNSDebugServer.h"

@implementation TNSRuntime (TNSDebugging)

- (id) enableDebuggingWithName:(NSString*)name {

    TNSWebSocketMessagingServer* webSocketChannel = [[TNSWebSocketMessagingServer alloc] initWithPort:8080];
    TNSTCPMessagingServer* tcpChannel = [[TNSTCPMessagingServer alloc] initWithPort:18181];

    TNSMultiChannel* multyChannel = [[TNSMultiChannel alloc] initWithSubchannels:tcpChannel, webSocketChannel, nil];

    return [[TNSDebugServer alloc] initWithRuntime:self name:name messagingChannel:multyChannel];
}

@end
