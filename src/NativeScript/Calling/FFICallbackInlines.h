//
//  FFICallbackInlines.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/23/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__FFICallbackInlines__
#define __NativeScript__FFICallbackInlines__

#include <JavaScriptCore/CatchScope.h>

#include "FFICallback.h"
#include "JSErrors.h"

namespace NativeScript {

template <class DerivedCallback>
const JSC::ClassInfo FFICallback<DerivedCallback>::s_info = { "FFICallback", nullptr, nullptr, nullptr, CREATE_METHOD_TABLE(FFICallback) };

template <class DerivedCallback>
inline void FFICallback<DerivedCallback>::ffiClosureCallback(ffi_cif* cif, void* retValue, void** argValues, void* userData) {
    FFICallback* callback = static_cast<FFICallback*>(userData);
    JSC::ExecState* execState = callback->_globalExecState;
    JSC::VM& vm = execState->vm();
    JSC::JSLockHolder lock(vm);

    auto scope = DECLARE_CATCH_SCOPE(vm);

    static_cast<DerivedCallback*>(callback)->ffiClosureCallback(retValue, argValues, userData);

    reportErrorIfAny(execState, scope);
}

template <class DerivedCallback>
inline void FFICallback<DerivedCallback>::marshallArguments(void** argValues, JSC::MarkedArgumentBuffer& argumentBuffer, FFICallback* self) {
    for (size_t i = 0; i < this->_parameterTypes.size(); ++i) {
        JSC::VM& vm = this->_globalExecState->vm();
        auto scope = DECLARE_THROW_SCOPE(vm);

        JSC::JSValue argument = this->_parameterTypes[i].read(this->_globalExecState, argValues[i + self->_initialArgumentIndex], this->_parameterTypesCells[i].get());
        argumentBuffer.append(argument);

        if (scope.exception()) {
            break;
        }
    }
}

template <class DerivedCallback>
inline void FFICallback<DerivedCallback>::callFunction(const JSC::JSValue& thisValue, const JSC::ArgList& arguments, void* retValue) {
    JSC::ExecState* execState = this->_globalExecState;
    JSC::VM& vm = this->_globalExecState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    JSC::CallData callData;
    JSC::CallType callType;
    if ((callType = this->_function.get()->methodTable()->getCallData(this->_function.get(), callData)) == JSC::CallType::None) {
        scope.throwException(execState, createNotAFunctionError(execState, this->_function.get()));
        return;
    }

    JSC::JSValue result = JSC::call(execState, this->_function.get(), callType, callData, thisValue, arguments);
    if (scope.exception()) {
        return;
    }

    this->_returnType.write(execState, result, retValue, this->_returnTypeCell.get());
}

template <class DerivedCallback>
inline void FFICallback<DerivedCallback>::finishCreation(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSCell* function, JSC::JSCell* returnType, const WTF::Vector<JSC::JSCell*>& parameterTypes, size_t initialArgumentIndex) {
    Base::finishCreation(vm);

    this->_globalExecState = globalObject->globalExec();
    this->_function.set(vm, this, function);

    this->_initialArgumentIndex = initialArgumentIndex;

    this->_returnTypeCell.set(vm, this, returnType);
    this->_returnType = getFFITypeMethodTable(vm, returnType);

    size_t parametersCount = parameterTypes.size();

    const ffi_type** parameterTypesFFITypes = new const ffi_type*[parametersCount + initialArgumentIndex];

    for (size_t i = 0; i < initialArgumentIndex; ++i) {
        parameterTypesFFITypes[i] = &ffi_type_pointer;
    }

    for (size_t i = 0; i < parametersCount; ++i) {
        JSCell* parameterTypeCell = parameterTypes[i];
        this->_parameterTypesCells.append(JSC::WriteBarrier<JSCell>(vm, this, parameterTypeCell));

        const FFITypeMethodTable& ffiTypeMethodTable = getFFITypeMethodTable(vm, parameterTypeCell);
        this->_parameterTypes.append(ffiTypeMethodTable);

        parameterTypesFFITypes[i + initialArgumentIndex] = ffiTypeMethodTable.ffiType;
    }

    this->_cif = new ffi_cif;

    ffi_prep_cif(this->_cif, FFI_DEFAULT_ABI, parametersCount + initialArgumentIndex, const_cast<ffi_type*>(this->_returnType.ffiType), const_cast<ffi_type**>(parameterTypesFFITypes));
    this->_closure = static_cast<ffi_closure*>(ffi_closure_alloc(sizeof(ffi_closure), &this->_functionPointer));
    ffi_prep_closure_loc(this->_closure, this->_cif, &ffiClosureCallback, this, this->_functionPointer);
}

template <class DerivedCallback>
inline void FFICallback<DerivedCallback>::visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    FFICallback* ffiCall = JSC::jsCast<FFICallback*>(cell);
    visitor.append(ffiCall->_function);
    visitor.append(ffiCall->_returnTypeCell);
    visitor.append(ffiCall->_parameterTypesCells.begin(), ffiCall->_parameterTypesCells.end());
}

template <class DerivedCallback>
inline FFICallback<DerivedCallback>::~FFICallback() {
    ffi_closure_free(this->_closure);
    delete[] this->_cif->arg_types;
    delete this->_cif;
}
} // namespace NativeScript

#endif /* defined(__NativeScript__FFICallbackInlines__) */
