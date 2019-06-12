//
//  FFIType.h
//  NativeScript
//
//  Created by Yavor Georgiev on 11.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__FFIType__
#define __NativeScript__FFIType__

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundef"
#include <ffi.h>
#pragma clang diagnostic pop
#include <vector>

namespace NativeScript {

struct FFITypeMethodTable {
    JSC::JSValue (*read)(JSC::ExecState*, const void*, JSC::JSCell* self);

    void (*write)(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell* self);

    bool (*canConvert)(JSC::ExecState*, const JSC::JSValue&, JSC::JSCell* self);

    const ffi_type* ffiType;

    const char* (*encode)(JSC::VM& vm, JSC::JSCell* self);
};

bool tryGetFFITypeMethodTable(JSC::VM& vm, JSC::JSValue value, const FFITypeMethodTable** methodTable);

const FFITypeMethodTable& getFFITypeMethodTable(JSC::VM& vm, JSC::JSCell* cell);

// Wraps a ffi_cif structure and its alotted argument types vector.
// This binds the lifetimes of both entities together and resolves memory leaks.
class CifWrapper {
public:
    CifWrapper(ffi_type* rtype, std::vector<const ffi_type*> atypes)
        : atypes(atypes)
        , cif(new ffi_cif) {

        ffi_prep_cif(cif.get(), FFI_DEFAULT_ABI, atypes.size(), rtype, const_cast<ffi_type**>(&this->atypes.front()));
    }

    ffi_cif* get() const {
        return this->cif.get();
    }

    ffi_cif* operator->() const {
        return this->cif.get();
    }

    operator ffi_cif*() const {
        return this->cif.get();
    }

private:
    std::vector<const ffi_type*> atypes;
    std::unique_ptr<ffi_cif> cif;
};

} // namespace NativeScript

#endif /* defined(__NativeScript__FFIType__) */
