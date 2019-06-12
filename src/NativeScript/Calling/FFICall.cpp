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
#include <JavaScriptCore/interpreter/FrameTracers.h>
#include <JavaScriptCore/interpreter/Interpreter.h>
#include <dispatch/dispatch.h>
#include <malloc/malloc.h>

namespace NativeScript {

void FFICall::initializeFFI(VM& vm, const InvocationHooks& hooks, JSCell* returnType, const Vector<Strong<JSCell>>& parameterTypes, size_t initialArgumentIndex) {
    this->_invocationHooks = hooks;

    this->_initialArgumentIndex = initialArgumentIndex;

    this->_returnTypeCell.set(vm, owner, returnType);
    this->_returnType = getFFITypeMethodTable(vm, returnType);

    size_t parametersCount = parameterTypes.size();

    std::vector<const ffi_type*> parameterTypesFFITypes;
    parameterTypesFFITypes.reserve(parametersCount + initialArgumentIndex);

    this->signatureVector.push_back(getFFITypeMethodTable(vm, returnType).ffiType);

    for (size_t i = 0; i < initialArgumentIndex; ++i) {
        parameterTypesFFITypes.push_back(&ffi_type_pointer);
        this->signatureVector.push_back(&ffi_type_pointer);
    }

    for (size_t i = 0; i < parametersCount; i++) {
        JSCell* parameterTypeCell = parameterTypes[i].get();
        this->_parameterTypesCells.append(WriteBarrier<JSCell>(vm, owner, parameterTypeCell));

        const FFITypeMethodTable& ffiTypeMethodTable = getFFITypeMethodTable(vm, parameterTypeCell);
        this->_parameterTypes.append(ffiTypeMethodTable);

        parameterTypesFFITypes.push_back(ffiTypeMethodTable.ffiType);
        this->signatureVector.push_back(parameterTypesFFITypes[i + initialArgumentIndex]);
    }

    this->_cif = getCif(const_cast<ffi_type*>(this->_returnType.ffiType), parameterTypesFFITypes);

    this->_argsCount = _cif->get()->nargs;
    this->_stackSize = 0;

    this->_argsArrayOffset = this->_stackSize;
    this->_stackSize += malloc_good_size(sizeof(void * [this->_cif->get()->nargs]));

    this->_returnOffset = this->_stackSize;
    this->_stackSize += malloc_good_size(std::max(this->_cif->get()->rtype->size, sizeof(ffi_arg)));

    for (size_t i = 0; i < this->_argsCount; i++) {
        this->_argValueOffsets.push_back(this->_stackSize);
        this->_stackSize += malloc_good_size(std::max(this->_cif->get()->arg_types[i]->size, sizeof(ffi_arg)));
    }
}

std::shared_ptr<CifWrapper> FFICall::getCif(ffi_type* rtype, std::vector<const ffi_type*> atypes) {

    WTF::LockHolder lock(FFICache::global()->_cacheLock);
    FFICache::FFIMap::const_iterator it = FFICache::global()->cifCache.find(this->signatureVector);

    if (it == FFICache::global()->cifCache.end()) {
        FFICache::global()->cifCache[this->signatureVector] = std::make_shared<CifWrapper>(rtype, atypes);
    }

    return FFICache::global()->cifCache[this->signatureVector];
}

} // namespace NativeScript
