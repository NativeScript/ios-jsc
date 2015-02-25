//
//  TNSTCPMessagingServer.m
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/27/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>

#import "TNSTCPMessagingServer.h"
#import "TNSTCPSocketMessageNetworkThread.h"
#import "TNSOutputMessageStream.h"
#import "TNSInputMessageStream.h"

@interface TNSTCPMessagingServer () <TNSMessageStreamDelegate>

@property(nonatomic, retain) TNSInputMessageStream* inputStream;
@property(nonatomic, retain) TNSOutputMessageStream* outputStream;
@property dispatch_queue_t delegateQueue;

- (void)handleTCPConnect:(CFSocketNativeHandle*)handle;

@end

void handleConnect(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void* data, void* info) {
    if (type == kCFSocketAcceptCallBack) {
        [(__bridge TNSTCPMessagingServer*)info handleTCPConnect:(CFSocketNativeHandle*)data];
    }
}

@implementation TNSTCPMessagingServer {
    CFSocketRef _socketServer;
    NSUInteger _port;
}

- (instancetype)initWithPort:(NSUInteger)port {
    self = [super init];
    if (self) {
        self.delegateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);

        self->_port = port;
        self->_socketServer = nil;
    }

    return self;
}

- (void)send:(NSString*)message {
    [self.outputStream send:message];
}

- (void)open {
    [self releaseSocketServer];

    CFSocketContext context;
    memset(&context, 0, sizeof(context));
    context.info = (__bridge void*)(self);

    // Setup socket
    self->_socketServer = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, handleConnect, &context);

    // Set socket's port
    struct sockaddr_in sin;
    memset(&sin, 0, sizeof(sin));
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET;
    sin.sin_port = htons(self->_port);
    sin.sin_addr.s_addr = INADDR_ANY;

    CFDataRef sincfd = CFDataCreate(kCFAllocatorDefault, (UInt8*)&sin, sizeof(sin));
    CFSocketSetAddress(self->_socketServer, sincfd);
    CFRelease(sincfd);

    CFRunLoopSourceRef socketsource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, self->_socketServer, 0);
    CFRunLoopRef runLoopRef = [TNSTCPSocketMessageNetworkThread sharedNetworkThread].runLoop.getCFRunLoop;
    CFRunLoopAddSource(runLoopRef, socketsource, kCFRunLoopDefaultMode);
}

- (void)releaseSocketServer {
    if (self->_socketServer) {
        CFSocketInvalidate(self->_socketServer);
        CFRelease(self->_socketServer);
        self->_socketServer = NULL;
    }
}

- (void)close {
    [self releaseSocketServer];

    [self.inputStream close];
    self.inputStream = nil;

    [self.outputStream close];
    self.outputStream = nil;
}

- (void)handleTCPConnect:(CFSocketNativeHandle*)handle {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, *handle, &readStream, &writeStream);

    self.outputStream = [[TNSOutputMessageStream alloc] initWithStream:CFBridgingRelease(writeStream)];
    [self.outputStream scheduleInRunLoop:[TNSTCPSocketMessageNetworkThread sharedNetworkThread].runLoop forMode:NSDefaultRunLoopMode];
    self.outputStream.delegate = self;
    [self.outputStream open];

    [self.delegate connected:self];

    self.inputStream = [[TNSInputMessageStream alloc] initWithStream:CFBridgingRelease(readStream)];
    [self.inputStream scheduleInRunLoop:[TNSTCPSocketMessageNetworkThread sharedNetworkThread].runLoop forMode:NSDefaultRunLoopMode];
    self.inputStream.delegate = self;
    [self.inputStream open];
}

#pragma mark - NSStreamDelegate

- (void)closed:(id)stream {
    [self.delegate disconnected:self];
    [self releaseSocketServer];
}

- (void)receivedMessage:(id)message from:(id)stream {
    dispatch_async(self.delegateQueue, ^{
        [self.delegate received:message onChannel:self];
    });
}

@end
