//
//  TNSRecords.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/19/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import <ARKit/ARKit.h>

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

typedef struct TNSStructWithPointers {
    void (*a)();
    int* x;
    TNSSimpleStruct* y;
    struct TNSStructWithPointers* z;
} TNSStructWithPointers;

TNSVerySimpleStruct getSimpleStruct();
TNSComplexStruct getComplexStruct();
simd_float2x2 getMatrix2x2();
simd_float2x3 getMatrix2x3();
simd_float2x4 getMatrix2x4();
simd_float3x2 getMatrix3x2();
simd_float3x3 getMatrix3x3();
simd_float3x4 getMatrix3x4();
simd_float4x2 getMatrix4x2();
simd_float4x3 getMatrix4x3();
simd_float4x4 getMatrix4x4();
NestedSimpleStruct getNestedStruct();
