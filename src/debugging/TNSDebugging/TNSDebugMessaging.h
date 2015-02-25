//
//  TNSDebugging.h
//  TNSDebugging
//
//  Created by Ivan Buhov on 10/10/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <NativeScript/NativeScript.h>

@protocol TNSDebugMessagingChannelDelegate

- (void)connected:(id)channel;
- (void)disconnected:(id)channel;

- (void)received:(NSString*)message onChannel:(id)channel;

@end

@protocol TNSDebugMessagingChannel

@property(nonatomic, weak) id<TNSDebugMessagingChannelDelegate> delegate;

- (void)send:(NSString*)message;

- (void)open;
- (void)close;

@end
