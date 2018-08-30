//
//  IsObjcObject.c
//  IsObjcObject
//
//  Created by Alexandre Colucci on 19.11.2016.
//  Copyright © 2016 Alexandre Colucci. All rights reserved.
//
//  Taken from: https://blog.timac.org/2016/1124-testing-if-an-arbitrary-pointer-is-a-valid-objective-c-object/

#include <objc/objc.h>
#include <stdbool.h>

/**
 Test if a pointer is an Objective-C object

 @param inPtr is the pointer to check
 @return true if the pointer is an Objective-C object
 */
extern "C" {

bool IsObjcObject(const void* inPtr);

/**
 Test if a pointer is a tagged pointer

 @param inPtr is the pointer to check
 @param outClass returns the registered class for the tagged pointer.
 @return true if the pointer is a tagged pointer.
 */
bool IsObjcTaggedPointer(const void* inPtr, Class* outClass);
}
