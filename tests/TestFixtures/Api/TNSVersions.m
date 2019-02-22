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

#pragma clang diagnostic push
// Ignore warnings about not implemented required protocol members.
// Those coming from TNSProtocolNeverAvailable are intentionally left unimplemented
#pragma clang diagnostic ignored "-Wobjc-protocol-property-synthesis"
#pragma clang diagnostic ignored "-Wobjc-property-implementation"
#pragma clang diagnostic ignored "-Wprotocol"

@implementation TNSInterfaceAlwaysAvailable

+ (int)staticPropertyFromProtocolAlwaysAvailable {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
    return 12;
}

+ (int)staticPropertyFromProtocolNeverAvailable {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
    return 23;
}

+ (void)staticMethodFromProtocolAlwaysAvailable {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}

+ (void)staticMethodFromProtocolNeverAvailable {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}

@synthesize propertyFromProtocolAlwaysAvailable;
@synthesize propertyFromProtocolNeverAvailable;

- (void)methodFromProtocolAlwaysAvailable {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}

- (void)methodFromProtocolNeverAvailable {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}

@end

@implementation TNSInterfaceNeverAvailable : TNSInterfaceAlwaysAvailable
@end

@implementation TNSInterfaceNeverAvailableDescendant : TNSInterfaceNeverAvailable
@end

#pragma clang diagnostic pop
