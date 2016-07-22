//
//  JSWorkerPrototype.h
//  NativeScript
//
//  Created by Ivan Buhov on 7/5/16.
//
//

#ifndef __NativeScript__JSWorkerPrototype__
#define __NativeScript__JSWorkerPrototype__

namespace NativeScript {
class JSWorkerPrototype : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static JSWorkerPrototype* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure) {
        JSWorkerPrototype* prototype = new (NotNull, JSC::allocateCell<JSWorkerPrototype>(vm.heap)) JSWorkerPrototype(vm, structure);
        prototype->finishCreation(vm, globalObject);
        return prototype;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    JSWorkerPrototype(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM& vm, JSC::JSGlobalObject*);
};
}
#endif /* defined(__NativeScript__JSWorkerPrototype__) */
