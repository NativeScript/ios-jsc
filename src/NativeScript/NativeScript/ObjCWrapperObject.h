//
//  ObjCWrapperObject.h
//  WrapperObject
//
//  Created by Yavor Georgiev on 17.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCWrapperObject__
#define __NativeScript__ObjCWrapperObject__

#include <JavaScriptCore/JSObject.h>
#include <wtf/RetainPtr.h>

namespace NativeScript {
class ObjCWrapperObject : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static ObjCWrapperObject* create(JSC::VM& vm, JSC::Structure* structure, id wrappedObject) {
        ObjCWrapperObject* object = new (NotNull, JSC::allocateCell<ObjCWrapperObject>(vm.heap)) ObjCWrapperObject(vm, structure);
        object->finishCreation(vm, wrappedObject);
        vm.heap.addFinalizer(object, destroy);
        return object;
    }

    static const bool needsDestruction = false;

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    id wrappedObject() const {
        return this->_wrappedObject.get();
    }

    void setWrappedObject(id wrappedObject) {
        this->_wrappedObject = wrappedObject;
    }

    static WTF::String className(const JSObject* object);

    ~ObjCWrapperObject();

private:
    ObjCWrapperObject(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        static_cast<ObjCWrapperObject*>(cell)->~ObjCWrapperObject();
    }

    void finishCreation(JSC::VM& vm, id wrappedObject);

    static bool getOwnPropertySlotByIndex(JSC::JSObject* object, JSC::ExecState* execState, unsigned propertyName, JSC::PropertySlot& propertySlot);

    static void putByIndex(JSC::JSCell* cell, JSC::ExecState* execState, unsigned propertyName, JSC::JSValue value, bool shouldThrow);

    WTF::RetainPtr<id> _wrappedObject;

    bool _canSetObjectAtIndexedSubscript;
};
}

#endif /* defined(__NativeScript__ObjCWrapperObject__) */
