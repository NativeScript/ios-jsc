//
//  TNSApi.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 3/10/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSApi.h"

NSObject *TNSConstant;

__attribute__((constructor)) static void initialize_TNSConstant() {
    TNSConstant = [[NSObject alloc] init];
}

void functionThrowsException() {
    @throw [NSException exceptionWithName:NSGenericException reason:@"No reason" userInfo:nil];
}

@implementation TNSApi {
    int _property;
}

- (int)customGetter {
    return _property;
}
- (void)customSetter:(int)value {
    _property = value;
}

+ (void)methodThrowsException {
    @throw [NSException exceptionWithName:NSGenericException reason:@"No reason" userInfo:nil];
}

- (void)methodThrowsException {
    @throw [NSException exceptionWithName:NSGenericException reason:@"No reason" userInfo:nil];
}

- (void)methodCalledInDealloc {
    // TODO
    //    [TNSGetOutput() appendString:@"methodCalledInDealloc called"];
}

- (void)dealloc {
    [self methodCalledInDealloc];
}

@end

@implementation TNSConflictingSelectorTypes1
+ (void)method:(long long)x {
}
- (void)method:(long long)x {
}
@end

@implementation TNSConflictingSelectorTypes2
+ (id)method:(id)x {
    return nil;
}
- (id)method:(id)x {
    return nil;
}
@end

@implementation TNSSwizzleKlass : NSObject
+ (int)staticMethod:(int)x {
    return x;
}
- (int)instanceMethod:(int)x {
    return x;
}
@end
