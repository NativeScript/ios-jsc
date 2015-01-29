//
//  TNSConstructorResolution.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/24/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSConstructorResolution.h"

@implementation TNSCInterface11
@end

@implementation TNSCInterface
- (id)init {
    [TNSGetOutput() appendFormat:@"%@ called", NSStringFromSelector(_cmd)];
    return [super init];
}

- (id)initWithPrimitive:(int)x {
    [TNSGetOutput() appendFormat:@"%@%d called", NSStringFromSelector(_cmd), x];
    return [super init];
}
- (id)initWithInterface:(TNSCInterface11 *)x {
    [TNSGetOutput() appendFormat:@"%@ called", NSStringFromSelector(_cmd)];
    return [super init];
}
- (id)initWithStructure:(TNSCStructure)x {
    [TNSGetOutput() appendFormat:@"%@%d.%d called", NSStringFromSelector(_cmd), x.x, x.y];
    return [super init];
}
- (id)initWithProtocol:(id<TNSCProtocol1>)x {
    NSAssert(x, @"");
    BOOL isConforming = [[(NSObject *)x class] conformsToProtocol:@protocol(TNSCProtocol1)];
    NSAssert(isConforming, @"");
    [TNSGetOutput() appendFormat:@"%@ called", NSStringFromSelector(_cmd)];
    return [super init];
}
- (id)initWithString:(NSString *)x {
    [TNSGetOutput() appendFormat:@"%@%@ called", NSStringFromSelector(_cmd), x];
    return [super init];
}
- (id)initWithPrimitive:(int)x instance:(TNSCInterface11 *)y structure:(TNSCStructure)z protocol:(id<TNSCProtocol1>)a string:(NSString *)b number:(NSNumber *)c {
    [TNSGetOutput() appendFormat:@"%@ called", NSStringFromSelector(_cmd)];
    return [super init];
}
@end
