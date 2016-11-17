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

bool TNSIsConfigurationDebug;

NSString* TNSGetOutput();

void TNSLog(NSString*);

void TNSClearOutput();

void TNSSaveResults(NSString*);

#if defined __cplusplus
}
#endif
