//
//  TNSRuntimeInspector.h
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#import "TNSRuntime.h"

@interface TNSRuntimeInspector : NSObject

+ (BOOL)logsToSystemConsole;
+ (void)setLogsToSystemConsole:(BOOL)shouldLog;

- (void)dispatchMessage:(NSString*)message;

@end

typedef BOOL (^TNSRuntimeInspectorMessageHandler)(NSString* message);

@interface TNSRuntime (Inspector)

- (TNSRuntimeInspector*)attachInspectorWithHandler:(TNSRuntimeInspectorMessageHandler)handler;

@end
