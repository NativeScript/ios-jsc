//
//  TNSPrimitivePointers.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 3/19/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSPrimitivePointers.h"

void* functionWith_VoidPtr(void* x) {
    TNSLog([NSString stringWithFormat:@"%p", x]);
    return x;
}

_Bool* functionWith_BoolPtr(_Bool* x) {
    TNSLog([NSString stringWithFormat:@"%d", !!*x]);
    return x;
}

unsigned char* functionWithUCharPtr(unsigned char* x) {
    TNSLog([NSString stringWithFormat:@"%s", x]);
    return x;
}

unsigned short* functionWithUShortPtr(unsigned short* x) {
    TNSLog([NSString stringWithFormat:@"%hu", *x]);
    return x;
}

unsigned int* functionWithUIntPtr(unsigned int* x) {
    TNSLog([NSString stringWithFormat:@"%u", *x]);
    return x;
}

unsigned long* functionWithULongPtr(unsigned long* x) {
    TNSLog([NSString stringWithFormat:@"%lu", *x]);
    return x;
}

unsigned long long* functionWithULongLongPtr(unsigned long long* x) {
    TNSLog([NSString stringWithFormat:@"%llu", *x]);
    return x;
}

char* functionWithCharPtr(char* x) {
    TNSLog([NSString stringWithFormat:@"%s", x]);

    return x;
}

short* functionWithShortPtr(short* x) {
    TNSLog([NSString stringWithFormat:@"%hd", *x]);
    return x;
}

int* functionWithIntPtr(int* x) {
    TNSLog([NSString stringWithFormat:@"%d", *x]);
    return x;
}

long* functionWithLongPtr(long* x) {
    TNSLog([NSString stringWithFormat:@"%ld", *x]);
    return x;
}

long long* functionWithLongLongPtr(long long* x) {
    TNSLog([NSString stringWithFormat:@"%lld", *x]);
    return x;
}

float* functionWithFloatPtr(float* x) {
    TNSLog([NSString stringWithFormat:@"%.45f", *x]);
    return x;
}

double* functionWithDoublePtr(double* x) {
    TNSLog([NSString stringWithFormat:@"%.325f", *x]);
    return x;
}

TNSNestedStruct* functionWithStructPtr(TNSNestedStruct* x) {
    TNSLog([NSString stringWithFormat:@"%d %d %d %d", x->a.x, x->a.y, x->b.x, x->b.y]);
    return x;
}

void functionWithOutStructPtr(TNSSimpleStruct* str) {
    str->x = 2;
    str->y = 3;
}

void functionWithIntIncompleteArray(int x[]) {
    for (int i = 0; x[i]; i++) {
        TNSLog([NSString stringWithFormat:@"%d", x[i]]);
    }
}
void functionWithIntConstantArray(int x[5]) {
    for (int i = 0; i < 5; i++) {
        TNSLog([NSString stringWithFormat:@"%d", x[i]]);
    }
}
void functionWithIntConstantArray2(int x[2][2]) {
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            TNSLog([NSString stringWithFormat:@"%d", x[i][j]]);
        }
    }
}

char** functionWithDoubleCharPtr(char** x) {
    TNSLog([NSString stringWithFormat:@"%s", x[0]]);
    TNSLog([NSString stringWithFormat:@"%s", x[1]]);

    free(x[0]);
    x[0] = calloc(4, sizeof(char));
    x[0][0] = '1';
    x[0][1] = '2';
    x[0][2] = '3';

    free(x[1]);
    x[1] = calloc(4, sizeof(char));
    x[1][0] = '4';
    x[1][1] = '5';
    x[1][2] = '6';

    return x;
}

void* functionWithNullPointer(void* x) {
    TNSLog([NSString stringWithFormat:@"%p", x]);
    return NULL;
}

void* functionWithIdPointer(void* x) {
    for (int i = 0; i < 3; i++) {
        TNSLog(NSStringFromClass([(__bridge id)((void**)x)[i] class]));
    }
    return x;
}

void* functionWithIdToVoidPointer(void* x) {
    TNSLog(NSStringFromClass([(__bridge id)x class]));
    return x;
}

@implementation TNSPointerManager {
    int _data;
}

- (int*)data {
    return &_data;
}
- (void)increment {
    _data++;
}
@end
