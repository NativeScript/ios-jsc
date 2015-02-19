//
//  TNSRuntimeTCPSocketNetworkThread.n
//  TNSApp
//
//  Created by Panayot Cankov on 1/14/15.
//  Copyright (c) 2015 TNS. All rights reserved.
//

#import "TNSTCPSocketMessageNetworkThread.h"

@interface TNSTCPSocketMessageNetworkThread () {
    dispatch_group_t _waitGroup;
}

@property(nonatomic, strong) NSRunLoop* runLoop;

@end
@implementation TNSTCPSocketMessageNetworkThread

#pragma mark - Singleton

+ (instancetype)sharedNetworkThread {
    static id sharedNetworkThread = nil;
    static dispatch_once_t sharedNetworkThreadOnce = 0;
    dispatch_once(&sharedNetworkThreadOnce, ^{
		sharedNetworkThread = [[self alloc] init];
    });
    return sharedNetworkThread;
}

#pragma mark - Properties

- (NSRunLoop*)runLoop {
    dispatch_group_wait(_waitGroup, DISPATCH_TIME_FOREVER);
    return _runLoop;
}

#pragma mark - Initialization

- (instancetype)init {
    if ((self = [super init])) {
        _waitGroup = dispatch_group_create();
        dispatch_group_enter(_waitGroup);

        [self start];
    }

    return self;
}

- (void)main {
    @autoreleasepool {
        _runLoop = [NSRunLoop currentRunLoop];
        dispatch_group_leave(_waitGroup);

        NSTimer* timer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture]
                                                  interval:0.0
                                                    target:nil
                                                  selector:nil
                                                  userInfo:nil
                                                   repeats:NO];
        [_runLoop addTimer:timer
                   forMode:NSDefaultRunLoopMode];

        NSRunLoop* runLoop = _runLoop;
        while ([runLoop runMode:NSDefaultRunLoopMode
                     beforeDate:[NSDate distantFuture]]) {
            // no-op
        }
        [NSException raise:NSInternalInconsistencyException
                    format:@"TNSTCPSocketMessageNetworkThread should never exit."];
    }
}

@end
