//
//  TNSRuntime.h
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#import <JavaScriptCore/JSBase.h>
#import <Foundation/NSObjCRuntime.h>

typedef void (*TNSUncaughtErrorHandler)(JSContextRef ctx, JSValueRef error);

FOUNDATION_EXTERN void TNSSetUncaughtErrorHandler(TNSUncaughtErrorHandler handler);

@interface TNSRuntime : NSObject

@property(nonatomic, retain) NSString* applicationPath;

- (instancetype)initWithApplicationPath:(NSString*)applicationPath;

- (JSGlobalContextRef)globalContext;

- (void)executeModule:(NSString*)entryPointModuleIdentifier;

@end