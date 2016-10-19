//
//  JSWorkerConstructor.h
//  NativeScript
//
//  Created by Ivan Buhov on 7/5/16.
//
//

#ifndef __NativeScript__JSWorkerConstructor__
#define __NativeScript__JSWorkerConstructor__

#include <JavaScriptCore/InternalFunction.h>

namespace NativeScript {
class JSWorkerPrototype;

class JSWorkerConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    DECLARE_INFO;

    static JSWorkerConstructor* create(JSC::VM& vm, JSC::Structure* structure, JSWorkerPrototype* prototype) {
        JSWorkerConstructor* object = new (NotNull, JSC::allocateCell<JSWorkerConstructor>(vm.heap)) JSWorkerConstructor(vm, structure);
        object->finishCreation(vm, prototype);
        return object;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    JSWorkerConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static JSC::ConstructType getConstructData(JSC::JSCell* cell, JSC::ConstructData& constructData);
    static JSC::CallType getCallData(JSC::JSCell* cell, JSC::CallData& callData);

    void finishCreation(JSC::VM& vm, JSWorkerPrototype* prototype);
};
}

#endif /* defined(__NativeScript__JSWorkerConstructor__) */