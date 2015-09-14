//
//  AllocatedPlaceholder.h
//  NativeScript
//
//  Created by Ivan Buhov on 7/9/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#ifndef __NativeScript__AllocatedPlaceholder__
#define __NativeScript__AllocatedPlaceholder__

namespace NativeScript {
class AllocatedPlaceholder : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static AllocatedPlaceholder* create(JSC::VM& vm, GlobalObject* globalObject, JSC::Structure* structure, id wrappedObject, JSC::Structure* instanceStructure) {
        AllocatedPlaceholder* object = new (NotNull, JSC::allocateCell<AllocatedPlaceholder>(vm.heap)) AllocatedPlaceholder(vm, structure);
        object->finishCreation(vm, globalObject, wrappedObject, instanceStructure);
        return object;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    id wrappedObject() const {
        return this->_wrappedObject;
    }

    JSC::Structure* instanceStructure() const {
        return this->_instanceStructure.get();
    }

private:
    id _wrappedObject;

    JSC::WriteBarrier<JSC::Structure> _instanceStructure;

    AllocatedPlaceholder(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM& vm, GlobalObject* globalObject, id wrappedObject, JSC::Structure* instanceStructure) {
        Base::finishCreation(vm);
        this->_wrappedObject = wrappedObject;
        this->_instanceStructure.set(vm, this, instanceStructure);
    }

    static void visitChildren(JSCell*, JSC::SlotVisitor&);
};
}

#endif /* defined(__NativeScript__AllocatedPlaceholder__) */
