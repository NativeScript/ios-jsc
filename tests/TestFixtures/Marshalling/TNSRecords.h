//
//  TNSRecords.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/19/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

typedef struct TNSSimpleStruct {
    int x;
    int y;
} TNSSimpleStruct;

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
} TNSComplexStruct;

typedef struct TNSStructWithPointers {
    void (*a)();
    int* x;
    TNSSimpleStruct* y;
    struct TNSStructWithPointers* z;
} TNSStructWithPointers;
