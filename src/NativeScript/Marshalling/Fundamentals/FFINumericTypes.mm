//
//  FFINumericTypes.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/16/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "FFINumericTypes.h"
#include <string.h>

namespace NativeScript {
using namespace JSC;

#define CREATE_NUMERIC_TYPE_METHOD_TABLE(name, T, ffi_type)                                           \
    static JSValue name##Read(ExecState* execState, const void* buffer, JSCell* self) {               \
        return jsNumber(*static_cast<const T*>(buffer));                                              \
    }                                                                                                 \
    static void name##Write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) { \
        *static_cast<T*>(buffer) = value.toNumber(execState);                                         \
    }                                                                                                 \
    static bool name##CanConvert(ExecState* execState, const JSValue& value, JSCell* self) {          \
        return value.isNumber();                                                                      \
    }                                                                                                 \
    static const char* name##encode(JSCell* self) {                                                   \
        return @encode(T);                                                                            \
    }                                                                                                 \
    const FFITypeMethodTable name##TypeMethodTable = {                                                \
        .read = name##Read,                                                                           \
        .write = name##Write,                                                                         \
        .canConvert = name##CanConvert,                                                               \
        .ffiType = &ffi_type,                                                                         \
        .encode = name##encode                                                                        \
    };

CREATE_NUMERIC_TYPE_METHOD_TABLE(int8, int8_t, ffi_type_sint8);
CREATE_NUMERIC_TYPE_METHOD_TABLE(uint8, uint8_t, ffi_type_uint8);
CREATE_NUMERIC_TYPE_METHOD_TABLE(int16, int16_t, ffi_type_sint16);
CREATE_NUMERIC_TYPE_METHOD_TABLE(uint16, uint16_t, ffi_type_uint16);
CREATE_NUMERIC_TYPE_METHOD_TABLE(int32, int32_t, ffi_type_sint32);
CREATE_NUMERIC_TYPE_METHOD_TABLE(uint32, uint32_t, ffi_type_uint32);
CREATE_NUMERIC_TYPE_METHOD_TABLE(int64, int64_t, ffi_type_sint64);
CREATE_NUMERIC_TYPE_METHOD_TABLE(uint64, uint64_t, ffi_type_uint64);
CREATE_NUMERIC_TYPE_METHOD_TABLE(float, float, ffi_type_float);
CREATE_NUMERIC_TYPE_METHOD_TABLE(double, double, ffi_type_double);
}
