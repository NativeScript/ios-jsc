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

TNSStructWithFloat2 getStructWithFloat2() {
    TNSStructWithFloat2 result = {
        .f = getFloat2(),
        .i = 5
    };

    return result;
}

TNSStructWith2Floats getStructWith2Floats() {
    TNSStructWith2Floats result = {
        .f1 = 1.2345,
        .f2 = 2.3456
    };

    return result;
}

TNSStructWith3Floats getStructWith3Floats() {
    TNSStructWith3Floats result = {
        .f1 = 1.2345,
        .f2 = 2.3456,
        .f3 = 3.4567
    };

    return result;
}

TNSStructWith4Floats getStructWith4Floats() {
    TNSStructWith4Floats result = {
        .f1 = 1.2345,
        .f2 = 2.3456,
        .f3 = 3.4567,
        .f4 = 4.5678
    };

    return result;
}

TNSStructWith2Doubles getStructWith2Doubles() {
    TNSStructWith2Doubles result = {
        .d1 = 1.2345,
        .d2 = 2.3456
    };

    return result;
}

TNSStructWith3Doubles getStructWith3Doubles() {
    TNSStructWith3Doubles result = {
        .d1 = 1.2345,
        .d2 = 2.3456,
        .d3 = 3.4567
    };

    return result;
}

TNSStructWith4Doubles getStructWith4Doubles() {
    TNSStructWith4Doubles result = {
        .d1 = 1.2345,
        .d2 = 2.3456,
        .d3 = 3.4567,
        .d4 = 4.5678
    };

    return result;
}

matrix_float2x2 getMatrixFloat2x2() {
    matrix_float2x2 result;
    float pi = 3.1415;
    for (int i = 0; i < 4; i++) {
        result.columns[i % 2][i / 2] = i * pi;
    }
    return result;
}

matrix_float2x3 getMatrixFloat2x3() {
    matrix_float2x3 result;
    float pi = 3.1415;
    for (int i = 0; i < 6; i++) {
        result.columns[i % 2][i / 2] = i * pi;
    }
    return result;
}

matrix_float2x4 getMatrixFloat2x4() {
    matrix_float2x4 result;
    float pi = 3.1415;
    for (int i = 0; i < 8; i++) {
        result.columns[i % 2][i / 2] = i * pi;
    }
    return result;
}

matrix_float3x2 getMatrixFloat3x2() {
    matrix_float3x2 result;
    float pi = 3.1415;
    for (int i = 0; i < 6; i++) {
        result.columns[i % 3][i / 3] = i * pi;
    }
    return result;
}

matrix_float3x3 getMatrixFloat3x3() {
    matrix_float3x3 result;
    float pi = 3.1415;
    for (int i = 0; i < 9; i++) {
        result.columns[i % 3][i / 3] = i * pi;
    }
    return result;
}

matrix_float3x4 getMatrixFloat3x4() {
    matrix_float3x4 result;
    float pi = 3.1415;
    for (int i = 0; i < 12; i++) {
        result.columns[i % 3][i / 3] = i * pi;
    }
    return result;
}

matrix_float4x2 getMatrixFloat4x2() {
    matrix_float4x2 result;
    float pi = 3.1415;
    for (int i = 0; i < 8; i++) {
        result.columns[i % 4][i / 4] = i * pi;
    }
    return result;
}

matrix_float4x3 getMatrixFloat4x3() {
    matrix_float4x3 result;
    float pi = 3.1415;
    for (int i = 0; i < 12; i++) {
        result.columns[i % 4][i / 4] = i * pi;
    }
    return result;
}

matrix_float4x4 getMatrixFloat4x4() {
    matrix_float4x4 result;
    float pi = 3.1415;
    for (int i = 0; i < 16; i++) {
        result.columns[i % 4][i / 4] = i * pi;
    }
    return result;
}

matrix_double2x2 getMatrixDouble2x2() {
    matrix_double2x2 result;
    double pi = 3.1415;
    for (int i = 0; i < 4; i++) {
        result.columns[i % 2][i / 2] = i * pi;
    }
    return result;
}

matrix_double2x3 getMatrixDouble2x3() {
    matrix_double2x3 result;
    double pi = 3.1415;
    for (int i = 0; i < 6; i++) {
        result.columns[i % 2][i / 2] = i * pi;
    }
    return result;
}

matrix_double2x4 getMatrixDouble2x4() {
    matrix_double2x4 result;
    double pi = 3.1415;
    for (int i = 0; i < 8; i++) {
        result.columns[i % 2][i / 2] = i * pi;
    }
    return result;
}

matrix_double3x2 getMatrixDouble3x2() {
    matrix_double3x2 result;
    double pi = 3.1415;
    for (int i = 0; i < 6; i++) {
        result.columns[i % 3][i / 3] = i * pi;
    }
    return result;
}

matrix_double3x3 getMatrixDouble3x3() {
    matrix_double3x3 result;
    double pi = 3.1415;
    for (int i = 0; i < 9; i++) {
        result.columns[i % 3][i / 3] = i * pi;
    }
    return result;
}

matrix_double3x4 getMatrixDouble3x4() {
    matrix_double3x4 result;
    double pi = 3.1415;
    for (int i = 0; i < 12; i++) {
        result.columns[i % 3][i / 3] = i * pi;
    }
    return result;
}

matrix_double4x2 getMatrixDouble4x2() {
    matrix_double4x2 result;
    double pi = 3.1415;
    for (int i = 0; i < 8; i++) {
        result.columns[i % 4][i / 4] = i * pi;
    }
    return result;
}

matrix_double4x3 getMatrixDouble4x3() {
    matrix_double4x3 result;
    double pi = 3.1415;
    for (int i = 0; i < 12; i++) {
        result.columns[i % 4][i / 4] = i * pi;
    }
    return result;
}

matrix_double4x4 getMatrixDouble4x4() {
    matrix_double4x4 result;
    double pi = 3.1415;
    for (int i = 0; i < 16; i++) {
        result.columns[i % 4][i / 4] = i * pi;
    }
    return result;
}

simd_float2 getFloat2() {
    simd_float2 float2 = simd_make_float2(1.2345, 2.3456);
    return float2;
}

simd_float3 getFloat3() {
    simd_float3 float3 = simd_make_float3(1.2345, 2.3456, 3.4567);
    return float3;
}

simd_float4 getFloat4() {
    simd_float4 float4 = simd_make_float4(1.2345, 2.3456, 3.4567, 4.5678);
    return float4;
}

simd_double2 getDouble2() {
    simd_double2 d = simd_make_double2(1.2345, 2.3456);
    return d;
}

simd_double3 createDouble3() {
    simd_double3 d = simd_make_double3(1.2345, 2.3456, 3.4567);
    simd_double3 d2 = simd_make_double3(0, 0, 0);
    simd_double3 res = d + d2;
    return res;
}

simd_double3 getDouble3() {
    simd_double3 res = createDouble3();
    return res;
}

simd_double4 getDouble4() {
    simd_double4 d = simd_make_double4(1.2345, 2.3456, 3.4567, 4.5678);
    return d;
}

StructWithFloatAndDouble getStructWithFloatAndDouble() {
    StructWithFloatAndDouble str;
    str.fl = 3.14;
    str.dbl = 1.414;
    return str;
}

StructWithVectorAndDouble getStructWithVectorAndDouble() {
    StructWithVectorAndDouble str;
    str.fl = simd_make_float4(1.2345, 2.3456, 3.4567, 4.5678);
    str.dbl = 1.67;
    return str;
}
