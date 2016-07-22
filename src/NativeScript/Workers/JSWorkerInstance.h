//
//  JSWorkerInstance.h
//  NativeScript
//
//  Created by Ivan Buhov on 7/5/16.
//
//

#ifndef __NativeScript__JSWorkerInstance__
#define __NativeScript__JSWorkerInstance__

namespace NativeScript {
class JSWorkerInstance : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    DECLARE_INFO;

    static JSWorkerInstance* create(JSC::VM& vm, JSC::Structure* structure, const WTF::String& moduleName) {
        // We don't currently support nested workers, so workers can only be created from the main thread.
        ASSERT(isMainThread());

        JSWorkerInstance* object = new (NotNull, JSC::allocateCell<JSWorkerInstance>(vm.heap)) JSWorkerInstance(vm, structure);
        object->finishCreation(vm, moduleName);
        return object;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    /* TODO: Implement postMessage communication
    void postMessage(PassRefPtr<SerializedScriptValue> message, const MessagePortArray*, ExceptionCode&);
    
    void postMessage(PassRefPtr<SerializedScriptValue> message, MessagePort*, ExceptionCode&);
     */

    void terminate() {
        //contextProxy->terminateWorkerGlobalScope();
    }

private:
    WTF::String moduleName;

    JSWorkerInstance(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~JSWorkerInstance() {
    }

    void finishCreation(JSC::VM& vm, const WTF::String& moduleName);

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<JSWorkerInstance*>(cell)->~JSWorkerInstance();
    }
};
}

#endif /* defined(__NativeScript__JSWorkerInstance__) */