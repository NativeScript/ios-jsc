//
//  FFICall.h
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__FFICall__
#define __NativeScript__FFICall__

#include "FFIType.h"
#include "ReleasePool.h"
#include <vector>

namespace NativeScript {
class FFICall : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    void* getReturn(uint8_t* buffer) {
        return static_cast<void*>(buffer + this->_returnOffset);
    }

    DECLARE_INFO;

    size_t parametersCount() const {
        return this->_parameterTypesCells.size();
    }

protected:
    FFICall(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~FFICall();

    void initializeFFI(JSC::VM& vm, JSC::JSCell* returnType, const WTF::Vector<JSC::JSCell*>& parameterTypes, size_t initialArgumentIndex = 0);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    template <class Derived>
    static JSC::EncodedJSValue JSC_HOST_CALL executeCall(JSC::ExecState* execState) {
        auto instance = JSC::jsCast<Derived*>(execState->callee());
        uint8_t* buffer = reinterpret_cast<uint8_t*>(alloca(instance->_stackSize));
        void** args = reinterpret_cast<void**>(buffer + instance->_argsArrayOffset);
        for (size_t i = 0; i < instance->_argsCount; i++) {
            args[i] = buffer + instance->_argValueOffsets[i];
        }

        ReleasePoolHolder poolHolder;

        instance->preCall(execState, buffer);
        if (execState->hadException()) {
            return JSC::JSValue::encode(JSC::jsUndefined());
        }

        return instance->derivedExecuteCall(execState, buffer);
    }

    void preCall(JSC::ExecState* execState, uint8_t* buffer);

    JSC::JSValue postCall(JSC::ExecState* execState, uint8_t* buffer) {
        return this->_returnType.read(execState, buffer + this->_returnOffset, this->_returnTypeCell.get());
    }

    template <class T>
    void setArgument(uint8_t* buffer, unsigned index, T argumentValue) {
        *static_cast<T*>(static_cast<void*>(buffer + this->_argValueOffsets[index])) = argumentValue;
    }

    template <class T>
    T getArgument(uint8_t* buffer, unsigned index) const {
        return *static_cast<T*>(buffer + this->_argValueOffsets[index]);
    }

    void executeFFICall(JSC::ExecState* execState, uint8_t* buffer, void (*function)(void)) {
        JSC::JSLock::DropAllLocks locksDropper(execState);
        ffi_call(this->_cif, function, reinterpret_cast<void*>(buffer + this->_returnOffset), reinterpret_cast<void**>(buffer + this->_argsArrayOffset));
    }

    bool (*_argumentCountValidator)(FFICall*, JSC::ExecState*) = [](FFICall* call, JSC::ExecState* execState) {
        return call->parametersCount() == execState->argumentCount();
    };

    JSC::WriteBarrier<JSC::JSCell> _returnTypeCell;
    FFITypeMethodTable _returnType;

    WTF::Vector<JSC::WriteBarrier<JSC::JSCell>> _parameterTypesCells;
    WTF::Vector<FFITypeMethodTable> _parameterTypes;

    size_t _initialArgumentIndex;

    ffi_cif* _cif;

    size_t _argsCount;
    size_t _stackSize;
    size_t _returnOffset;
    size_t _argsArrayOffset;
    std::vector<size_t> _argValueOffsets;

#define FFI_DERIVED_MEMBERS \
    friend class FFICall;   \
    JSC::EncodedJSValue derivedExecuteCall(JSC::ExecState* execState, uint8_t* buffer);
};
}

#endif /* defined(__NativeScript__FFICall__) */
