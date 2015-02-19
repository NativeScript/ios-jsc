//
//  FFIType.h
//  NativeScript
//
//  Created by Yavor Georgiev on 11.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__FFIType__
#define __NativeScript__FFIType__

#include <ffi.h>

namespace NativeScript {

struct FFITypeMethodTable {
    JSC::JSValue (*read)(JSC::ExecState*, const void*, JSC::JSCell* self);

    void (*write)(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell* self);

    void (*postCall)(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell* self);

    bool (*canConvert)(JSC::ExecState*, const JSC::JSValue&, JSC::JSCell* self);

    const ffi_type* ffiType;

    const char* (*encode)(JSC::JSCell* self);
};

bool tryGetFFITypeMethodTable(JSC::JSValue value, const FFITypeMethodTable** methodTable);

const FFITypeMethodTable& getFFITypeMethodTable(JSC::JSCell* cell);
}

#endif /* defined(__NativeScript__FFIType__) */
