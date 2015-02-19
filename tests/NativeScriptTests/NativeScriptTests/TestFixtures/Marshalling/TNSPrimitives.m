//
//  TNSPrimitives.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/24/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSPrimitives.h"

char functionWithChar(char x) {
    TNSLog([NSString stringWithFormat:@"%hhd", x]);
    return x;
}
short functionWithShort(short x) {
    TNSLog([NSString stringWithFormat:@"%hd", x]);
    return x;
}
int functionWithInt(int x) {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
long functionWithLong(long x) {
    TNSLog([NSString stringWithFormat:@"%ld", x]);
    return x;
}
long long functionWithLongLong(long long x) {
    TNSLog([NSString stringWithFormat:@"%lld", x]);
    return x;
}
unsigned char functionWithUChar(unsigned char x) {
    TNSLog([NSString stringWithFormat:@"%hhu", x]);
    return x;
}
unsigned short functionWithUShort(unsigned short x) {
    TNSLog([NSString stringWithFormat:@"%hu", x]);
    return x;
}
unsigned int functionWithUInt(unsigned int x) {
    TNSLog([NSString stringWithFormat:@"%u", x]);
    return x;
}
unsigned long functionWithULong(unsigned long x) {
    TNSLog([NSString stringWithFormat:@"%lu", x]);
    return x;
}
unsigned long long functionWithULongLong(unsigned long long x) {
    TNSLog([NSString stringWithFormat:@"%llu", x]);
    return x;
}
float functionWithFloat(float x) {
    TNSLog([NSString stringWithFormat:@"%.45f", x]);
    return x;
}
double functionWithDouble(double x) {
    TNSLog([NSString stringWithFormat:@"%.325f", x]);
    return x;
}
_Bool functionWithBool(_Bool x) {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
bool functionWithBool2(bool x) {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
BOOL functionWithBool3(BOOL x) {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
SEL functionWithSelector(SEL x) {
    TNSLog([NSString stringWithFormat:@"%@", NSStringFromSelector(x)]);
    return x;
}
Class functionWithClass(Class x) {
    TNSLog([NSString stringWithFormat:@"%@", NSStringFromClass(x)]);
    return x;
}
Protocol *functionWithProtocol(Protocol *x) {
    TNSLog([NSString stringWithFormat:@"%@", NSStringFromProtocol(x)]);
    return x;
}
NSNull *functionWithNull(NSNull *x) {
    TNSLog([NSString stringWithFormat:@"%@", x]);
    return x;
}
unichar functionWithUnichar(unichar x) {
    TNSLog([NSString stringWithFormat:@"%C", x]);
    return x;
}


@implementation TNSPrimitives
+ (char)methodWithChar:(char)x {
    TNSLog([NSString stringWithFormat:@"%hhd", x]);
    return x;
}
+ (short)methodWithShort:(short)x {
    TNSLog([NSString stringWithFormat:@"%hd", x]);
    return x;
}
+ (int)methodWithInt:(int)x {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
+ (long)methodWithLong:(long)x {
    TNSLog([NSString stringWithFormat:@"%ld", x]);
    return x;
}
+ (long long)methodWithLongLong:(long long)x {
    TNSLog([NSString stringWithFormat:@"%lld", x]);
    return x;
}
+ (unsigned char)methodWithUChar:(unsigned char)x {
    TNSLog([NSString stringWithFormat:@"%hhu", x]);
    return x;
}
+ (unsigned short)methodWithUShort:(unsigned short)x {
    TNSLog([NSString stringWithFormat:@"%hu", x]);
    return x;
}
+ (unsigned int)methodWithUInt:(unsigned int)x {
    TNSLog([NSString stringWithFormat:@"%u", x]);
    return x;
}
+ (unsigned long)methodWithULong:(unsigned long)x {
    TNSLog([NSString stringWithFormat:@"%lu", x]);
    return x;
}
+ (unsigned long long)methodWithULongLong:(unsigned long long)x {
    TNSLog([NSString stringWithFormat:@"%llu", x]);
    return x;
}
+ (float)methodWithFloat:(float)x {
    TNSLog([NSString stringWithFormat:@"%.45f", x]);
    return x;
}
+ (double)methodWithDouble:(double)x {
    TNSLog([NSString stringWithFormat:@"%.325f", x]);
    return x;
}
+ (_Bool)methodWithBool:(_Bool)x {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
+ (bool)methodWithBool2:(bool)x {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
+ (BOOL)methodWithBool3:(BOOL)x {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
+ (SEL)methodWithSelector:(SEL)x {
    TNSLog([NSString stringWithFormat:@"%@", NSStringFromSelector(x)]);
    return x;
}
+ (Class)methodWithClass:(Class)x {
    TNSLog([NSString stringWithFormat:@"%@", NSStringFromClass(x)]);
    return x;
}
+ (Protocol *)methodWithProtocol:(Protocol *)x {
    TNSLog([NSString stringWithFormat:@"%@", NSStringFromProtocol(x)]);
    return x;
}
+ (NSNull *)methodWithNull:(NSNull *)x {
    TNSLog([NSString stringWithFormat:@"%@", NSStringFromClass([x class])]);
    return x;
}
+ (unichar)methodWithUnichar:(unichar)x {
    TNSLog([NSString stringWithFormat:@"%C", x]);
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
    TNSLog([NSString stringWithFormat:@"%hhd", x]);
    return x;
}
- (short)methodWithShort:(short)x {
    TNSLog([NSString stringWithFormat:@"%hd", x]);
    return x;
}
- (int)methodWithInt:(int)x {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
- (long)methodWithLong:(long)x {
    TNSLog([NSString stringWithFormat:@"%ld", x]);
    return x;
}
- (long long)methodWithLongLong:(long long)x {
    TNSLog([NSString stringWithFormat:@"%lld", x]);
    return x;
}
- (unsigned char)methodWithUChar:(unsigned char)x {
    TNSLog([NSString stringWithFormat:@"%hhu", x]);
    return x;
}
- (unsigned short)methodWithUShort:(unsigned short)x {
    TNSLog([NSString stringWithFormat:@"%hu", x]);
    return x;
}
- (unsigned int)methodWithUInt:(unsigned int)x {
    TNSLog([NSString stringWithFormat:@"%u", x]);
    return x;
}
- (unsigned long)methodWithULong:(unsigned long)x {
    TNSLog([NSString stringWithFormat:@"%lu", x]);
    return x;
}
- (unsigned long long)methodWithULongLong:(unsigned long long)x {
    TNSLog([NSString stringWithFormat:@"%llu", x]);
    return x;
}
- (float)methodWithFloat:(float)x {
    TNSLog([NSString stringWithFormat:@"%.45f", x]);
    return x;
}
- (double)methodWithDouble:(double)x {
    TNSLog([NSString stringWithFormat:@"%.325f", x]);
    return x;
}
- (_Bool)methodWithBool:(_Bool)x {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
- (bool)methodWithBool2:(bool)x {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
- (BOOL)methodWithBool3:(BOOL)x {
    TNSLog([NSString stringWithFormat:@"%d", x]);
    return x;
}
- (SEL)methodWithSelector:(SEL)x {
    TNSLog([NSString stringWithFormat:@"%@", NSStringFromSelector(x)]);
    return x;
}
- (Class)methodWithClass:(Class)x {
    TNSLog([NSString stringWithFormat:@"%@", NSStringFromClass(x)]);
    return x;
}
- (Protocol *)methodWithProtocol:(Protocol *)x {
    TNSLog([NSString stringWithFormat:@"%@", NSStringFromProtocol(x)]);
    return x;
}
- (NSNull *)methodWithNull:(NSNull *)x {
    TNSLog([NSString stringWithFormat:@"%@", NSStringFromClass([x class])]);
    return x;
}
- (unichar)methodWithUnichar:(unichar)x {
    TNSLog([NSString stringWithFormat:@"%C", x]);
    return x;
}

@end
