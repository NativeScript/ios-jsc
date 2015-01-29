//
//  TNSPrimitives.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/24/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSPrimitives.h"

char functionWithChar(char x) {
    [TNSGetOutput() appendFormat:@"%hhd", x];
    return x;
}
short functionWithShort(short x) {
    [TNSGetOutput() appendFormat:@"%hd", x];
    return x;
}
int functionWithInt(int x) {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
long functionWithLong(long x) {
    [TNSGetOutput() appendFormat:@"%ld", x];
    return x;
}
long long functionWithLongLong(long long x) {
    [TNSGetOutput() appendFormat:@"%lld", x];
    return x;
}
unsigned char functionWithUChar(unsigned char x) {
    [TNSGetOutput() appendFormat:@"%hhu", x];
    return x;
}
unsigned short functionWithUShort(unsigned short x) {
    [TNSGetOutput() appendFormat:@"%hu", x];
    return x;
}
unsigned int functionWithUInt(unsigned int x) {
    [TNSGetOutput() appendFormat:@"%u", x];
    return x;
}
unsigned long functionWithULong(unsigned long x) {
    [TNSGetOutput() appendFormat:@"%lu", x];
    return x;
}
unsigned long long functionWithULongLong(unsigned long long x) {
    [TNSGetOutput() appendFormat:@"%llu", x];
    return x;
}
float functionWithFloat(float x) {
    [TNSGetOutput() appendFormat:@"%.45f", x];
    return x;
}
double functionWithDouble(double x) {
    [TNSGetOutput() appendFormat:@"%.325f", x];
    return x;
}
_Bool functionWithBool(_Bool x) {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
bool functionWithBool2(bool x) {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
BOOL functionWithBool3(BOOL x) {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
SEL functionWithSelector(SEL x) {
    [TNSGetOutput() appendFormat:@"%@", NSStringFromSelector(x)];
    return x;
}
Class functionWithClass(Class x) {
    [TNSGetOutput() appendFormat:@"%@", NSStringFromClass(x)];
    return x;
}
Protocol *functionWithProtocol(Protocol *x) {
    [TNSGetOutput() appendFormat:@"%@", NSStringFromProtocol(x)];
    return x;
}
NSNull *functionWithNull(NSNull *x) {
    [TNSGetOutput() appendFormat:@"%@", x];
    return x;
}
unichar functionWithUnichar(unichar x) {
    [TNSGetOutput() appendFormat:@"%C", x];
    return x;
}


@implementation TNSPrimitives
+ (char)methodWithChar:(char)x {
    [TNSGetOutput() appendFormat:@"%hhd", x];
    return x;
}
+ (short)methodWithShort:(short)x {
    [TNSGetOutput() appendFormat:@"%hd", x];
    return x;
}
+ (int)methodWithInt:(int)x {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
+ (long)methodWithLong:(long)x {
    [TNSGetOutput() appendFormat:@"%ld", x];
    return x;
}
+ (long long)methodWithLongLong:(long long)x {
    [TNSGetOutput() appendFormat:@"%lld", x];
    return x;
}
+ (unsigned char)methodWithUChar:(unsigned char)x {
    [TNSGetOutput() appendFormat:@"%hhu", x];
    return x;
}
+ (unsigned short)methodWithUShort:(unsigned short)x {
    [TNSGetOutput() appendFormat:@"%hu", x];
    return x;
}
+ (unsigned int)methodWithUInt:(unsigned int)x {
    [TNSGetOutput() appendFormat:@"%u", x];
    return x;
}
+ (unsigned long)methodWithULong:(unsigned long)x {
    [TNSGetOutput() appendFormat:@"%lu", x];
    return x;
}
+ (unsigned long long)methodWithULongLong:(unsigned long long)x {
    [TNSGetOutput() appendFormat:@"%llu", x];
    return x;
}
+ (float)methodWithFloat:(float)x {
    [TNSGetOutput() appendFormat:@"%.45f", x];
    return x;
}
+ (double)methodWithDouble:(double)x {
    [TNSGetOutput() appendFormat:@"%.325f", x];
    return x;
}
+ (_Bool)methodWithBool:(_Bool)x {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
+ (bool)methodWithBool2:(bool)x {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
+ (BOOL)methodWithBool3:(BOOL)x {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
+ (SEL)methodWithSelector:(SEL)x {
    [TNSGetOutput() appendFormat:@"%@", NSStringFromSelector(x)];
    return x;
}
+ (Class)methodWithClass:(Class)x {
    [TNSGetOutput() appendFormat:@"%@", NSStringFromClass(x)];
    return x;
}
+ (Protocol *)methodWithProtocol:(Protocol *)x {
    [TNSGetOutput() appendFormat:@"%@", NSStringFromProtocol(x)];
    return x;
}
+ (NSNull *)methodWithNull:(NSNull *)x {
    [TNSGetOutput() appendFormat:@"%@", NSStringFromClass([x class])];
    return x;
}
+ (unichar)methodWithUnichar:(unichar)x {
    [TNSGetOutput() appendFormat:@"%C", x];
    return x;
}

+ (int)methodVariadicSum:(int)count, ... {
    va_list ap;
    int i, sum;

    va_start(ap, count);

    sum = 0;
    for (i = 0; i < count; i++) {
        sum += va_arg(ap, int);
    }

    va_end(ap);
    return sum;
}


- (char)methodWithChar:(char)x {
    [TNSGetOutput() appendFormat:@"%hhd", x];
    return x;
}
- (short)methodWithShort:(short)x {
    [TNSGetOutput() appendFormat:@"%hd", x];
    return x;
}
- (int)methodWithInt:(int)x {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
- (long)methodWithLong:(long)x {
    [TNSGetOutput() appendFormat:@"%ld", x];
    return x;
}
- (long long)methodWithLongLong:(long long)x {
    [TNSGetOutput() appendFormat:@"%lld", x];
    return x;
}
- (unsigned char)methodWithUChar:(unsigned char)x {
    [TNSGetOutput() appendFormat:@"%hhu", x];
    return x;
}
- (unsigned short)methodWithUShort:(unsigned short)x {
    [TNSGetOutput() appendFormat:@"%hu", x];
    return x;
}
- (unsigned int)methodWithUInt:(unsigned int)x {
    [TNSGetOutput() appendFormat:@"%u", x];
    return x;
}
- (unsigned long)methodWithULong:(unsigned long)x {
    [TNSGetOutput() appendFormat:@"%lu", x];
    return x;
}
- (unsigned long long)methodWithULongLong:(unsigned long long)x {
    [TNSGetOutput() appendFormat:@"%llu", x];
    return x;
}
- (float)methodWithFloat:(float)x {
    [TNSGetOutput() appendFormat:@"%.45f", x];
    return x;
}
- (double)methodWithDouble:(double)x {
    [TNSGetOutput() appendFormat:@"%.325f", x];
    return x;
}
- (_Bool)methodWithBool:(_Bool)x {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
- (bool)methodWithBool2:(bool)x {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
- (BOOL)methodWithBool3:(BOOL)x {
    [TNSGetOutput() appendFormat:@"%d", x];
    return x;
}
- (SEL)methodWithSelector:(SEL)x {
    [TNSGetOutput() appendFormat:@"%@", NSStringFromSelector(x)];
    return x;
}
- (Class)methodWithClass:(Class)x {
    [TNSGetOutput() appendFormat:@"%@", NSStringFromClass(x)];
    return x;
}
- (Protocol *)methodWithProtocol:(Protocol *)x {
    [TNSGetOutput() appendFormat:@"%@", NSStringFromProtocol(x)];
    return x;
}
- (NSNull *)methodWithNull:(NSNull *)x {
    [TNSGetOutput() appendFormat:@"%@", NSStringFromClass([x class])];
    return x;
}
- (unichar)methodWithUnichar:(unichar)x {
    [TNSGetOutput() appendFormat:@"%C", x];
    return x;
}

@end
