//
//  AllocatedPlaceholder.h
//  NativeScript
//
//  Created by Ivan Buhov on 7/9/15.
//
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
        return this->_wrappedObject.get();
    }

private:
    WTF::RetainPtr<id> _wrappedObject;

    AllocatedPlaceholder(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM& vm, GlobalObject* globalObject, id wrappedObject, JSC::Structure* instanceStructure) {
        Base::finishCreation(vm);
        this->_wrappedObject = wrappedObject;
        this->putDirect(vm, globalObject->instanceStructureIdentifier(), JSC::JSValue(instanceStructure), JSC::ReadOnly | JSC::DontEnum | JSC::DontDelete);
    }
};
}

#endif /* defined(__NativeScript__AllocatedPlaceholder__) */
