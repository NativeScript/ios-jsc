//
//  FFICall.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "FFICall.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo FFICall::s_info = { "FFICall", &Base::s_info, 0, CREATE_METHOD_TABLE(FFICall) };

void FFICall::initializeFFI(VM& vm, JSCell* returnType, const Vector<JSCell*>& parameterTypes, size_t initialArgumentIndex) {
    ASSERT(this->methodTable()->destroy != FFICall::destroy);

    this->_initialArgumentIndex = initialArgumentIndex;

    this->_returnTypeCell.set(vm, this, returnType);
    this->_returnType = getFFITypeMethodTable(returnType);

    size_t parametersCount = parameterTypes.size();
    this->putDirect(vm, vm.propertyNames->length, jsNumber(parametersCount), ReadOnly | DontEnum | DontDelete);

    const ffi_type** parameterTypesFFITypes = new const ffi_type*[parametersCount + initialArgumentIndex];

    for (size_t i = 0; i < initialArgumentIndex; ++i) {
        parameterTypesFFITypes[i] = &ffi_type_pointer;
    }

    for (size_t i = 0; i < parametersCount; i++) {
        JSCell* parameterTypeCell = parameterTypes[i];
        this->_parameterTypesCells.append(WriteBarrier<JSCell>(vm, this, parameterTypeCell));

        const FFITypeMethodTable& ffiTypeMethodTable = getFFITypeMethodTable(parameterTypeCell);
        this->_parameterTypes.append(ffiTypeMethodTable);

        parameterTypesFFITypes[i + initialArgumentIndex] = ffiTypeMethodTable.ffiType;
    }

    this->_cif = new ffi_cif;
    ffi_prep_cif(this->_cif, FFI_DEFAULT_ABI, parametersCount + initialArgumentIndex, const_cast<ffi_type*>(this->_returnType.ffiType), const_cast<ffi_type**>(parameterTypesFFITypes));

    this->_argsCount = _cif->nargs;
    this->_stackSize = 0;

    this->_argsArrayOffset = this->_stackSize;
    this->_stackSize += sizeof(void * [this->_cif->nargs]);

    this->_returnOffset = this->_stackSize;
    this->_stackSize += this->_cif->rtype->size;

    for (size_t i = 0; i < this->_argsCount; i++) {
        this->_argValueOffsets.push_back(this->_stackSize);
        this->_stackSize += this->_cif->arg_types[i]->size;
    }
}

FFICall::~FFICall() {
    delete[] this->_cif->arg_types;
    delete this->_cif;
}

void FFICall::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    FFICall* ffiCall = jsCast<FFICall*>(cell);
    visitor.append(&ffiCall->_returnTypeCell);
    visitor.append(ffiCall->_parameterTypesCells.begin(), ffiCall->_parameterTypesCells.end());
}

void FFICall::preCall(ExecState* execState, uint8_t* buffer) {
    const size_t parametersCount = this->_parameterTypes.size();
    if (parametersCount != execState->argumentCount()) {
        WTF::String message = WTF::String::format("Actual arguments count: \"%lu\". Expected: \"%lu\". ", execState->argumentCount(), parametersCount);
        execState->vm().throwException(execState, createError(execState, message));
        return;
    }

    // TODO: Check if arguments can be converted

    for (unsigned i = 0; i < parametersCount; i++) {
        JSValue argument = execState->uncheckedArgument(i);
        void* argumentBuffer = reinterpret_cast<void**>(buffer + this->_argsArrayOffset)[i + this->_initialArgumentIndex];
        JSCell* parameterType = this->_parameterTypesCells[i].get();
        this->_parameterTypes[i].write(execState, argument, argumentBuffer, parameterType);

        if (execState->hadException()) {
            return;
        }
    }
}
}