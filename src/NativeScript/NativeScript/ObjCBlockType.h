//
//  ObjCBlockType.h
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCBlockType__
#define __NativeScript__ObjCBlockType__

#include "FFIType.h"

namespace NativeScript {
class ObjCBlockType : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static ObjCBlockType* create(JSC::VM& vm, JSC::Structure* structure, JSCell* returnType, const WTF::Vector<JSCell*>& parameterTypes) {
        ObjCBlockType* cell = new (NotNull, JSC::allocateCell<ObjCBlockType>(vm.heap)) ObjCBlockType(vm, structure);
        cell->finishCreation(vm, returnType, parameterTypes);
        vm.heap.addFinalizer(cell, destroy);
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
    ObjCBlockType(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<ObjCBlockType*>(cell)->~ObjCBlockType();
    }

    void finishCreation(JSC::VM&, JSCell* returnType, const WTF::Vector<JSCell*>& parameterTypes);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static JSC::JSValue read(JSC::ExecState*, void const*, JSC::JSCell*);

    static void write(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell*);

    static void postCall(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell*);

    static bool canConvert(JSC::ExecState*, const JSC::JSValue&, JSC::JSCell*);

    static JSC::CallType getCallData(JSC::JSCell* cell, JSC::CallData& callData);

    JSC::WriteBarrier<JSCell> _returnType;

    WTF::Vector<JSC::WriteBarrier<JSCell>> _parameterTypes;

    FFITypeMethodTable _ffiTypeMethodTable;
};
}

#endif /* defined(__NativeScript__ObjCBlockType__) */
