//
//  TNSRecords.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/19/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSRecords.h"
#import <ARKit/ARKit.h>

TNSVerySimpleStruct getSimpleStruct() {
    TNSVerySimpleStruct simpleStruct = { .x1 = 100, .y1 = { { .x2 = 10, .x3 = 20 }, { .x2 = 30, .x3 = 40 } } };

    return simpleStruct;
}

TNSComplexStruct getComplexStruct() {
    TNSComplexStruct result = { .x1 = 100, .y1 = { { .x2 = 10, .y2 = { .x3 = { 1, 2 } } }, { .x2 = 20, .y2 = { .x3 = { 3, 4 } } } }, .x4 = 123456 };

    return result;
}

simd_float4x4 getMatrix() {
    matrix_float4x4 result;
    float pi = 3.1415;
    for (int i = 0; i < 16; i++) {
        result.columns[i % 4][i / 4] = i * pi;
    }
    return result;
}
