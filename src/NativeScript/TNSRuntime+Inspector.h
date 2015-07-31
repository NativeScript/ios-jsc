//
//  TNSRuntime+Inspector.h
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#import "TNSRuntime.h"
#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString* const TNSInspectorRunLoopMode;

@interface TNSRuntimeInspector : NSObject

+ (BOOL)logsToSystemConsole;
+ (void)setLogsToSystemConsole:(BOOL)shouldLog;

- (void)dispatchMessage:(NSString*)message;

- (void)reportFatalError:(JSValueRef)error __attribute__((noreturn));

- (void)pause;

@end

typedef void (^TNSRuntimeInspectorMessageHandler)(NSString* message);

@interface TNSRuntime (Inspector)

- (TNSRuntimeInspector*)attachInspectorWithHandler:(TNSRuntimeInspectorMessageHandler)messageHandler;

@end
