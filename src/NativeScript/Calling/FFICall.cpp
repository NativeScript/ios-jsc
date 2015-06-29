//
//  FFICall.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "FFICall.h"

const size_t MAX_KNOWN_ALIGNMENT = 8;

namespace NativeScript {
using namespace JSC;

FFICall::FFICallFrame::FFICallFrame(FFISignature& signature, ExecState* execState, Byte* buffer)
    : _execState(execState) {

    _result = buffer + signature.resultOffset;
    _arguments = reinterpret_cast<void**>(buffer + signature.argsArrayOffset);

    for (size_t i = 0; i < signature.argsCount; ++i) {
        _arguments[i] = buffer + signature.argValueOffsets[i];
    }
}

FFICall::FFISignature::FFISignature()
    : argValueOffsets(nullptr)
    , postCalls(nullptr) {
}

void align_offset(size_t& offset, size_t alignment) {
    size_t misaligned = offset % alignment;
    if (misaligned) {
        offset += alignment - misaligned;
    }
}

size_t allocate_aligned_offset(size_t& offset, size_t size, size_t alignment) {
    if (!size) {
        return offset;
    }
    align_offset(offset, alignment);
    size_t result = offset;
    offset += size;
    return result;
}

size_t allocate_aligned_ffi_arg(size_t& offset, ffi_type* type) {
    return allocate_aligned_offset(offset, type->size, type->alignment);
}

void FFICall::FFISignature::initialize(ffi_cif* cif, WTF::Vector<FFITypeMethodTable> parameterTypes, size_t initialArgumentIndex) {
    argsCount = cif->nargs;
    argValueOffsets = new size_t[argsCount];
    stackSize = 0;

    argsArrayOffset = allocate_aligned_offset(stackSize, sizeof(void * [cif->nargs]), MAX_KNOWN_ALIGNMENT);
    resultOffset = allocate_aligned_ffi_arg(stackSize, cif->rtype);

    for (size_t i = 0; i < argsCount; i++) {
        argValueOffsets[i] = allocate_aligned_ffi_arg(stackSize, cif->arg_types[i]);
    }

    // Calculate the count of post calls.
    size_t postCallsCount = 0;
    for (size_t i = 0; i < parameterTypes.size(); ++i) {
        if (parameterTypes[i].postCall) {
            postCallsCount++;
        }
    }

    // Create a linked list with post calls packed close in the memory.
    if (postCallsCount) {
        postCalls = new PostCall[postCallsCount];
        PostCall* _currentPostCall = postCalls;
        for (size_t i = 0; i < parameterTypes.size(); ++i) {
            if (parameterTypes[i].postCall) {
                _currentPostCall->argIndex = i;
                _currentPostCall->postCall = parameterTypes[i].postCall;
                _currentPostCall->next = _currentPostCall + 1;
                _currentPostCall = _currentPostCall->next;
            }
        }
        postCalls[postCallsCount - 1].next = nullptr;
    }
}

FFICall::FFISignature::~FFISignature() {
    if (argsArrayOffset) {
        delete[] argValueOffsets;
    }

    if (postCalls) {
        delete[] postCalls;
    }
}

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

    _signature.initialize(_cif, _parameterTypes, _initialArgumentIndex);
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

void FFICall::basePreCall(FFICallFrame& frame) {
    ExecState* execState = frame.execState();
    const size_t parametersCount = this->_parameterTypes.size();
    if (parametersCount != execState->argumentCount()) {
        WTF::String message = WTF::String::format("Actual arguments count: \"%lu\". Expected: \"%lu\". ", execState->argumentCount(), parametersCount);
        execState->vm().throwException(execState, createError(execState, message));
        return;
    }

    // TODO: Check if arguments can be converted
    // TODO: In case of exception, we won't know for which arguments we should execute postCall.

    for (unsigned i = 0; i < parametersCount && !execState->hadException(); i++) {
        JSValue argument = execState->uncheckedArgument(i);
        void* argumentBuffer = frame._arguments[i + this->_initialArgumentIndex];
        JSCell* parameterType = this->_parameterTypesCells[i].get();
        this->_parameterTypes[i].write(execState, argument, argumentBuffer, parameterType);
    }
}

JSC::EncodedJSValue FFICall::baseCall(FFICallFrame& frame) {
    {
        // The scope here is important. Reading the results later will fail if the locks are not reacquired.
        JSC::JSLock::DropAllLocks locksDropper(frame.execState());
        ffi_call(this->_cif, FFI_FN(frame._function), frame._result, frame._arguments);
    }
    JSC::JSValue jsResult = _returnType.read(frame.execState(), frame._result, _returnTypeCell.get());
    return JSC::JSValue::encode(jsResult);
}

void FFICall::basePostCall(FFICallFrame& frame) {
    FFISignature::PostCall* currentPostCall = _signature.postCalls;
    while (currentPostCall) {
        int i = currentPostCall->argIndex;
        JSValue argument = frame.execState()->uncheckedArgument(i);
        void* argumentBuffer = frame._arguments[i + _initialArgumentIndex];
        JSCell* parameterType = this->_parameterTypesCells[i].get();
        currentPostCall->postCall(frame.execState(), argument, argumentBuffer, parameterType);
        currentPostCall = currentPostCall->next;
    }
}
}