//
//  TNSOutputMessageStream.h
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/27/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNSMessageStreamDelegate.h"

@interface TNSOutputMessageStream : NSObject

@property (nonatomic, weak) id<TNSMessageStreamDelegate> delegate;

- (instancetype) initWithStream:(NSOutputStream*)stream;
- (void) send: (NSString*) message;

- (void) open;
- (void) close;

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

@end
