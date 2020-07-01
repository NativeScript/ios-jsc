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

// For dlsym
#include <dlfcn.h>

// For malloc_size
#include <malloc/malloc.h>

// Do not thoroughly check valid memory pointers - it's too computationally intensive and slows down the runtime by 3 to 10 times
#define SKIP_CHECK_FOR_KNOWN_CLASS 1

#pragma mark - Expose non exported Tagged Pointer functions from objc4-706/runtime/objc-internal.h

#if TARGET_OS_OSX && __x86_64__
// 64-bit Mac - tag bit is LSB
#define OBJC_MSB_TAGGED_POINTERS 0
#else
// Everything else - tag bit is MSB
#define OBJC_MSB_TAGGED_POINTERS 1
#endif

#define _OBJC_TAG_INDEX_MASK 0x7
#define _OBJC_TAG_EXT_INDEX_MASK 0xff

#if OBJC_MSB_TAGGED_POINTERS
#define _OBJC_TAG_MASK (1ULL << 63)
#define _OBJC_TAG_INDEX_SHIFT 60
#define _OBJC_TAG_EXT_INDEX_SHIFT 52
#else
#define _OBJC_TAG_MASK 1
#define _OBJC_TAG_INDEX_SHIFT 1
#define _OBJC_TAG_EXT_INDEX_SHIFT 4
#endif

#if (defined __arm__ && __arm__) || (defined __i386__ && __i386__)
#define SKIP_OBJECTIVE_C_CHECKS 1
#endif

#if !defined SKIP_OBJECTIVE_C_CHECKS || !SKIP_OBJECTIVE_C_CHECKS

typedef enum {
    OBJC_TAG_NSAtom = 0,
    OBJC_TAG_1 = 1,
    OBJC_TAG_NSString = 2,
    OBJC_TAG_NSNumber = 3,
    OBJC_TAG_NSIndexPath = 4,
    OBJC_TAG_NSManagedObjectID = 5,
    OBJC_TAG_NSDate = 6,
    OBJC_TAG_RESERVED_7 = 7,

    OBJC_TAG_First60BitPayload = 0,
    OBJC_TAG_Last60BitPayload = 6,
    OBJC_TAG_First52BitPayload = 8,
    OBJC_TAG_Last52BitPayload = 263,

    OBJC_TAG_RESERVED_264 = 264
} objc_tag_index_t;

static inline bool _objc_isTaggedPointer(const void* ptr) {
    return ((intptr_t)ptr & _OBJC_TAG_MASK) == _OBJC_TAG_MASK;
}

static inline objc_tag_index_t _objc_getTaggedPointerTag(const void* ptr) {
    uintptr_t basicTag = ((uintptr_t)ptr >> _OBJC_TAG_INDEX_SHIFT) & _OBJC_TAG_INDEX_MASK;
    uintptr_t extTag = ((uintptr_t)ptr >> _OBJC_TAG_EXT_INDEX_SHIFT) & _OBJC_TAG_EXT_INDEX_MASK;
    if (basicTag == _OBJC_TAG_INDEX_MASK) {
        return (objc_tag_index_t)(extTag + OBJC_TAG_First52BitPayload);
    } else {
        return (objc_tag_index_t)basicTag;
    }
}

#pragma mark - Tagged Pointer

/**
 Returns the registered class for the given tag.
 Returns nil if the tag is valid but has no registered class.

 This function searches the exported function: _objc_getClassForTag(objc_tag_index_t tag)
 declared in https://opensource.apple.com/source/objc4/objc4-706/runtime/objc-internal.h
 */
static Class _objc_getClassForTag(objc_tag_index_t tag) {
    static bool _objc_getClassForTag_searched = false;
    static Class (*_objc_getClassForTag_func)(objc_tag_index_t) = NULL;
    if (!_objc_getClassForTag_searched) {
        _objc_getClassForTag_func = (Class(*)(objc_tag_index_t))dlsym(RTLD_DEFAULT, "_objc_getClassForTag");
        _objc_getClassForTag_searched = true;
        if (_objc_getClassForTag_func == NULL) {
            fprintf(stderr, "*** Could not find _objc_getClassForTag()!\n");
        }
    }

    if (_objc_getClassForTag_func != NULL) {
        return _objc_getClassForTag_func(tag);
    }

    return NULL;
}

/**
 Test if a pointer is a tagged pointer

 @param inPtr is the pointer to check
 @param outClass returns the registered class for the tagged pointer.
 @return true if the pointer is a tagged pointer.
 */
bool IsObjcTaggedPointer(const void* inPtr, Class* outClass) {
    bool isTaggedPointer = _objc_isTaggedPointer(inPtr);
    if (outClass != NULL) {
        if (isTaggedPointer) {
            objc_tag_index_t tagIndex = _objc_getTaggedPointerTag(inPtr);
            *outClass = _objc_getClassForTag(tagIndex);
        } else {
            *outClass = NULL;
        }
    }

    return isTaggedPointer;
}

#endif // !defined SKIP_OBJECTIVE_C_CHECKS || !SKIP_OBJECTIVE_C_CHECKS

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

#if !defined SKIP_OBJECTIVE_C_CHECKS || !SKIP_OBJECTIVE_C_CHECKS
    //
    // Check for tagged pointers
    //
    if (IsObjcTaggedPointer(inPtr, NULL)) {
        return true;
    }
#endif

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

#if !defined SKIP_OBJECTIVE_C_CHECKS || !SKIP_OBJECTIVE_C_CHECKS
    // refactored to prevent occasional crashes on ios 14
    // accessing the isa pointers like we used to is a hacky solution
    // it has worked fine for a long time, but with ios 14 it can now
    // cause apps to crash. We are instead using object_getClass now.
    
    Class ptrClass = object_getClass((id)inPtr);

    if (ptrClass == NULL) {
        return false;
    }

#if !defined(SKIP_CHECK_FOR_KNOWN_CLASS) || !SKIP_CHECK_FOR_KNOWN_CLASS
    //
    // Verifies that the found Class is a known class.
    //
    bool isKnownClass = false;

    unsigned int numClasses = 0;
    Class* classesList = objc_copyClassList(&numClasses);
    for (unsigned i = 0; i < numClasses; i++) {
        if (classesList[i] == ptrClass) {
            isKnownClass = true;
            break;
        }
    }
    free(classesList);

    if (!isKnownClass) {
        return false;
    }
#endif // !defined(SKIP_CHECK_FOR_KNOWN_CLASS) || !SKIP_CHECK_FOR_KNOWN_CLASS

    //
    // From Greg Parker
    // https://twitter.com/gparker/status/801894068502433792
    // You can filter out some false positives by checking malloc_size(obj) >= class_getInstanceSize(cls).
    //
    size_t pointerSize = malloc_size(inPtr);
    if (pointerSize > 0 && pointerSize < class_getInstanceSize(ptrClass)) {
        return false;
    }
#endif // !defined SKIP_OBJECTIVE_C_CHECKS || !SKIP_OBJECTIVE_C_CHECKS

    return true;
}
