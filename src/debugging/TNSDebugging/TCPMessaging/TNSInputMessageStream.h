//
//  TNSOutputMessageStream.h
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/27/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNSMessageStreamDelegate.h"

@interface TNSInputMessageStream : NSObject

@property(nonatomic, weak) id<TNSMessageStreamDelegate> delegate;

- (instancetype)initWithStream:(NSInputStream*)stream;

- (void)open;
- (void)close;

- (void)scheduleInRunLoop:(NSRunLoop*)aRunLoop forMode:(NSString*)mode;
- (void)removeFromRunLoop:(NSRunLoop*)aRunLoop forMode:(NSString*)mode;

@end
