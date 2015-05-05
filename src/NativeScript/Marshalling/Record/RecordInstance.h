//
//  RecordInstance.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/13/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__RecordInstance__
#define __NativeScript__RecordInstance__

#include "PointerInstance.h"

namespace NativeScript {

class RecordInstance : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static RecordInstance* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, size_t size, PointerInstance* pointer) {
        RecordInstance* cell = new (NotNull, JSC::allocateCell<RecordInstance>(vm.heap)) RecordInstance(vm, structure);
        cell->finishCreation(vm, globalObject, size, pointer);
        vm.heap.addFinalizer(cell, destroy);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(globalObject->vm(), globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    void* data() const {
        return _pointer.get()->data();
    }

    size_t size() const {
        return this->_size;
    }

private:
    RecordInstance(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<RecordInstance*>(cell)->~RecordInstance();
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, size_t size, PointerInstance* pointer);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    JSC::WriteBarrier<PointerInstance> _pointer;

    size_t _size;
};
}

#endif /* defined(__NativeScript__RecordInstance__) */
