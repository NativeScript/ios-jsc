//
//  FFICall.hpp
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 10/15/18.
//

#ifndef FFICall_h
#define FFICall_h

#include "FFIType.h"
#include "ReleasePool.h"
#include <JavaScriptCore/Exception.h>
#include <vector>

namespace NativeScript {

class FunctionWrapper;

using namespace JSC;
class FFICall {
public:
    class Invocation {
        friend class FunctionWrapper;

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

        const FFICall* owner;

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

        uint8_t* _buffer;
    };

    typedef void (*InvocationHook)(FFICall*, JSC::ExecState*, Invocation&);
    struct InvocationHooks {
        InvocationHook pre;
        InvocationHook post;
    };

    FFICall(FunctionWrapper* owner)
        : owner(owner) {
    }

    bool (*_argumentCountValidator)(FFICall*, JSC::ExecState*) = [](FFICall* call, JSC::ExecState* execState) {
        return call->parametersCount() == execState->argumentCount();
    };

    const std::shared_ptr<CifWrapper>& cif() const {
        return this->_cif;
    }

    size_t parametersCount() const {
        return this->_parameterTypesCells.size();
    }

    size_t argsCount() const {
        return this->_argsCount;
    }

    FFITypeMethodTable returnType() const {
        return this->_returnType;
    }

    size_t stackSize() const {
        return this->_stackSize;
    }

    size_t returnOffset() const {
        return this->_returnOffset;
    }

    size_t argsArrayOffset() const {
        return this->_argsArrayOffset;
    }

    JSC::WriteBarrier<JSC::JSCell> returnTypeCell() const {
        return this->_returnTypeCell;
    }

    const WTF::Vector<JSC::WriteBarrier<JSC::JSCell>>& parameterTypesCells() const {
        return this->_parameterTypesCells;
    }

    const WTF::Vector<FFITypeMethodTable>& parameterTypes() const {
        return this->_parameterTypes;
    }

    std::shared_ptr<CifWrapper> getCif(ffi_type* rtype, std::vector<const ffi_type*> atypes);

    std::vector<const ffi_type*> signatureVector;

    void preCall(JSC::ExecState* execState, Invocation& invocation) {
        JSC::VM& vm = execState->vm();
        auto scope = DECLARE_THROW_SCOPE(vm);

        if (!this->_argumentCountValidator(this, execState)) {
            WTF::String message = WTF::String::format("Actual arguments count: \"%lu\". Expected: \"%lu\".", execState->argumentCount(), this->parametersCount());
            throwException(execState, scope, JSC::createError(execState, message, defaultSourceAppender));
            return;
        }

        // TODO: Check if arguments can be converted

        for (size_t i = 0; i < execState->argumentCount(); i++) {
            JSC::JSValue argument = execState->uncheckedArgument(i);
            JSCell* parameterType = _parameterTypesCells[i].get();
            _parameterTypes[i].write(execState, argument, invocation.argumentBuffer(i + _initialArgumentIndex), parameterType);

            if (scope.exception()) {
                return;
            }
        }

        this->_invocationHooks.pre(this, execState, invocation);
    }

    void postCall(JSC::ExecState* execState, Invocation& invocation) {
        if (FFICall::InvocationHook post = this->_invocationHooks.post) {
            post(this, execState, invocation);
        }
    }

    void initializeFFI(JSC::VM&, const InvocationHooks&, JSC::JSCell* returnType, const WTF::Vector<Strong<JSC::JSCell>>& parameterTypes, size_t initialArgumentIndex = 0);

protected:
    std::shared_ptr<CifWrapper> _cif;

    FunctionWrapper* owner;

    InvocationHooks _invocationHooks;

    FFITypeMethodTable _returnType;
    JSC::WriteBarrier<JSC::JSCell> _returnTypeCell;

    WTF::Vector<FFITypeMethodTable> _parameterTypes;
    WTF::Vector<JSC::WriteBarrier<JSC::JSCell>> _parameterTypesCells;

    size_t _initialArgumentIndex;

    size_t _argsCount;
    size_t _stackSize;
    size_t _returnOffset;
    size_t _argsArrayOffset;
    std::vector<size_t> _argValueOffsets;
};
} // namespace NativeScript

#endif /* FFICall_hpp */
