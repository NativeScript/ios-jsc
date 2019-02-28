//
//  TNSVersions.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 21/08/15.
//  Copyright (c) 2015 Jason Zhekov. All rights reserved.
//

#define generateVersionImpl
#import "TNSVersions.h"
#undef generateVersionImpl

@implementation TNSInterfaceAlwaysAvailable
@end

@implementation TNSInterfaceNeverAvailable : TNSInterfaceAlwaysAvailable
@end

@implementation TNSInterfaceNeverAvailableDescendant : TNSInterfaceNeverAvailable
@end
