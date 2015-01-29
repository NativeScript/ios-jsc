//
//  TNSTestCommon.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/21/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#if defined __cplusplus
extern "C" {
#endif

#define SYSTEM_VERSION_GET ([[UIDevice currentDevice] systemVersion])
#define SYSTEM_VERSION_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

NSMutableString *TNSGetOutput();

void TNSLog(NSString *);

void TNSClearOutput();

void TNSRunScript(NSString *);

void TNSSaveResults(NSString *);

#if defined __cplusplus
}
#endif
