//
//  TNSInheritance.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/26/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSInheritance.h"

@implementation TNSIConstructorVirtualCalls

- (id)initWithX:(int)x andY:(int)y {
    TNSLog([NSString stringWithFormat:@"constructor initWithX:%dandY:%d called", x, y]);

    if (self = [super init]) {
        _x = x;
        _y = y;
    }

    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"x: %d; y: %d", _x, _y];
}

@end

@implementation TNSIBaseInterface
- (void)baseImplementedOptionalMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}
@end

@implementation TNSIBaseInterface (TNSIBaseCategory)
- (void)baseImplementedCategoryMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}
@end

@implementation TNSIDerivedInterface
- (void)derivedImplementedOptionalMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}
@end

@implementation TNSIDerivedInterface (TNSIDerivedCategory)
- (void)derivedImplementedCategoryMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}
@end