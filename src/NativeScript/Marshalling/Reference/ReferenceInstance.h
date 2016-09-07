//
//  ReferenceInstance.h
//  NativeScript
//
//  Created by Jason Zhekov on 8/6/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ReferenceInstance__
#define __NativeScript__ReferenceInstance__

#include "FFIType.h"
#include "PointerInstance.h"

namespace NativeScript {
class ReferenceType;

class ReferenceInstance : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    DECLARE_INFO;

    static ReferenceInstance* create(JSC::VM& vm, JSC::Structure* structure, JSC::JSValue value = JSC::jsUndefined()) {
        ReferenceInstance* cell = new (NotNull, JSC::allocateCell<ReferenceInstance>(vm.heap)) ReferenceInstance(vm, structure);
        cell->finishCreation(vm, value);
        return cell;
    }

    static ReferenceInstance* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, JSC::JSCell* innerType, PointerInstance* pointer) {
        ReferenceInstance* object = new (NotNull, JSC::allocateCell<ReferenceInstance>(vm.heap)) ReferenceInstance(vm, structure);
        object->finishCreation(vm, globalObject, innerType, pointer);
        return object;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    void createBackingStorage(JSC::VM&, GlobalObject*, JSC::ExecState*, JSC::JSCell* innerType);

    void* data() const {
        return this->_pointer ? this->_pointer->data() : nullptr;
    }

    PointerInstance* pointer() const {
        return this->_pointer.get();
    }

    JSC::JSCell* innerType() const {
        return this->_innerTypeCell.get();
    }

    const FFITypeMethodTable& ffiTypeMethodTable() {
        return this->_ffiTypeMethodTable;
    }

    static bool getOwnPropertySlotByIndex(JSC::JSObject*, JSC::ExecState*, unsigned int, JSC::PropertySlot&);

    static void putByIndex(JSCell*, JSC::ExecState*, unsigned int, JSC::JSValue, bool shouldThrow);

private:
    ReferenceInstance(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<ReferenceInstance*>(cell)->~ReferenceInstance();
    }

    void finishCreation(JSC::VM&, JSC::JSValue);

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, JSC::JSCell* innerType, PointerInstance*);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    void setType(JSC::VM&, JSC::JSCell* innerType);

    JSC::WriteBarrier<PointerInstance> _pointer;

    JSC::WriteBarrier<JSC::JSCell> _innerTypeCell;

    FFITypeMethodTable _ffiTypeMethodTable;
};
}

#endif /* defined(__NativeScript__ReferenceInstance__) */
