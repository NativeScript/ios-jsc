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
    [TNSGetOutput() appendFormat:@"constructor initWithX:%dandY:%d called", x, y];

    if (self = [super init]) {
        _x = x;
        _y = y;
    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"x: %d; y: %d", _x, _y];
}

@end



@implementation TNSIBaseInterface
- (void)baseImplementedOptionalMethod {
    [TNSGetOutput() appendFormat:@"%@ called", NSStringFromSelector(_cmd)];
}
@end

@implementation TNSIBaseInterface (TNSIBaseCategory)
- (void)baseImplementedCategoryMethod {
    [TNSGetOutput() appendFormat:@"%@ called", NSStringFromSelector(_cmd)];
}
@end

@implementation TNSIDerivedInterface
- (void)derivedImplementedOptionalMethod {
    [TNSGetOutput() appendFormat:@"%@ called", NSStringFromSelector(_cmd)];
}
@end

@implementation TNSIDerivedInterface (TNSIDerivedCategory)
- (void)derivedImplementedCategoryMethod {
    [TNSGetOutput() appendFormat:@"%@ called", NSStringFromSelector(_cmd)];
}
@end