//
//  FunctionReferenceTypeInstance.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/18/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__FunctionReferenceTypeInstance__
#define __NativeScript__FunctionReferenceTypeInstance__

#include "FFIType.h"

namespace NativeScript {
class FunctionReferenceTypeInstance : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static FunctionReferenceTypeInstance* create(JSC::VM& vm, JSC::Structure* structure, JSCell* returnType, const WTF::Vector<JSCell*>& parameterTypes) {
        FunctionReferenceTypeInstance* cell = new (NotNull, JSC::allocateCell<FunctionReferenceTypeInstance>(vm.heap)) FunctionReferenceTypeInstance(vm, structure);
        cell->finishCreation(vm, returnType, parameterTypes);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    const FFITypeMethodTable& ffiTypeMethodTable() const {
        return this->_ffiTypeMethodTable;
    }

    JSC::JSCell* returnType() const {
        return this->_returnType.get();
    }

    const WTF::Vector<JSC::JSCell*> parameterTypes() const {
        WTF::Vector<JSC::JSCell*> result(this->_parameterTypes.size());
        for (size_t i = 0; i < this->_parameterTypes.size(); ++i) {
            result[i] = this->_parameterTypes[i].get();
        }
        return result;
    }

private:
    FunctionReferenceTypeInstance(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<FunctionReferenceTypeInstance*>(cell)->~FunctionReferenceTypeInstance();
    }

    void finishCreation(JSC::VM&, JSCell* returnType, const WTF::Vector<JSCell*>& parameterTypes);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static JSC::JSValue read(JSC::ExecState*, void const*, JSC::JSCell*);

    static void write(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell*);

    static bool canConvert(JSC::ExecState*, const JSC::JSValue&, JSC::JSCell*);

    static const char* encode(JSC::JSCell*);

    static JSC::CallType getCallData(JSC::JSCell* cell, JSC::CallData& callData);

    JSC::WriteBarrier<JSCell> _returnType;

    WTF::Vector<JSC::WriteBarrier<JSCell>> _parameterTypes;

    FFITypeMethodTable _ffiTypeMethodTable;
};
}

#endif /* defined(__NativeScript__FunctionReferenceTypeInstance__) */
