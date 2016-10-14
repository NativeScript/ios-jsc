//
//  TNSRuntime.h
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#import <Foundation/NSObjCRuntime.h>
#import <JavaScriptCore/JSBase.h>

typedef void (*TNSUncaughtErrorHandler)(JSContextRef ctx, JSValueRef error);

FOUNDATION_EXTERN void TNSSetUncaughtErrorHandler(TNSUncaughtErrorHandler handler);

@interface TNSRuntime : NSObject

@property(nonatomic, readonly) uint32_t threadId;

@property(nonatomic, retain, readonly) NSString* applicationPath;

+ (void)initializeMetadata:(void*)metadataPtr;

+ (TNSRuntime*)current;

- (instancetype)initWithApplicationPath:(NSString*)applicationPath;

- (void)scheduleInRunLoop:(NSRunLoop*)runLoop forMode:(NSString*)mode;

- (void)removeFromRunLoop:(NSRunLoop*)runLoop forMode:(NSString*)mode;

- (JSGlobalContextRef)globalContext;

- (void)executeModule:(NSString*)entryPointModuleIdentifier;

- (void)executeModule:(NSString*)entryPointModuleIdentifier referredBy:(NSString*)referer;

- (JSValueRef)convertObject:(id)object;
@end

@interface TNSWorkerRuntime : TNSRuntime
@end