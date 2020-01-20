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

+ (int)staticBaseImplementedOptionalProperty {
    return -1;
}

+ (void)setStaticBaseImplementedOptionalProperty:(int)x {
}

+ (void)staticBaseImplementedOptionalMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}

@synthesize baseImplementedOptionalProperty;

- (void)baseImplementedOptionalMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation TNSIBaseInterface (TNSIBaseCategory)
+ (void)staticBaseImplementedCategoryMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}

- (void)baseImplementedCategoryMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}
@end

@implementation TNSIDerivedInterface
+ (int)staticDerivedImplementedOptionalProperty {
    return -1;
}

+ (void)setStaticDerivedImplementedOptionalProperty:(int)x {
}

@synthesize derivedImplementedOptionalProperty;

+ (void)staticDerivedImplementedOptionalMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}

- (void)derivedImplementedOptionalMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}

@end

@implementation TNSIDerivedInterface (TNSIDerivedCategory)
+ (void)staticDerivedImplementedCategoryMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}

- (void)derivedImplementedCategoryMethod {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
}
@end
#pragma clang diagnostic pop

@implementation TNSIterableConsumer

+ (void)consumeIterable:(id<NSFastEnumeration>)iterable {
    for (id obj in iterable) {
        TNSLog([obj description]);
    }
}

@end

/////////////////////////////////////////////////////////////////////////
/// TNSIBaseProtocolImpl_Private

@interface TNSIBaseProtocolImpl_Private : NSObject <TNSIBaseProtocol>
@end

@implementation TNSIBaseProtocolImpl_Private

+ (int)staticBaseImplementedOptionalProperty {
    return -100;
}

+ (void)setStaticBaseImplementedOptionalProperty:(int)x {
    TNSLog([NSString stringWithFormat:@"private %@ called with %d", NSStringFromSelector(_cmd), x]);
}

+ (void)staticBaseImplementedOptionalMethod {
    TNSLog([NSString stringWithFormat:@"private %@ called", NSStringFromSelector(_cmd)]);
}

- (int)baseImplementedOptionalProperty {
    return -100;
}

- (void)setBaseImplementedOptionalProperty:(int)x {
    TNSLog([NSString stringWithFormat:@"private %@ called with %d", NSStringFromSelector(_cmd), x]);
}

- (void)baseImplementedOptionalMethod {
    TNSLog([NSString stringWithFormat:@"private %@ called", NSStringFromSelector(_cmd)]);
}

@end

/////////////////////////////////////////////////////////////////////////
/// TNSIBaseInterface_Private

@interface TNSIBaseInterface_Private : TNSIBaseInterface
@end

@implementation TNSIBaseInterface_Private

+ (int)staticBaseImplementedOptionalProperty {
    return -200;
}

+ (void)setStaticBaseImplementedOptionalProperty:(int)x {
    TNSLog([NSString stringWithFormat:@"private2 %@ called with %d", NSStringFromSelector(_cmd), x]);
}

+ (void)staticBaseImplementedOptionalMethod {
    TNSLog([NSString stringWithFormat:@"private2 %@ called", NSStringFromSelector(_cmd)]);
}

- (int)baseImplementedOptionalProperty {
    return -200;
}

- (void)setBaseImplementedOptionalProperty:(int)x {
    TNSLog([NSString stringWithFormat:@"private2 %@ called with %d", NSStringFromSelector(_cmd), x]);
}

- (void)baseImplementedOptionalMethod {
    TNSLog([NSString stringWithFormat:@"private2 %@ called", NSStringFromSelector(_cmd)]);
}

@end

/////////////////////////////////////////////////////////////////////////
/// TNSPrivateInterfaceResults

@implementation TNSPrivateInterfaceResults

+ (TNSIBaseInterface*)instanceFromUnrelatedPrivateType {
    return (TNSIBaseInterface*)[TNSIBaseProtocolImpl_Private new];
}

+ (id<TNSIBaseProtocol>)instanceFromPrivateTypeImplementingProtocol {
    return [TNSIBaseInterface_Private new];
}

+ (id<TNSIBaseProtocol, TNSIDerivedProtocol>)instanceFromPrivateTypeImplementingTwoProtocols {
    return (id<TNSIBaseProtocol, TNSIDerivedProtocol>)[TNSIBaseInterface_Private new];
}

+ (id<TNSIBaseProtocol>)instanceFromPublicTypeImplementingProtocol {
    return [TNSIBaseInterface new];
}

@end

@implementation TNSBlacklistedInterface
@end
