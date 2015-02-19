//
//  TNSFunctionPointers.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 3/27/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSFunctionPointers.h"

static long long _simpleFunctionImplementation(long long x) {
    return x * x;
}

long long (*functionWhichReturnsSimpleFunctionPointer())(long long) {
    return _simpleFunctionImplementation;
}

void functionWithSimpleFunctionPointer(int (*f)(int)) {
    int result = f(2);
    TNSLog([NSString stringWithFormat:@"%d", result]);
}

void functionWithComplexFunctionPointer(TNSNestedStruct (*f)(char p1, short p2, int p3, long p4, long long p5, unsigned char p6, unsigned short p7, unsigned int p8, unsigned long p9, unsigned long long p10, float p11, double p12, SEL p13, Class p14, Protocol *p15, NSObject *p16, TNSNestedStruct p17)) {
    static NSObject *object = nil;

    if (object == nil) {
        object = [NSObject new];
    }

    TNSNestedStruct nestedStruct = { .a = { 1, 2 }, .b = { 3, 4 } };
    TNSNestedStruct result = f(127, 32767, 2147483647, 2147483647, 9223372036854775807LL, 255, 65535, 4294967295U, 4294967295U, 18446744073709551615ULL, 340282346638528859811704183484516925440.0F, 179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.0, @selector(init), [NSObject class], @protocol(NSObject), object, nestedStruct);
    TNSLog([NSString stringWithFormat:@"%d %d %d %d", result.a.x, result.a.y, result.b.x, result.b.y]);
}

void *functionReturningFunctionPtrAsVoidPtr() {
    return (void *)_simpleFunctionImplementation;
}