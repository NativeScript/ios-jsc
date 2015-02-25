//
//  TNSWebSocketDebugConnectionProtocol.h
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/20/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <NativeScript/NativeScript.h>
#import "TNSDebugMessaging.h"

@interface TNSDebugServer : NSObject

- (instancetype)initWithRuntime:(TNSRuntime*)runtime
                           name:(NSString*)name
               messagingChannel:(id<TNSDebugMessagingChannel>)channel;

@end
