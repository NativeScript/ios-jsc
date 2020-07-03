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

// For vm_region_64
#include <mach/mach.h>

// Objective-C runtime
#include <objc/runtime.h>

// For malloc_size
#include <malloc/malloc.h>

#pragma mark - Expose non exported Tagged Pointer functions from objc4-781.2/runtime/objc-internal.h

#if TARGET_OS_OSX && __x86_64__
//  64-bit Mac - tag bit is LSB
#   define _OBJC_TAG_MASK 1UL
#else
//  Everything else - tag bit is MSB
#   define _OBJC_TAG_MASK (1ULL << 63)
#endif

static inline bool _objc_isTaggedPointer(const void * _Nullable ptr) {
    return ((uintptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK;
}

#pragma mark - Readable and valid memory

/**
 Test if the pointer points to readable and valid memory.
 @param inPtr is the pointer
 @return true if the pointer points to readable and valid memory.
 */
static bool IsValidReadableMemory(const void* inPtr) {
    kern_return_t error = KERN_SUCCESS;

    // Check for read permissions
    bool hasReadPermissions = false;

    vm_size_t vmsize;
    vm_address_t address = (vm_address_t)inPtr;
    vm_region_basic_info_data_t info;
    mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT_64;

    memory_object_name_t object;

    error = vm_region_64(mach_task_self(), &address, &vmsize, VM_REGION_BASIC_INFO, (vm_region_info_t)&info, &info_count, &object);
    if (error != KERN_SUCCESS) {
        // vm_region/vm_region_64 returned an error
        hasReadPermissions = false;
    } else {
        hasReadPermissions = (info.protection & VM_PROT_READ);
    }

    if (!hasReadPermissions) {
        return false;
    }

    // Read the memory
    char buf[sizeof(uintptr_t)];
    vm_size_t size = 0;
    error = vm_read_overwrite(mach_task_self(), (vm_address_t)inPtr, sizeof(uintptr_t), (vm_address_t)buf, &size);
    if (error != KERN_SUCCESS) {
        // vm_read returned an error
        return false;
    }

    return true;
}

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
    
    //
    // Check if the pointer is a tagged objc pointer
    //
    if (_objc_isTaggedPointer(inPtr)) {
        return true;
    }
    
    //
    // Check if the pointer is aligned
    //
    if (((uintptr_t)inPtr % sizeof(uintptr_t)) != 0) {
        return false;
    }
    
    //
    // Check if the memory is valid and readable
    //
    if (!IsValidReadableMemory(inPtr)) {
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
