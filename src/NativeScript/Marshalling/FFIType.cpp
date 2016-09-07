//
//  FFIType.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/7/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "FFIType.h"
#include "FFISimpleType.h"
#include "FunctionReferenceTypeInstance.h"
#include "ObjCBlockType.h"
#include "ObjCConstructorBase.h"
#include "PointerConstructor.h"
#include "RecordConstructor.h"
#include "ReferenceTypeInstance.h"
#include "UnmanagedType.h"

namespace NativeScript {
using namespace JSC;

bool tryGetFFITypeMethodTable(JSValue value, const FFITypeMethodTable** methodTable) {

    if (!value.isCell()) {
        return false;
    }

    JSCell* cell = value.asCell();

    if (FFISimpleType* object = jsDynamicCast<FFISimpleType*>(cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (ObjCConstructorBase* object = jsDynamicCast<ObjCConstructorBase*>(cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (RecordConstructor* object = jsDynamicCast<RecordConstructor*>(cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (ReferenceTypeInstance* object = jsDynamicCast<ReferenceTypeInstance*>(cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (ObjCBlockType* object = jsDynamicCast<ObjCBlockType*>(cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (FunctionReferenceTypeInstance* object = jsDynamicCast<FunctionReferenceTypeInstance*>(cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (PointerConstructor* object = jsDynamicCast<PointerConstructor*>(cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (UnmanagedType* object = jsDynamicCast<UnmanagedType*>(cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    return false;
}

const FFITypeMethodTable& getFFITypeMethodTable(JSCell* cell) {
    ASSERT(cell);

    const FFITypeMethodTable* methodTable;
    if (tryGetFFITypeMethodTable(cell, &methodTable)) {
        return *methodTable;
    }

    RELEASE_ASSERT_NOT_REACHED();
}
}
