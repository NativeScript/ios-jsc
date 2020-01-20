//
//  TNSFunctions.m
//  NativeScriptTests
//
//  Created by Yavor Georgiev on 25.02.14.
//  Copyright (c) 2014 г. Jason Zhekov. All rights reserved.
//

#import "TNSFunctions.h"

CFArrayRef CFArrayCreateWithString(CFStringRef string) {
    const void* values[] = { string };
    return CFArrayCreate(kCFAllocatorDefault, values, 1, &kCFTypeArrayCallBacks);
}

struct rusage_info_v0 getBlacklistedRusage_info_v0() {
    struct rusage_info_v0 ret = { { 0 }, 1, 100, 1000, 0, 0, 0, 0, 0, 0, 0 };

    return ret;
}

TNSBlacklistedInterface<TNSBlacklistedProtocol>* getTNSBlacklisted() {
    return [TNSBlacklistedInterface new];
}

BOOL funcWithTNSBlacklisted(TNSBlacklistedInterface* arg) {
    return [arg isKindOfClass:[TNSBlacklistedInterface class]];
}
