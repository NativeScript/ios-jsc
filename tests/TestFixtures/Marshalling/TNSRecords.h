//
//  TNSRecords.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/19/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <simd/simd.h>

typedef struct TNSSimpleStruct {
    int x;
    int y;
} TNSSimpleStruct;

typedef struct TNSStruct16 {
    int64_t x;
    int32_t y;
    int32_t z;
} TNSStruct16;

typedef struct TNSStruct24 {
    int64_t x;
    int32_t y;
    int64_t z;
} TNSStruct24;

typedef struct TNSStruct32 {
    int64_t x;
    int64_t y;
    int64_t z;
} TNSStruct32;

typedef struct TNSNestedStruct {
    struct TNSSimpleStruct a;
    struct TNSSimpleStruct b;
} TNSNestedStruct;

typedef struct TNSStructWithArray {
    int32_t x;
    int8_t arr[4];
} TNSStructWithArray;

typedef struct TNSNestedAnonymousStruct {
    int x1;
    struct {
        int x2;
        struct {
            int x3;
        } y2;
    } y1;
} TNSNestedAnonymousStruct;

typedef struct TNSComplexStruct {
    int32_t x1;
    struct {
        int16_t x2;
        struct {
            int8_t x3[2];
        } y2;
    } y1[2];
    int64_t x4;
} TNSComplexStruct;

typedef struct TNSVerySimpleStruct {
    int32_t x1;
    struct {
        int16_t x2;
        int32_t x3;
    } y1[2];
} TNSVerySimpleStruct;

typedef struct NestedSimpleStruct {
    struct {
        float x2;
        float x3;
    } y1;
    struct {
        float x2;
        float x3;
    } y2;
} NestedSimpleStruct;

typedef struct TNSStructWith2Floats {
    float f1;
    float f2;
} TNSStructWith2Floats;

typedef struct TNSStructWith3Floats {
    float f1;
    float f2;
    float f3;
} TNSStructWith3Floats;

typedef struct TNSStructWith4Floats {
    float f1;
    float f2;
    float f3;
    float f4;
} TNSStructWith4Floats;

typedef struct TNSStructWith2Doubles {
    double d1;
    double d2;
} TNSStructWith2Doubles;

typedef struct TNSStructWith3Doubles {
    double d1;
    double d2;
    double d3;
} TNSStructWith3Doubles;

typedef struct TNSStructWith4Doubles {
    double d1;
    double d2;
    double d3;
    double d4;
} TNSStructWith4Doubles;

typedef struct TNSStructWithPointers {
    void (*a)();
    int* x;
    TNSSimpleStruct* y;
    struct TNSStructWithPointers* z;
} TNSStructWithPointers;

typedef struct TNSStructWithFloat2 {
    simd_float2 f;
    int i;
} TNSStructWithFloat2;

typedef struct StructWithFloatAndDouble {
    float fl;
    double dbl;
} StructWithFloatAndDouble;

typedef struct StructWithVectorAndDouble {
    simd_float4 fl; // offset 0 size 16
    double dbl; //offset 16, size 8
} StructWithVectorAndDouble;

TNSVerySimpleStruct getSimpleStruct();
TNSComplexStruct getComplexStruct();
matrix_float2x2 getMatrixFloat2x2();
matrix_float2x3 getMatrixFloat2x3();
matrix_float2x4 getMatrixFloat2x4();
matrix_float3x2 getMatrixFloat3x2();
matrix_float3x3 getMatrixFloat3x3();
matrix_float3x4 getMatrixFloat3x4();
matrix_float4x2 getMatrixFloat4x2();
matrix_float4x3 getMatrixFloat4x3();
matrix_float4x4 getMatrixFloat4x4();
matrix_double2x2 getMatrixDouble2x2();
matrix_double2x3 getMatrixDouble2x3();
matrix_double2x4 getMatrixDouble2x4();
matrix_double3x2 getMatrixDouble3x2();
matrix_double3x3 getMatrixDouble3x3();
matrix_double3x4 getMatrixDouble3x4();
matrix_double4x2 getMatrixDouble4x2();
matrix_double4x3 getMatrixDouble4x3();
matrix_double4x4 getMatrixDouble4x4();

matrix_float2x2 doubleMatrixFloat2x2(matrix_float2x2);
matrix_float2x3 doubleMatrixFloat2x3(matrix_float2x3);
matrix_float2x4 doubleMatrixFloat2x4(matrix_float2x4);
matrix_float3x2 doubleMatrixFloat3x2(matrix_float3x2);
matrix_float3x3 doubleMatrixFloat3x3(matrix_float3x3);
matrix_float3x4 doubleMatrixFloat3x4(matrix_float3x4);
matrix_float4x2 doubleMatrixFloat4x2(matrix_float4x2);
matrix_float4x3 doubleMatrixFloat4x3(matrix_float4x3);
matrix_float4x4 doubleMatrixFloat4x4(matrix_float4x4);
matrix_double2x2 doubleMatrixDouble2x2(matrix_double2x2);
matrix_double2x3 doubleMatrixDouble2x3(matrix_double2x3);
matrix_double2x4 doubleMatrixDouble2x4(matrix_double2x4);
matrix_double3x2 doubleMatrixDouble3x2(matrix_double3x2);
matrix_double3x3 doubleMatrixDouble3x3(matrix_double3x3);
matrix_double3x4 doubleMatrixDouble3x4(matrix_double3x4);
matrix_double4x2 doubleMatrixDouble4x2(matrix_double4x2);
matrix_double4x3 doubleMatrixDouble4x3(matrix_double4x3);
matrix_double4x4 doubleMatrixDouble4x4(matrix_double4x4);

simd_float2 getFloat2();
simd_float3 getFloat3();
simd_float4 getFloat4();
simd_double2 getDouble2();
simd_double3 getDouble3();
simd_double4 getDouble4();
simd_double2 incrementDouble2(simd_double2 v);
simd_double3 incrementDouble3(simd_double3 v);
simd_double4 incrementDouble4(simd_double4 v);
simd_float2 incrementFloat2(simd_float2 v);
simd_float3 incrementFloat3(simd_float3 v);
simd_float4 incrementFloat4(simd_float4 v);
NestedSimpleStruct getNestedStruct();
StructWithFloatAndDouble getStructWithFloatAndDouble();
StructWithVectorAndDouble getStructWithVectorAndDouble();
TNSStructWithFloat2 getStructWithFloat2();
TNSStructWith4Floats getStructWith4Floats();
TNSStructWith3Floats getStructWith3Floats();
TNSStructWith2Floats getStructWith2Floats();
TNSStructWith4Doubles getStructWith4Doubles();
TNSStructWith3Doubles getStructWith3Doubles();
TNSStructWith2Doubles getStructWith2Doubles();

simd_float3 _SCNVector3ToFloat3(SCNVector3 v);
simd_float4 _SCNVector4ToFloat4(SCNVector4 v);
simd_float4x4 _SCNMatrix4ToMat4(SCNMatrix4 m);

SCNVector3 _SCNVector3FromFloat3(simd_float3 v);
SCNVector4 _SCNVector4FromFloat4(simd_float4 v);
SCNMatrix4 _SCNMatrix4FromMat4(simd_float4x4 m);
