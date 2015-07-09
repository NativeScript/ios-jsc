//
//  AllocedObject.h
//  NativeScript
//
//  Created by Ivan Buhov on 7/9/15.
//
//

#ifndef __NativeScript__AllocedObject__
#define __NativeScript__AllocedObject__

namespace NativeScript {
class AllocedObject : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static AllocedObject* create(JSC::VM& vm, JSC::Structure* structure, Class klass) {
        AllocedObject* object = new (NotNull, JSC::allocateCell<AllocedObject>(vm.heap)) AllocedObject(vm, structure);
        object->finishCreation(vm, klass);
        return object;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    Class klass;

    AllocedObject(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM& vm, Class klass) {
        Base::finishCreation(vm);
        this->klass = klass;
    }
};
}

#endif /* defined(__NativeScript__AllocedObject__) */
