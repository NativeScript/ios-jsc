//
//  JSWeakRefInstance.h
//  NativeScript
//
//  Created by Yavor Georgiev on 02.10.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__JSWeakRefInstance__
#define __NativeScript__JSWeakRefInstance__

#include <JavaScriptCore/Weak.h>
#include <JavaScriptCore/WeakInlines.h>

namespace NativeScript {
class JSWeakRefInstance : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    DECLARE_INFO;

    static const bool needsDestruction = false;

    static JSWeakRefInstance* create(JSC::VM& vm, JSC::Structure* structure, JSC::JSCell* cell) {
        JSWeakRefInstance* object = new (NotNull, JSC::allocateCell<JSWeakRefInstance>(vm.heap)) JSWeakRefInstance(vm, structure);
        object->finishCreation(vm, cell);
        vm.heap.addFinalizer(object, destroy);
        return object;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    JSCell* cell() const {
        return this->_handle.get();
    }

    void clear() {
        this->_handle.clear();
    }

    ~JSWeakRefInstance() {
    }

private:
    JSWeakRefInstance(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM& vm, JSC::JSCell* cell) {
        Base::finishCreation(vm);
        this->_handle = cell;
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<JSWeakRefInstance*>(cell)->~JSWeakRefInstance();
    }

    JSC::Weak<JSCell> _handle;
};
}

#endif /* defined(__NativeScript__JSWeakRefInstance__) */
