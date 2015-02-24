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

    static JSWeakRefInstance* create(JSC::VM& vm, JSC::Structure* structure, JSC::JSObject* object) {
        JSWeakRefInstance* weakref = new (NotNull, JSC::allocateCell<JSWeakRefInstance>(vm.heap)) JSWeakRefInstance(vm, structure);
        weakref->finishCreation(vm, object);
        vm.heap.addFinalizer(weakref, destroy);
        return weakref;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    JSObject* cell() const {
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

    void finishCreation(JSC::VM& vm, JSC::JSObject* object) {
        Base::finishCreation(vm);
        this->_handle = object;
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<JSWeakRefInstance*>(cell)->~JSWeakRefInstance();
    }

    JSC::Weak<JSObject> _handle;
};
}

#endif /* defined(__NativeScript__JSWeakRefInstance__) */
