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
class WorkerMessagingProxy;

class JSWorkerInstance : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    DECLARE_INFO;

    static JSC::Strong<JSWorkerInstance> create(JSC::VM& vm, JSC::Structure* structure, const WTF::String& applicationPath, const WTF::String& entryModuleId, const WTF::String referrer) {
        JSC::Strong<JSWorkerInstance> object(vm, new (NotNull, JSC::allocateCell<JSWorkerInstance>(vm.heap)) JSWorkerInstance(vm, structure));
        object->finishCreation(vm, applicationPath, entryModuleId, referrer);
        return object;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    void postMessage(JSC::ExecState* exec, JSC::JSValue message, JSC::JSArray* transferList);

    void onmessage(JSC::ExecState* exec, JSC::JSValue message);

    void onerror(JSC::ExecState* exec, JSObject* error);

    void terminate();

    std::shared_ptr<WorkerMessagingProxy> workerMessagingProxy() {
        return _workerMessagingProxy;
    }

private:
    JSWorkerInstance(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM& vm, const WTF::String& applicationPath, const WTF::String& entryModuleId, const WTF::String referer);

    WTF::String _applicationPath;
    WTF::String _entryModuleId;
    WTF::String _referrer;
    std::shared_ptr<WorkerMessagingProxy> _workerMessagingProxy;

    JSC::Identifier _onmessageIdentifier;
    JSC::Identifier _onerrorIdentifier;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__JSWorkerInstance__) */
