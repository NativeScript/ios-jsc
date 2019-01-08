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

    static JSC::Strong<JSWorkerConstructor> create(JSC::VM& vm, JSC::Structure* structure, JSWorkerPrototype* prototype) {
        JSC::Strong<JSWorkerConstructor> object(vm, new (NotNull, JSC::allocateCell<JSWorkerConstructor>(vm.heap)) JSWorkerConstructor(vm, structure));
        object->finishCreation(vm, prototype);
        return object;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

private:
    JSWorkerConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure, callJSWorker, constructJSWorker) {
    }

    void finishCreation(JSC::VM& vm, JSWorkerPrototype* prototype);

    static JSC::EncodedJSValue JSC_HOST_CALL callJSWorker(JSC::ExecState* exec);
    static JSC::EncodedJSValue JSC_HOST_CALL constructJSWorker(JSC::ExecState* exec);
};
} // namespace NativeScript

#endif /* defined(__NativeScript__JSWorkerConstructor__) */
