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
public:
    typedef JSC::InternalFunction Base;

    void* getReturn() {
        return this->_return;
    }

    DECLARE_INFO;

protected:
    FFICall(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~FFICall();

    void initializeFFI(JSC::VM& vm, JSC::JSCell* returnType, const WTF::Vector<JSC::JSCell*>& parameterTypes, size_t initialArgumentIndex = 0);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    void preCall(JSC::ExecState*);

    JSC::JSValue postCall(JSC::ExecState*);

    template <class T>
    void setArgument(unsigned index, T argumentValue) {
        *static_cast<T*>(this->_arguments[index]) = argumentValue;
    }

    template <class T>
    T getArgument(unsigned index) const {
        return *static_cast<T*>(this->_arguments[index]);
    }

    void executeFFICall(void (*function)(void)) {
        ffi_call(this->_cif, function, this->_return, this->_arguments);
    }

    JSC::WriteBarrier<JSC::JSCell> _returnTypeCell;
    FFITypeMethodTable _returnType;
    void* _return;

    WTF::Vector<JSC::WriteBarrier<JSC::JSCell>> _parameterTypesCells;
    WTF::Vector<FFITypeMethodTable> _parameterTypes;
    void** _arguments;

    size_t _initialArgumentIndex;

    ffi_cif* _cif;
};
}

#endif /* defined(__NativeScript__FFICall__) */
