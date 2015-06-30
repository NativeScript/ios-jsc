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
#include <vector>

namespace NativeScript {
class FFICall : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    void* getReturn(uint8_t* buffer) {
        return static_cast<void*>(buffer + this->_returnOffset);
    }

    DECLARE_INFO;

protected:
    FFICall(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~FFICall();

    void initializeFFI(JSC::VM& vm, JSC::JSCell* returnType, const WTF::Vector<JSC::JSCell*>& parameterTypes, size_t initialArgumentIndex = 0);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    template <class Derived>
    static JSC::EncodedJSValue baseExecuteCall(JSC::ExecState* execState) {
        auto instance = JSC::jsCast<Derived*>(execState->callee());
        uint8_t* buffer = (uint8_t*)alloca(instance->_stackSize);
        void** args = reinterpret_cast<void**>(buffer + instance->_argsArrayOffset);
        for (size_t i = 0; i < instance->_argsCount; i++) {
            args[i] = buffer + instance->_argValueOffsets[i];
        }
        return instance->derivedExecuteCall(buffer, execState);
    }

    void preCall(uint8_t* buffer, JSC::ExecState* execState);

    JSC::JSValue postCall(uint8_t* buffer, JSC::ExecState* execState);

    template <class T>
    void setArgument(uint8_t* buffer, unsigned index, T argumentValue) {
        *static_cast<T*>(static_cast<void*>(buffer + this->_argValueOffsets[index])) = argumentValue;
    }

    template <class T>
    T getArgument(uint8_t* buffer, unsigned index) const {
        return *static_cast<T*>(buffer + this->_argValueOffsets[index]);
    }

    void executeFFICall(uint8_t* buffer, JSC::ExecState* execState, void (*function)(void)) {
        JSC::JSLock::DropAllLocks locksDropper(execState);
        ffi_call(this->_cif, function, reinterpret_cast<void*>(buffer + this->_returnOffset), reinterpret_cast<void**>(buffer + this->_argsArrayOffset));
    }

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
    JSC::EncodedJSValue derivedExecuteCall(uint8_t* buffer, JSC::ExecState* execState);
};
}

#endif /* defined(__NativeScript__FFICall__) */
