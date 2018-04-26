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
class JSWeakRefInstance : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    DECLARE_INFO;

    static JSWeakRefInstance* create(JSC::VM& vm, JSC::Structure* structure, JSC::JSObject* weakObject) {
        JSWeakRefInstance* object = new (NotNull, JSC::allocateCell<JSWeakRefInstance>(vm.heap)) JSWeakRefInstance(vm, structure);
        object->finishCreation(vm, weakObject);
        return object;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
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
        static_cast<JSWeakRefInstance*>(cell)->~JSWeakRefInstance();
    }

    JSC::Weak<JSObject> _handle;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__JSWeakRefInstance__) */
