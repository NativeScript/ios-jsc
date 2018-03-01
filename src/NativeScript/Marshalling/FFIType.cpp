//
//  FFIType.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/7/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "FFIType.h"
#include "ExtVectorTypeInstance.h"
#include "FFISimpleType.h"
#include "FunctionReferenceTypeInstance.h"
#include "IndexedRefTypeInstance.h"
#include "ObjCBlockType.h"
#include "ObjCConstructorBase.h"
#include "PointerConstructor.h"
#include "RecordConstructor.h"
#include "ReferenceTypeInstance.h"
#include "UnmanagedType.h"

namespace NativeScript {
using namespace JSC;

bool tryGetFFITypeMethodTable(VM& vm, JSValue value, const FFITypeMethodTable** methodTable) {

    if (!value.isCell()) {
        return false;
    }

    JSCell* cell = value.asCell();

    if (FFISimpleType* object = jsDynamicCast<FFISimpleType*>(vm, cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (ObjCConstructorBase* object = jsDynamicCast<ObjCConstructorBase*>(vm, cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (RecordConstructor* object = jsDynamicCast<RecordConstructor*>(vm, cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (IndexedRefTypeInstance* object = jsDynamicCast<IndexedRefTypeInstance*>(vm, cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (ExtVectorTypeInstance* object = jsDynamicCast<ExtVectorTypeInstance*>(vm, cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (ReferenceTypeInstance* object = jsDynamicCast<ReferenceTypeInstance*>(vm, cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (ObjCBlockType* object = jsDynamicCast<ObjCBlockType*>(vm, cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (FunctionReferenceTypeInstance* object = jsDynamicCast<FunctionReferenceTypeInstance*>(vm, cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (PointerConstructor* object = jsDynamicCast<PointerConstructor*>(vm, cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    if (UnmanagedType* object = jsDynamicCast<UnmanagedType*>(vm, cell)) {
        *methodTable = &object->ffiTypeMethodTable();
        return true;
    }

    return false;
}

const FFITypeMethodTable& getFFITypeMethodTable(VM& vm, JSCell* cell) {
    ASSERT(cell);

    const FFITypeMethodTable* methodTable;
    if (tryGetFFITypeMethodTable(vm, cell, &methodTable)) {
        return *methodTable;
    }

    RELEASE_ASSERT_NOT_REACHED();
}
} // namespace NativeScript
