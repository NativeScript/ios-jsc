//
//  FunctionWrapper.cpp
//  NativeScript
//
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//  Created by Teodor Dermendzhiev on 10/15/18.
//

#include "FFICall.h"
#include "FFICache.h"
#include "FunctionWrapper.h"
#include <JavaScriptCore/JSPromiseDeferred.h>
#include <JavaScriptCore/StrongInlines.h>
#include <JavaScriptCore/interpreter/FrameTracers.h>
#include <JavaScriptCore/interpreter/Interpreter.h>
#include <dispatch/dispatch.h>
#include <malloc/malloc.h>

namespace NativeScript {

void deleteCif(ffi_cif* cif) {
    delete[] cif->arg_types;
    delete cif;
}

void FFICall::initializeFFI(VM& vm, const InvocationHooks& hooks, JSCell* returnType, const Vector<JSCell*>& parameterTypes, size_t initialArgumentIndex) {
    this->_invocationHooks = hooks;

    this->_initialArgumentIndex = initialArgumentIndex;

    this->_returnTypeCell.set(vm, owner, returnType);
    this->_returnType = getFFITypeMethodTable(vm, returnType);

    size_t parametersCount = parameterTypes.size();

    const ffi_type** parameterTypesFFITypes = new const ffi_type*[parametersCount + initialArgumentIndex];

    this->signatureVector.push_back(getFFITypeMethodTable(vm, returnType).ffiType);

    for (size_t i = 0; i < initialArgumentIndex; ++i) {
        parameterTypesFFITypes[i] = &ffi_type_pointer;
        this->signatureVector.push_back(&ffi_type_pointer);
    }

    for (size_t i = 0; i < parametersCount; i++) {
        JSCell* parameterTypeCell = parameterTypes[i];
        this->_parameterTypesCells.append(WriteBarrier<JSCell>(vm, owner, parameterTypeCell));

        const FFITypeMethodTable& ffiTypeMethodTable = getFFITypeMethodTable(vm, parameterTypeCell);
        this->_parameterTypes.append(ffiTypeMethodTable);

        parameterTypesFFITypes[i + initialArgumentIndex] = ffiTypeMethodTable.ffiType;
        this->signatureVector.push_back(parameterTypesFFITypes[i + initialArgumentIndex]);
    }

    this->_cif = getCif(parametersCount + initialArgumentIndex, const_cast<ffi_type*>(this->_returnType.ffiType), const_cast<ffi_type**>(parameterTypesFFITypes));

    this->_argsCount = _cif->nargs;
    this->_stackSize = 0;

    this->_argsArrayOffset = this->_stackSize;
    this->_stackSize += malloc_good_size(sizeof(void * [this->_cif->nargs]));

    this->_returnOffset = this->_stackSize;
    this->_stackSize += malloc_good_size(std::max(this->_cif.get()->rtype->size, sizeof(ffi_arg)));

    for (size_t i = 0; i < this->_argsCount; i++) {
        this->_argValueOffsets.push_back(this->_stackSize);
        this->_stackSize += malloc_good_size(std::max(this->_cif->arg_types[i]->size, sizeof(ffi_arg)));
    }
}
std::shared_ptr<ffi_cif> FFICall::getCif(unsigned int nargs, ffi_type* rtype, ffi_type** atypes) {

    WTF::LockHolder lock(FFICache::global()->_cacheLock);
    FFICache::FFIMap::const_iterator it = FFICache::global()->cifCache.find(this->signatureVector);

    if (it == FFICache::global()->cifCache.end()) {
        std::shared_ptr<ffi_cif> shared(new ffi_cif, deleteCif);
        ffi_prep_cif(shared.get(), FFI_DEFAULT_ABI, nargs, rtype, atypes);
        FFICache::global()->cifCache[this->signatureVector] = shared;
    }

    return FFICache::global()->cifCache[this->signatureVector];
}

} // namespace NativeScript
