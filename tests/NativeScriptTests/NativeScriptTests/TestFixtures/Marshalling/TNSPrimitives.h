//
//  TNSPrimitives.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/24/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSRecords.h"

char functionWithChar(char x);
short functionWithShort(short x);
int functionWithInt(int x);
long functionWithLong(long x);
long long functionWithLongLong(long long x);
unsigned char functionWithUChar(unsigned char x);
unsigned short functionWithUShort(unsigned short x);
unsigned int functionWithUInt(unsigned int x);
unsigned long functionWithULong(unsigned long x);
unsigned long long functionWithULongLong(unsigned long long x);
float functionWithFloat(float x);
double functionWithDouble(double x);
_Bool functionWithBool(_Bool x);
bool functionWithBool2(bool x);
BOOL functionWithBool3(BOOL x);
SEL functionWithSelector(SEL x);
Class functionWithClass(Class x);
Protocol *functionWithProtocol(Protocol *x);
NSNull *functionWithNull(NSNull *x);
unichar functionWithUnichar(unichar x);

@interface TNSPrimitives : NSObject
+ (char)methodWithChar:(char)x;
+ (short)methodWithShort:(short)x;
+ (int)methodWithInt:(int)x;
+ (long)methodWithLong:(long)x;
+ (long long)methodWithLongLong:(long long)x;
+ (unsigned char)methodWithUChar:(unsigned char)x;
+ (unsigned short)methodWithUShort:(unsigned short)x;
+ (unsigned int)methodWithUInt:(unsigned int)x;
+ (unsigned long)methodWithULong:(unsigned long)x;
+ (unsigned long long)methodWithULongLong:(unsigned long long)x;
+ (float)methodWithFloat:(float)x;
+ (double)methodWithDouble:(double)x;
+ (_Bool)methodWithBool:(_Bool)x;
+ (bool)methodWithBool2:(bool)x;
+ (BOOL)methodWithBool3:(BOOL)x;
+ (SEL)methodWithSelector:(SEL)x;
+ (Class)methodWithClass:(Class)x;
+ (Protocol *)methodWithProtocol:(Protocol *)x;
+ (NSNull *)methodWithNull:(NSNull *)x;
+ (unichar)methodWithUnichar:(unichar)x;

- (char)methodWithChar:(char)x;
- (short)methodWithShort:(short)x;
- (int)methodWithInt:(int)x;
- (long)methodWithLong:(long)x;
- (long long)methodWithLongLong:(long long)x;
- (unsigned char)methodWithUChar:(unsigned char)x;
- (unsigned short)methodWithUShort:(unsigned short)x;
- (unsigned int)methodWithUInt:(unsigned int)x;
- (unsigned long)methodWithULong:(unsigned long)x;
- (unsigned long long)methodWithULongLong:(unsigned long long)x;
- (float)methodWithFloat:(float)x;
- (double)methodWithDouble:(double)x;
- (_Bool)methodWithBool:(_Bool)x;
- (bool)methodWithBool2:(bool)x;
- (BOOL)methodWithBool3:(BOOL)x;
- (SEL)methodWithSelector:(SEL)x;
- (Class)methodWithClass:(Class)x;
- (Protocol *)methodWithProtocol:(Protocol *)x;
- (NSNull *)methodWithNull:(NSNull *)x;
- (unichar)methodWithUnichar:(unichar)x;

@end
