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

namespace NativeScript {

class FFICall : public JSC::InternalFunction {
private:
    class FFISignature;

public:
    typedef JSC::InternalFunction Base;

    DECLARE_INFO;

protected:
    class FFICallFrame {
        friend class FFICall;
        FFICallFrame(FFISignature& signature, JSC::ExecState* execState, Byte* buffer);

    public:
        template <class T>
        void setArgument(unsigned index, T argumentValue) {
            *static_cast<T*>(this->_arguments[index]) = argumentValue;
        }

        typedef void (*F)();
        void setFunction(F function) {
            _function = function;
        }

        void* result() { return _result; }

        JSC::ExecState* execState() {
            return _execState;
        }

    private:
        JSC::ExecState* _execState;
        void* _result;
        void** _arguments;
        F _function;
    };

    FFICall(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~FFICall();

    void initializeFFI(JSC::VM& vm, JSC::JSCell* returnType, const WTF::Vector<JSC::JSCell*>& parameterTypes, size_t initialArgumentIndex = 0);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    template <class Derived>
    static JSC::EncodedJSValue baseExecuteCall(JSC::ExecState* execState) {
        auto instance = JSC::jsCast<Derived*>(execState->callee());

        Byte* buffer = (Byte*)alloca(instance->_signature.stackSize);
        FFICallFrame frame(instance->_signature, execState, buffer);

        instance->basePreCall(frame);

        if (execState->hadException()) {
            return JSC::JSValue::encode(JSC::JSValue::JSUndefined);
        }

        auto result = instance->call(frame);

        instance->basePostCall(frame);

        return result;
    }

    JSC::EncodedJSValue baseCall(FFICallFrame& frame);

    JSC::WriteBarrier<JSC::JSCell> _returnTypeCell;
    FFITypeMethodTable _returnType;

    WTF::Vector<JSC::WriteBarrier<JSC::JSCell>> _parameterTypesCells;
    WTF::Vector<FFITypeMethodTable> _parameterTypes;

    size_t _initialArgumentIndex;
    ffi_cif* _cif;

#define FFI_DERIVED_MEMBERS \
    friend class FFICall;   \
    JSC::EncodedJSValue call(FFICallFrame&);

private:
    void basePreCall(FFICallFrame&);
    void basePostCall(FFICallFrame&);

    class FFISignature {
    public:
        friend class FFICallFrame;

        struct PostCall {
            size_t argIndex;
            void (*postCall)(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell* self);
            PostCall* next;
        };

        FFISignature();
        ~FFISignature();

        void initialize(ffi_cif* cif, WTF::Vector<FFITypeMethodTable> parameterTypes, size_t initialArgumentIndex);

        size_t stackSize;

        size_t argsCount;

        size_t resultOffset;
        size_t argsArrayOffset;
        size_t* argValueOffsets;

        PostCall* postCalls;
    };

    FFISignature _signature;
};
}

#endif /* defined(__NativeScript__FFICall__) */
