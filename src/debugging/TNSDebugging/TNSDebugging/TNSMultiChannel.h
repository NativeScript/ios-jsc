//
//  TNSMultiChannel.h
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/29/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNSDebugMessaging.h"

@interface TNSMultiChannel : NSObject <TNSDebugMessagingChannel>

@property (nonatomic, weak) id<TNSDebugMessagingChannelDelegate> delegate;

- (instancetype) initWithSubchannels: (id<TNSDebugMessagingChannel>)channel, ... NS_REQUIRES_NIL_TERMINATION;

@end
