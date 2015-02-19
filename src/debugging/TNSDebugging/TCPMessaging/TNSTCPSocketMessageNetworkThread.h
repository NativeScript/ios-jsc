//
//  TNSRuntimeTCPSocketNetworkThread.h
//  TNSApp
//
//  Created by Panayot Cankov on 1/14/15.
//  Copyright (c) 2015 TNS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNSTCPSocketMessageNetworkThread : NSThread

#pragma mark - Singleton

+ (instancetype)sharedNetworkThread;

#pragma mark - Properties

@property(nonatomic, strong, readonly) NSRunLoop* runLoop;

@end
