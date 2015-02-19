//
//  TNSWebSocketMessagingServer.h
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/27/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNSDebugMessaging.h"

@interface TNSWebSocketMessagingServer : NSObject<TNSDebugMessagingChannel>

@property (nonatomic, weak) id<TNSDebugMessagingChannelDelegate> delegate;

- (instancetype) initWithPort: (NSUInteger) port;

@end
