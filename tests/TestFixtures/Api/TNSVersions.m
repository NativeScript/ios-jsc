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

@implementation TNSInterfaceAlwaysAvailable (AvailableAfter1_0)

- (void)availableStaticMethod1_0 {
}

- (void)explicitlyUnvailableStaticMethod {
}

+ (void)availableMethod1_0 {
}

- (void)explicitlyUnvailableMethod {
}

@end

@implementation TNSInterfaceAlwaysAvailable (NeverAvailable)

- (void)unavailableStaticMethod {
}

- (void)explicitlyAvailableStaticMethod1_0 {
}

+ (void)unavailableMethod {
}

- (void)explicitlyAvailableMethod1_0 {
}

@end
