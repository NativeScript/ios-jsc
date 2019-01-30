//
//  TNSAllocLog.m
//  NativeScript
//
//  Created by Martin Bekchiev on 1.02.19.
//

#import "TNSAllocLog.h"
#import "../TNSTestCommon.h"

@implementation TNSAllocLog

// Disable ARC for TextFixtures.a and uncomment for debugging puproses
//- (instancetype)retain {
//    return [super retain];
//}
//- (void)release {
//    [super release];
//}

- (instancetype)init {
    TNSLog(@"TNSAllocLog init");
    return [super init];
}

- (void)dealloc {
    TNSLog(@"TNSAllocLog dealloc");
}

@end
