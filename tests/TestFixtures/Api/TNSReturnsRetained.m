//
//  TNSReturnsRetained.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 5/10/15.
//  Copyright (c) 2015 Jason Zhekov. All rights reserved.
//

#import "TNSReturnsRetained.h"

id functionReturnsNSRetained() {
    return [[NSObject alloc] init];
}
id functionReturnsCFRetained() {
    return [[NSObject alloc] init];
}
id functionImplicitCreateNSObject() {
    return [[NSObject alloc] init];
}
id functionExplicitCreateNSObject() {
    return [[NSObject alloc] init];
}

@implementation TNSReturnsRetained
+ (id)methodReturnsNSRetained {
    return [[NSObject alloc] init];
}
+ (id)methodReturnsCFRetained {
    return [[NSObject alloc] init];
}
+ (id)newNSObjectMethod {
    return [[TNSReturnsRetained alloc] init];
}
@end
