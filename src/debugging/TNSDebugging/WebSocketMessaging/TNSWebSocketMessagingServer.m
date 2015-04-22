//
//  TNSWebSocketMessagingServer.m
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/27/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import <PSWebSocketServer.h>
#import "TNSWebSocketMessagingServer.h"

@interface TNSWebSocketMessagingServer () <PSWebSocketServerDelegate>

@property(nonatomic, strong) PSWebSocketServer* webSocketServer;
@property(nonatomic, strong) PSWebSocket* socket;
@property dispatch_queue_t delegateQueue;

@end

@implementation TNSWebSocketMessagingServer

- (instancetype)initWithPort:(NSUInteger)port {
    self = [super init];
    if (self) {
        self.delegateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

        self.webSocketServer = [PSWebSocketServer serverWithHost:nil port:port];
        self.webSocketServer.delegate = self;
        self.webSocketServer.delegateQueue = self.delegateQueue;
    }
    return self;
}

- (void)send:(NSString*)message {
    [self.socket send:message];
}

- (void)open {
    [self.webSocketServer start];
}

- (void)close {
    [self.webSocketServer stop];
}

#pragma mark - PSWebSocketServerDelegate

- (void)serverDidStart:(PSWebSocketServer*)server {
}

- (void)serverDidStop:(PSWebSocketServer*)server {
}

- (BOOL)server:(PSWebSocketServer*)server acceptWebSocketWithRequest:(NSURLRequest*)request {
    return !self.socket;
}

- (void)server:(PSWebSocketServer*)server webSocketDidOpen:(PSWebSocket*)webSocket {
    if (!self.socket) {
        self.socket = webSocket;
        self.socket.delegateQueue = self.delegateQueue;
        [self.delegate connected:self];
    }
}

- (void)server:(PSWebSocketServer*)server webSocket:(PSWebSocket*)webSocket didReceiveMessage:(id)message {
    [self.delegate received:message onChannel:self];
}

- (void)server:(PSWebSocketServer*)server webSocket:(PSWebSocket*)webSocket didFailWithError:(NSError*)error {
    [self closeSocket];
}

- (void)server:(PSWebSocketServer*)server webSocket:(PSWebSocket*)webSocket didCloseWithCode:(NSInteger)code reason:(NSString*)reason wasClean:(BOOL)wasClean {
    [self closeSocket];
}

- (void)closeSocket {
    [self close];
    self.socket = nil;
    [self.delegate disconnected:self];
}

@end
