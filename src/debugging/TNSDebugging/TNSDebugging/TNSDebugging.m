//
//  TNSDebugging.m
//  TNSDebugging
//
//  Created by Ivan Buhov on 10/10/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#import "TNSDebugging.h"
#import <PocketSocket/PSWebSocketServer.h>

@interface TNSRuntimeWebSocketServerDelegate : NSObject <PSWebSocketServerDelegate>

- (instancetype)initWithRuntime:(TNSRuntime*)runtime port:(NSUInteger)port;

@end

@implementation TNSRuntimeWebSocketServerDelegate {
    TNSRuntime* _runtime;
    TNSRuntimeInspector* _inspector;
    PSWebSocketServer* _server;
}

- (instancetype)initWithRuntime:(TNSRuntime*)runtime port:(NSUInteger)port {
    if (self = [super init]) {
        self->_runtime = runtime;
        self->_server = [PSWebSocketServer serverWithHost:nil
                                                     port:port];
        self->_server.delegate = self;
        self->_server.delegateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        [self->_server start];
    }

    return self;
}

- (void)serverDidStart:(PSWebSocketServer*)server {
    NSLog(@"Waiting for debugger...");
}

- (void)serverDidStop:(PSWebSocketServer*)server {
}

- (BOOL)server:(PSWebSocketServer*)server acceptWebSocketWithRequest:(NSURLRequest*)request {
    return self->_inspector == nil;
}

- (void)server:(PSWebSocketServer*)server webSocketDidOpen:(PSWebSocket*)webSocket {
    webSocket.delegateQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_inspector = [self->_runtime attachInspectorWithHandler:^BOOL(NSString *message) {
            [webSocket send:message];
            return YES;
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CFRunLoopStop(CFRunLoopGetMain());
        });
    });
}
- (void)server:(PSWebSocketServer*)server webSocket:(PSWebSocket*)webSocket didReceiveMessage:(id)message {
    const void* runLoopModes[] = { kCFRunLoopCommonModes, CFSTR("com.apple.JavaScriptCore.remote-inspector-runloop-mode") };
    CFArrayRef modes = CFArrayCreate(kCFAllocatorDefault, runLoopModes, 2, &kCFTypeArrayCallBacks);
    CFRunLoopPerformBlock(CFRunLoopGetMain(), modes, ^{
        [self->_inspector dispatchMessage:message];
    });
    CFRunLoopWakeUp(CFRunLoopGetMain());
}

- (void)server:(PSWebSocketServer*)server webSocket:(PSWebSocket*)webSocket didFailWithError:(NSError*)error {
    self->_inspector = nil;
}

- (void)server:(PSWebSocketServer*)server webSocket:(PSWebSocket*)webSocket didCloseWithCode:(NSInteger)code reason:(NSString*)reason wasClean:(BOOL)wasClean {
    self->_inspector = nil;
}

@end

@implementation TNSRuntime (WebSocketDebugging)

- (id)startWebSocketServerOnPort:(NSUInteger)port {
    return [[TNSRuntimeWebSocketServerDelegate alloc] initWithRuntime:self
                                                                 port:port];
}

@end
