//
//  FFIPrimitiveTypes.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 16.10.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "FFIPrimitiveTypes.h"
#include "FFISimpleType.h"
#include "Interop.h"
#include "PointerInstance.h"
#include "ReferenceInstance.h"
#include "ReleasePool.h"
#include "TypeFactory.h"
#include <JavaScriptCore/JSGlobalObjectInspectorController.h>

namespace NativeScript {
using namespace JSC;

#pragma mark noopType
static JSValue noopType_read(ExecState* execState, const void* buffer, JSCell* self) {
    JSValue exception = createError(execState, WTF::ASCIILiteral("Can not read from noop type."));
    return execState->vm().throwException(execState, exception);
}
static void noopType_write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    JSValue exception = createError(execState, WTF::ASCIILiteral("Can not write to noop type."));
    execState->vm().throwException(execState, exception);
}
static bool noopType_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return false;
}
const FFITypeMethodTable noopTypeMethodTable = {
    .read = &noopType_read,
    .write = &noopType_write,
    .canConvert = &noopType_canConvert,
    .ffiType = &ffi_type_pointer
};

#pragma mark voidType
static JSValue voidType_read(ExecState* execState, const void* buffer, JSCell* self) {
    return jsUndefined();
}
static void voidType_write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
}
static bool voidType_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return value.isUndefinedOrNull();
}
static const char* voidType_encode(JSC::JSCell* self) {
    return "v";
}
const FFITypeMethodTable voidTypeMethodTable = {
    .read = &voidType_read,
    .write = &voidType_write,
    .canConvert = &voidType_canConvert,
    .ffiType = &ffi_type_void,
    .encode = &voidType_encode
};

#pragma mark boolType
static JSValue boolType_read(ExecState* execState, const void* buffer, JSCell* self) {
    return jsBoolean(*static_cast<const char*>(buffer) != 0);
}
static void boolType_write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    *static_cast<bool*>(buffer) = value.toBoolean(execState);
}
static bool boolType_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return true;
}
static const char* boolType_encode(JSC::JSCell* self) {
    return "B";
}
const FFITypeMethodTable boolTypeMethodTable = {
    .read = &boolType_read,
    .write = &boolType_write,
    .canConvert = &boolType_canConvert,
    .ffiType = &ffi_type_sint8,
    .encode = &boolType_encode
};

#pragma mark unicharType
static JSValue unicharType_read(ExecState* execState, const void* buffer, JSCell* self) {
    const UChar character = *static_cast<const UChar*>(buffer);
    return jsSingleCharacterString(execState, character);
}
static void unicharType_write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    JSString* str = value.toString(execState);
    if (str->length() != 1) {
        JSValue exception = createError(execState, WTF::ASCIILiteral("Only one character string can be converted to unichar."));
        execState->vm().throwException(execState, exception);
        return;
    }

    UChar character = str->value(execState).characterAt(0);
    *static_cast<UChar*>(buffer) = character;
}
static bool unicharType_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return value.isCell() && value.toString(execState)->length() == 1;
}
static const char* unicharType_encode(JSC::JSCell* self) {
    return "S";
}
const FFITypeMethodTable unicharTypeMethodTable = {
    .read = &unicharType_read,
    .write = &unicharType_write,
    .canConvert = &unicharType_canConvert,
    .ffiType = &ffi_type_ushort,
    .encode = &unicharType_encode
};

#pragma mark cStringType
static JSValue cStringType_read(ExecState* execState, const void* buffer, JSCell* self) {
    const char* string = *static_cast<char* const*>(buffer);

    if (!string) {
        return jsNull();
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    JSCell* type = globalObject->typeFactory()->int8Type();
    PointerInstance* pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState->vm(), const_cast<char*>(string)));
    return ReferenceInstance::create(execState->vm(), globalObject, globalObject->interop()->referenceInstanceStructure(), type, pointer);
}
static void cStringType_write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    if (value.isUndefinedOrNull()) {
        *static_cast<char**>(buffer) = nullptr;
        return;
    }

    if (value.isString()) {
        WTF::CString result = value.toString(execState)->value(execState).utf8();
        *static_cast<const char**>(buffer) = result.data();
        releaseSoon(execState, std::move(result));
        return;
    }

    bool hasHandle;
    void* handle = tryHandleofValue(value, &hasHandle);
    if (hasHandle) {
        *static_cast<char**>(buffer) = static_cast<char*>(handle);
        return;
    }

    JSValue exception = createError(execState, WTF::ASCIILiteral("Value is not a string."));
    execState->vm().throwException(execState, exception);
    return;
}
static bool cStringType_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return true;
}
static const char* cStringType_encode(JSC::JSCell* self) {
    return "*";
}
const FFITypeMethodTable utf8CStringTypeMethodTable = {
    .read = &cStringType_read,
    .write = &cStringType_write,
    .canConvert = &cStringType_canConvert,
    .ffiType = &ffi_type_pointer,
    .encode = &cStringType_encode
};
}
