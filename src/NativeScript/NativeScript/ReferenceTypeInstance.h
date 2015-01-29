//
//  ReferenceTypeInstance.h
//  NativeScript
//
//  Created by Yavor Georgiev on 21.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__ReferenceTypeInstance__
#define __NativeScript__ReferenceTypeInstance__

#include "FFIType.h"

namespace NativeScript {
class ReferenceTypeInstance : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static ReferenceTypeInstance* create(JSC::VM& vm, JSC::Structure* structure, JSC::JSCell* innerType) {
        ReferenceTypeInstance* cell = new (NotNull, JSC::allocateCell<ReferenceTypeInstance>(vm.heap)) ReferenceTypeInstance(vm, structure);
        cell->finishCreation(vm, innerType);
        vm.heap.addFinalizer(cell, destroy);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    JSC::JSCell* innerType() const {
        return this->_innerType.get();
    }

    const FFITypeMethodTable& ffiTypeMethodTable() const {
        return this->_ffiTypeMethodTable;
    }

private:
    ReferenceTypeInstance(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<ReferenceTypeInstance*>(cell)->~ReferenceTypeInstance();
    }

    void finishCreation(JSC::VM&, JSC::JSCell*);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static JSC::JSValue read(JSC::ExecState*, void const*, JSC::JSCell*);

    static void write(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell*);

    static void postCall(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell*);

    static bool canConvert(JSC::ExecState*, const JSC::JSValue&, JSC::JSCell*);

    static JSC::CallType getCallData(JSC::JSCell* cell, JSC::CallData& callData);

    JSC::WriteBarrier<JSC::JSCell> _innerType;

    FFITypeMethodTable _ffiTypeMethodTable;
};
}

#endif /* defined(__NativeScript__ReferenceTypeInstance__) */
