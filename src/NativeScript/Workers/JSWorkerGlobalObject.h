#ifndef JSWorkerGlobalObject_h
#define JSWorkerGlobalObject_h

#include "GlobalObject.h"

namespace NativeScript {
class WorkerMessagingProxy;

class JSWorkerGlobalObject : public GlobalObject {
public:
    typedef GlobalObject Base;

    static JSC::Strong<JSWorkerGlobalObject> create(JSC::VM& vm, JSC::Structure* structure, WTF::String applicationPath) {
        JSC::Strong<JSWorkerGlobalObject> object(vm, new (NotNull, JSC::allocateCell<JSWorkerGlobalObject>(vm.heap)) JSWorkerGlobalObject(vm, structure));
        object->finishCreation(vm, applicationPath);
        return object;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, 0, prototype, JSC::TypeInfo(JSC::GlobalObjectType, JSWorkerGlobalObject::StructureFlags), JSWorkerGlobalObject::info());
    }

    void postMessage(JSC::ExecState* exec, JSC::JSValue message, JSC::JSArray* transferList);

    void onmessage(JSC::ExecState* exec, JSC::JSValue message);

    void close();

    void uncaughtErrorReported(const WTF::String& message = "", const WTF::String& filename = "", int lineNumber = 0, int colNumber = 0);

    WorkerMessagingProxy* workerMessagingProxy();

    void setWorkerMessagingProxy(std::shared_ptr<WorkerMessagingProxy> workerMessagingProxy) {
        _workerMessagingProxy = workerMessagingProxy;
    }

protected:
    JSWorkerGlobalObject(JSC::VM& vm, JSC::Structure* structure)
        : GlobalObject(vm, structure) {
    }

    ~JSWorkerGlobalObject() = default;

    void finishCreation(JSC::VM&, WTF::String applicationPath);

private:
    static void destroy(JSC::JSCell* cell) {
        static_cast<JSWorkerGlobalObject*>(cell)->~JSWorkerGlobalObject();
    }

    JSC::Identifier _onmessageIdentifier;

    std::shared_ptr<WorkerMessagingProxy> _workerMessagingProxy = nullptr;
};
} // namespace NativeScript

#endif
