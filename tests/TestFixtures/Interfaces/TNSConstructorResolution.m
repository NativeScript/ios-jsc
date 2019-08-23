//
//  TNSConstructorResolution.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/24/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSConstructorResolution.h"

@implementation TNSCInterface
- (id)init {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
    return [super init];
}

- (id)initWithEmpty {
    TNSLog([NSString stringWithFormat:@"%@ called", NSStringFromSelector(_cmd)]);
    return [super init];
}

- (id)initWithPrimitive:(int)x {
    TNSLog([NSString stringWithFormat:@"%@%d called", NSStringFromSelector(_cmd), x]);
    return [super init];
}
- (id)initWithStructure:(TNSCStructure)x {
    TNSLog([NSString stringWithFormat:@"%@%d.%d called", NSStringFromSelector(_cmd), x.x, x.y]);
    return [super init];
}
- (id)initWithString:(NSString*)x {
    TNSLog([NSString stringWithFormat:@"%@%@ called", NSStringFromSelector(_cmd), x]);
    return [super init];
}
- (id)initWithParameter1:(NSString*)x parameter2:(NSString*)y error:(NSError**)error {
    TNSLog([NSString stringWithFormat:@"%@ %@ %@ called", NSStringFromSelector(_cmd), x, y]);
    if (error) {
        *error = [NSError errorWithDomain:@"TNSErrorDomain" code:1 userInfo:nil];
    }
    return [super init];
}

- (id)initWithInt:(int)x andInt:(int)y {
    TNSLog([NSString stringWithFormat:@"%@ %d %d called", NSStringFromSelector(_cmd), x, y]);
    return [super init];
}

- (id)initWithStringOptional:(NSString*)x andString:(NSString*)y {
    TNSLog([NSString stringWithFormat:@"%@ %@ %@ called", NSStringFromSelector(_cmd), x, y]);
    return [super init];
}

- (id)initWithConflict1:(NSString*)x conflict2:(NSString*)y conflict3:(NSString*)z {
    return [super init];
}

- (id)initWithConflict1_:(NSString*)x conflict2_:(NSString*)y conflict3_:(NSString*)z {
    return [super init];
}

@end
