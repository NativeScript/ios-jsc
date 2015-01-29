//
//  TNSObjCTypes.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/25/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSObjCTypes.h"

void TNSFunctionWithCFTypeRefArgument(CFTypeRef x) {
    NSString *str = (__bridge NSString *)x;
    [TNSGetOutput() appendFormat:@"%@", str];
}

CFTypeRef TNSFunctionWithSimpleCFTypeRefReturn() {
    NSString *str = @"test";
    return (__bridge CFTypeRef)(str);
}

CFTypeRef TNSFunctionWithCreateCFTypeRefReturn() {
    NSString *str = @"test";
    CFBridgingRetain(str);
    return (__bridge CFTypeRef)(str);
}

@implementation TNSObjCTypes
+ (void)methodWithComplexBlock:(id (^)(int, id, SEL, NSObject *, TNSOStruct))block {
    TNSOStruct str = {5, 6, 7};
    id result = block(1, @2, @selector(init), @[ @3, @4 ], str);
    [TNSGetOutput() appendFormat:@"\n%@", NSStringFromClass([result class])];
}

- (void)methodWithIdOutParameter:(NSString **)value {
    [TNSGetOutput() appendFormat:@"%@", *value];
    *value = @"test";
}

- (void)methodWithLongLongOutParameter:(long long *)value {
    [TNSGetOutput() appendFormat:@"%lld", *value];
    *value = 1;
}

- (void)methodWithStructOutParameter:(TNSOStruct *)value {
    [TNSGetOutput() appendFormat:@"%d %d %d", value->x, value->y, value->z];
    *value = (TNSOStruct) {4, 5, 6};
}

- (void)methodWithSimpleBlock:(void (^)(void))block {
    block();
}

- (void)methodWithComplexBlock:(id (^)(int, id, SEL, NSObject *, TNSOStruct))block {
    TNSOStruct str = {5, 6, 7};
    id result = block(1, @2, @selector(init), @[ @3, @4 ], str);
    [TNSGetOutput() appendFormat:@"\n%@", NSStringFromClass([result class])];
}

- (NumberReturner)methodWithBlockScope:(int)number {
    return ^(int a, int b, int c) {
        return (number + a + b + c);
    };
}

- (id)methodReturningBlockAsId:(int)number {
    return ^(int a, int b, int c) {
        return (number + a + b + c);
    };
}

- (NSArray *)methodWithNSArray:(NSArray *)array {
    for (id x in array) {
        [TNSGetOutput() appendFormat:@"%@", x];
    }
    return array;
}

- (NSData *)methodWithNSData:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [TNSGetOutput() appendString:string];
    return data;
}

- (NSNumber *)methodWithNSCFBool {
    return @YES;
}

- (NSNull *)methodWithNSNull {
    return [NSNull null];
}

@end
