//
//  FFICallback.h
//  NativeScript
//
//  Created by Yavor Georgiev on 20.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__FFICallback__
#define __NativeScript__FFICallback__

#include "FFIType.h"

namespace NativeScript {
template <class DerivedCallback>
class FFICallback : public JSC::JSCell {
public:
    typedef JSC::JSCell Base;

    DECLARE_INFO;

    JSC::JSCell* function() const {
        return this->_function.get();
    }

    void* functionPointer() const {
        return this->_functionPointer;
    }

    JSC::ExecState* execState() const {
        return this->_globalExecState;
    }

protected:
    FFICallback(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~FFICallback();

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<FFICallback*>(cell)->~FFICallback();
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, JSC::JSCell* function, JSC::JSCell* returnType, const WTF::Vector<JSC::JSCell*>& parameterTypes, size_t initialArgumentIndex = 0);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    void marshallArguments(void**, JSC::MarkedArgumentBuffer&, FFICallback* self);

    void callFunction(const JSC::JSValue& thisValue, const JSC::ArgList& arguments, void* retValue);

    JSC::ExecState* _globalExecState;

private:
    static void ffiClosureCallback(ffi_cif*, void* retValue, void** argValues, void* userData);

    JSC::WriteBarrier<JSCell> _returnTypeCell;
    FFITypeMethodTable _returnType;

    WTF::Vector<JSC::WriteBarrier<JSCell>> _parameterTypesCells;
    WTF::Vector<FFITypeMethodTable> _parameterTypes;
    size_t _initialArgumentIndex;

    JSC::WriteBarrier<JSC::JSCell> _function;
    void* _functionPointer;
    ffi_cif* _cif;
    ffi_closure* _closure;
};
}

#endif /* defined(__NativeScript__FFICallback__) */
