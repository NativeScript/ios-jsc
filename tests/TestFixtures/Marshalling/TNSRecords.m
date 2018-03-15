//
//  TNSRecords.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/19/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSRecords.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 110000
typedef vector_float2 simd_float2;
typedef vector_float3 simd_float3;
typedef vector_float4 simd_float4;
#define simd_make_float2(a, b) \
    { a, b }
#define simd_make_float3(a, b, c) \
    { a, b, c }
#define simd_make_float4(a, b, c, d) \
    { a, b, c, d }
#endif

TNSVerySimpleStruct getSimpleStruct() {
    TNSVerySimpleStruct simpleStruct = { .x1 = 100, .y1 = { { .x2 = 10, .x3 = 20 }, { .x2 = 30, .x3 = 40 } } };

    return simpleStruct;
}

NestedSimpleStruct getNestedStruct() {
    NestedSimpleStruct simpleStruct = { .y1 = { .x2 = 12.34, .x3 = 3.675 }, .y2 = { .x2 = 31.34, .x3 = 67.675 } };
    return simpleStruct;
}

TNSComplexStruct getComplexStruct() {
    TNSComplexStruct result = { .x1 = 100, .y1 = { { .x2 = 10, .y2 = { .x3 = { 1, 2 } } }, { .x2 = 20, .y2 = { .x3 = { 3, 4 } } } }, .x4 = 123456 };

    return result;
}

matrix_float2x2 getMatrix2x2() {
    matrix_float2x2 result;
    simd_float2 sfloat = simd_make_float2(1.2345, 2.3456);
    for (int i = 0; i < 2; i++) {
        result.columns[i] = sfloat;
    }
    return result;
}

matrix_float2x3 getMatrix2x3() {
    matrix_float2x3 result;
    simd_float3 sfloat = simd_make_float3(1.2345, 2.3456, 3.4567);
    for (int i = 0; i < 2; i++) {
        result.columns[i] = sfloat;
    }
    return result;
}

matrix_float2x4 getMatrix2x4() {
    matrix_float2x4 result;
    simd_float4 sfloat = simd_make_float4(1.2345, 2.3456, 3.4567, 4.5678);
    for (int i = 0; i < 2; i++) {
        result.columns[i] = sfloat;
    }
    return result;
}

matrix_float3x2 getMatrix3x2() {
    matrix_float3x2 result;
    simd_float2 sfloat = simd_make_float2(1.2345, 2.3456);
    for (int i = 0; i < 3; i++) {
        result.columns[i] = sfloat;
    }
    return result;
}

matrix_float3x3 getMatrix3x3() {
    matrix_float3x3 result;
    simd_float3 sfloat = simd_make_float3(1.2345, 2.3456, 3.4567);
    for (int i = 0; i < 3; i++) {
        result.columns[i] = sfloat;
    }
    return result;
}

matrix_float3x4 getMatrix3x4() {
    matrix_float3x4 result;
    simd_float4 sfloat = simd_make_float4(1.2345, 2.3456, 3.4567, 4.5678);
    for (int i = 0; i < 3; i++) {
        result.columns[i] = sfloat;
    }
    return result;
}

matrix_float4x2 getMatrix4x2() {
    matrix_float4x2 result;
    simd_float2 sfloat = simd_make_float2(1.2345, 2.3456);
    for (int i = 0; i < 4; i++) {
        result.columns[i] = sfloat;
    }
    return result;
}

matrix_float4x3 getMatrix4x3() {
    matrix_float4x3 result;
    simd_float3 sfloat = simd_make_float3(1.2345, 2.3456, 3.4567);
    for (int i = 0; i < 4; i++) {
        result.columns[i] = sfloat;
    }
    return result;
}

matrix_float4x4 getMatrix4x4() {
    matrix_float4x4 result;
    float pi = 3.1415;
    for (int i = 0; i < 16; i++) {
        result.columns[i % 4][i / 4] = i * pi;
    }
    return result;
}
