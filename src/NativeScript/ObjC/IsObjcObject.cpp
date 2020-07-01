//
//  IsObjcObject.c
//  IsObjcObject
//
//  Created by Alexandre Colucci on 19.11.2016.
//  Copyright © 2016 Alexandre Colucci. All rights reserved.
//
//
//  Taken from: https://blog.timac.org/2016/1124-testing-if-an-arbitrary-pointer-is-a-valid-objective-c-object/

#include "IsObjcObject.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

// Objective-C runtime
#include <objc/runtime.h>

// For malloc_size
#include <malloc/malloc.h>

#pragma mark - IsObjcObject

/**
 Test if a pointer is an Objective-C object

 @param inPtr is the pointer to check
 @return true if the pointer is an Objective-C object
 */
bool IsObjcObject(const void* inPtr) {
    //
    // NULL pointer is not an Objective-C object
    //
    if (inPtr == NULL) {
        return false;
    }

    Class ptrClass = NULL;
    ptrClass = object_getClass((id)inPtr);
    
    if (ptrClass == NULL) {
        return false;
    }
    
    //
    // From Greg Parker
    // https://twitter.com/gparker/status/801894068502433792
    // You can filter out some false positives by checking malloc_size(obj) >= class_getInstanceSize(cls).
    //
    size_t pointerSize = malloc_size(inPtr);
    if (pointerSize > 0 && pointerSize < class_getInstanceSize(ptrClass)) {
        return false;
    }

    return true;
}
