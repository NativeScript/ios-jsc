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
#include <JavaScriptCore/Exception.h>
#include <vector>

namespace NativeScript {
class FFICall : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    DECLARE_INFO;

    size_t parametersCount() const {
        return this->_parameterTypesCells.size();
    }

    JSC::JSObject* async(JSC::ExecState*, JSC::JSValue thisValue, const JSC::ArgList&);

protected:
    FFICall(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~FFICall();

    ffi_cif* _cif;

    class Invocation {
        WTF_MAKE_NONCOPYABLE(Invocation)
        WTF_MAKE_FAST_ALLOCATED;

    public:
        void* function;

        void* argumentBuffer(unsigned index) {
            return _buffer + owner->_argValueOffsets[index];
        }

        template <typename T>
        T& getArgument(unsigned index) {
            return *static_cast<T*>(argumentBuffer(index));
        }

        template <typename T>
        void setArgument(unsigned index, T value) {
            *static_cast<T*>(argumentBuffer(index)) = value;
        }

        void* resultBuffer() {
            return _buffer + owner->_returnOffset;
        }

        template <typename T>
        T& getResult() {
            return *static_cast<T*>(resultBuffer());
        }

        FFICall* owner;

        ~Invocation() {
            WTF::fastFree(_buffer);
        }

    private:
        Invocation(FFICall* owner)
            : owner(owner) {
            _buffer = reinterpret_cast<uint8_t*>(WTF::fastMalloc(owner->_stackSize));
            void** argsArray = reinterpret_cast<void**>(_buffer + owner->_argsArrayOffset);
            for (size_t i = 0; i < owner->_argsCount; i++) {
                argsArray[i] = _buffer + owner->_argValueOffsets[i];
            }
        }

        friend class FFICall;

        uint8_t* _buffer;
    };
    typedef void (*InvocationHook)(FFICall*, JSC::ExecState*, Invocation&);
    struct InvocationHooks {
        InvocationHook pre;
        InvocationHook post;
    };

    friend class FFIInvocation;

    void initializeFFI(JSC::VM&, const InvocationHooks&, JSC::JSCell* returnType, const WTF::Vector<JSC::JSCell*>& parameterTypes, size_t initialArgumentIndex = 0);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);

    static JSC::EncodedJSValue JSC_HOST_CALL call(JSC::ExecState* execState);

    void preCall(JSC::ExecState* execState, Invocation& invocation) {
        if (!this->_argumentCountValidator(this, execState)) {
            WTF::String message = WTF::String::format("Actual arguments count: \"%lu\". Expected: \"%lu\". ", execState->argumentCount(), this->parametersCount());
            execState->vm().throwException(execState, JSC::createError(execState, message));
            return;
        }

        // TODO: Check if arguments can be converted

        for (size_t i = 0; i < execState->argumentCount(); i++) {
            JSC::JSValue argument = execState->uncheckedArgument(i);
            JSCell* parameterType = _parameterTypesCells[i].get();
            _parameterTypes[i].write(execState, argument, invocation.argumentBuffer(i + _initialArgumentIndex), parameterType);

            if (execState->hadException()) {
                return;
            }
        }
    }

    bool (*_argumentCountValidator)(FFICall*, JSC::ExecState*) = [](FFICall* call, JSC::ExecState* execState) {
        return call->parametersCount() == execState->argumentCount();
    };

    InvocationHooks _invocationHooks;

    JSC::WriteBarrier<JSC::JSCell> _returnTypeCell;
    FFITypeMethodTable _returnType;

    WTF::Vector<JSC::WriteBarrier<JSC::JSCell>> _parameterTypesCells;
    WTF::Vector<FFITypeMethodTable> _parameterTypes;

    size_t _initialArgumentIndex;

    size_t _argsCount;
    size_t _stackSize;
    size_t _returnOffset;
    size_t _argsArrayOffset;
    std::vector<size_t> _argValueOffsets;
};
}

#endif /* defined(__NativeScript__FFICall__) */
