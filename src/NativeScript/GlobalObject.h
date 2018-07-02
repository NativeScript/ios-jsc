//
//  GlobalObject.h
//  NativeScript
//
//  Created by Yavor Georgiev on 14.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__GlobalObject__
#define __NativeScript__GlobalObject__

#include <JavaScriptCore/JSGlobalObject.h>
#include <list>
#include <map>
#include <objc/runtime.h>
#include <wtf/Deque.h>

namespace NativeScript {
class ObjCConstructorBase;
class ObjCProtocolWrapper;
class RecordConstructor;
class Interop;
class TypeFactory;
class ObjCWrapperObject;
class GlobalObjectInspectorController;
class FFICallPrototype;
class ReleasePoolBase;

class GlobalObject : public JSC::JSGlobalObject {
public:
    typedef JSC::JSGlobalObject Base;

    static const unsigned StructureFlags;

    static GlobalObject* create(JSC::VM& vm, JSC::Structure* structure, WTF::String applicationPath) {
        GlobalObject* object = new (NotNull, JSC::allocateCell<GlobalObject>(vm.heap)) GlobalObject(vm, structure);
        object->finishCreation(vm, applicationPath);
        return object;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, 0, prototype, JSC::TypeInfo(JSC::GlobalObjectType, GlobalObject::StructureFlags), GlobalObject::info());
    }

    static const JSC::GlobalObjectMethodTable globalObjectMethodTable;

    static bool getOwnPropertySlot(JSC::JSObject* object, JSC::ExecState* execState, JSC::PropertyName propertyName, JSC::PropertySlot& propertySlot);

#ifdef DEBUG
    static void getOwnPropertyNames(JSC::JSObject* object, JSC::ExecState* execState, JSC::PropertyNameArray& propertyNames, JSC::EnumerationMode enumerationMode);
#endif

    static void visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor);

    FFICallPrototype* ffiCallPrototype() const {
        return this->_ffiCallPrototype.get();
    }

    JSC::Structure* objCMethodCallStructure() const {
        return this->_objCMethodCallStructure.get();
    }

    JSC::Structure* objCConstructorCallStructure() const {
        return this->_objCConstructorCallStructure.get();
    }

    JSC::Structure* objCBlockCallStructure() const {
        return this->_objCBlockCallStructure.get();
    }

    JSC::Structure* ffiFunctionCallStructure() const {
        return this->_ffiFunctionCallStructure.get();
    }

    JSC::Structure* objCBlockCallbackStructure() const {
        return this->_objCBlockCallbackStructure.get();
    }

    JSC::Structure* objCMethodCallbackStructure() const {
        return this->_objCMethodCallbackStructure.get();
    }

    JSC::Structure* ffiFunctionCallbackStructure() const {
        return this->_ffiFunctionCallbackStructure.get();
    }

    JSC::Structure* recordFieldGetterStructure() const {
        return this->_recordFieldGetterStructure.get();
    }

    JSC::Structure* recordFieldSetterStructure() const {
        return this->_recordFieldSetterStructure.get();
    }

    Interop* interop() const {
        return this->_interop.get();
    }

    ObjCConstructorBase* constructorFor(Class klass, Class fallback = Nil);

    ObjCProtocolWrapper* protocolWrapperFor(Protocol* aProtocol);

    JSC::Structure* weakRefConstructorStructure() const {
        return this->_weakRefConstructorStructure.get();
    }

    JSC::Structure* weakRefPrototypeStructure() const {
        return this->_weakRefPrototypeStructure.get();
    }

    JSC::Structure* weakRefInstanceStructure() const {
        return this->_weakRefInstanceStructure.get();
    }

    JSC::Structure* workerConstructorStructure() const {
        return this->_workerConstructorStructure.get();
    }

    JSC::Structure* workerPrototypeStructure() const {
        return this->_workerPrototypeStructure.get();
    }

    JSC::Structure* workerInstanceStructure() const {
        return this->_workerInstanceStructure.get();
    }

    JSC::Structure* unmanagedInstanceStructure() const {
        return this->_unmanagedInstanceStructure.get();
    }

    JSC::JSFunction* typeScriptOriginalExtendsFunction() const {
        return this->_typeScriptOriginalExtendsFunction.get();
    }

    JSC::JSFunction* smartStringifyFunction() const {
        return this->_smartStringifyFunction.get();
    }

    GlobalObjectInspectorController& inspectorController() const {
        return *this->_inspectorController.get();
    }

    TypeFactory* typeFactory() const {
        return _typeFactory.get();
    }

    WTF::String applicationPath() const {
        return _applicationPath;
    }

    JSC::Structure* fastEnumerationIteratorStructure() const {
        return this->_fastEnumerationIteratorStructure.get();
    }

    CFRunLoopSourceRef microtaskRunLoopSource() const {
        return this->_microtaskRunLoopSource.get();
    }

    CFRunLoopObserverRef runLoopBeforeWaitingObserver() const {
        return this->_runLoopBeforeWaitingObserver.get();
    }

    std::list<WTF::RetainPtr<CFRunLoopRef>>& microtaskRunLoops() {
        return this->_microtaskRunLoops;
    }

    void drainMicrotasks();

    WTF::Deque<WTF::RefPtr<JSC::Microtask>>& microtasks() {
        return this->_microtasksQueue;
    }

    WTF::Deque<std::map<std::string, std::unique_ptr<ReleasePoolBase>>>& releasePools() {
        return this->_releasePools;
    }

    const JSC::Identifier& commonJSModuleFunctionIdentifier() const {
        return this->_commonJSModuleFunctionIdentifier;
    }

    WTF::HashMap<WTF::String, WTF::String, WTF::ASCIICaseInsensitiveHash>& modulePathCache() {
        return this->_modulePathCache;
    }

    bool callJsUncaughtErrorCallback(JSC::ExecState* execState, JSC::Exception* exception, WTF::NakedPtr<JSC::Exception>& outException);

    bool isUIApplicationMainAtTopOfCallstack();

protected:
    static JSC::EncodedJSValue JSC_HOST_CALL commonJSRequire(JSC::ExecState*);

    GlobalObject(JSC::VM& vm, JSC::Structure* structure);

    ~GlobalObject();

    void finishCreation(JSC::VM& vm, WTF::String applicationPath);

private:
    friend class ObjCClassBuilder;

    WTF::Deque<WTF::RefPtr<JSC::Microtask>> _microtasksQueue;

    static void destroy(JSC::JSCell* cell) {
        static_cast<GlobalObject*>(cell)->~GlobalObject();
    }

    static void queueTaskToEventLoop(JSC::JSGlobalObject& globalObject, WTF::Ref<JSC::Microtask>&& task);

    static JSC::JSInternalPromise* moduleLoaderImportModule(JSC::JSGlobalObject*, JSC::ExecState*, JSC::JSModuleLoader*, JSC::JSString*, JSC::JSValue, const JSC::SourceOrigin&);

    static JSC::Identifier moduleLoaderResolve(JSC::JSGlobalObject*, JSC::ExecState*, JSC::JSModuleLoader*, JSC::JSValue keyValue, JSC::JSValue referrerValue, JSC::JSValue initiator);

    static JSC::JSInternalPromise* moduleLoaderFetch(JSC::JSGlobalObject*, JSC::ExecState*, JSC::JSModuleLoader*, JSC::JSValue keyValue, JSC::JSValue parameters, JSC::JSValue initiator);

    static JSC::JSObject* moduleLoaderCreateImportMetaProperties(JSGlobalObject*, JSC::ExecState*, JSC::JSModuleLoader*, JSC::JSValue, JSC::JSModuleRecord*, JSC::JSValue);

    static JSC::JSValue moduleLoaderEvaluate(JSC::JSGlobalObject*, JSC::ExecState*, JSC::JSModuleLoader*, JSC::JSValue keyValue, JSC::JSValue moduleRecordValue, JSC::JSValue initiator);

    static WTF::String defaultLanguage();

    JSC::Identifier _jsUncaughtErrorCallbackIdentifier;
    JSC::Identifier _jsUncaughtErrorCallbackIdentifierFallback;

    std::unique_ptr<GlobalObjectInspectorController> _inspectorController;

    WTF::String _applicationPath;

    std::list<WTF::RetainPtr<CFRunLoopRef>> _microtaskRunLoops;
    WTF::RetainPtr<CFRunLoopSourceRef> _microtaskRunLoopSource;
    WTF::RetainPtr<CFRunLoopObserverRef> _runLoopBeforeWaitingObserver;

    JSC::WriteBarrier<FFICallPrototype> _ffiCallPrototype;
    JSC::WriteBarrier<JSC::Structure> _objCMethodCallStructure;
    JSC::WriteBarrier<JSC::Structure> _objCConstructorCallStructure;
    JSC::WriteBarrier<JSC::Structure> _objCBlockCallStructure;
    JSC::WriteBarrier<JSC::Structure> _ffiFunctionCallStructure;

    JSC::WriteBarrier<JSC::Structure> _objCBlockCallbackStructure;
    JSC::WriteBarrier<JSC::Structure> _objCMethodCallbackStructure;
    JSC::WriteBarrier<JSC::Structure> _ffiFunctionCallbackStructure;

    JSC::WriteBarrier<JSC::Structure> _recordFieldGetterStructure;
    JSC::WriteBarrier<JSC::Structure> _recordFieldSetterStructure;

    JSC::WriteBarrier<JSC::Structure> _fastEnumerationIteratorStructure;

    JSC::WriteBarrier<TypeFactory> _typeFactory;

    JSC::Identifier _interopIdentifier;
    JSC::WriteBarrier<Interop> _interop;

    JSC::WriteBarrier<JSC::JSFunction> _typeScriptOriginalExtendsFunction;
    JSC::WriteBarrier<JSC::JSFunction> _smartStringifyFunction;

    JSC::WriteBarrier<JSC::Structure> _weakRefConstructorStructure;
    JSC::WriteBarrier<JSC::Structure> _weakRefPrototypeStructure;
    JSC::WriteBarrier<JSC::Structure> _weakRefInstanceStructure;

    JSC::WriteBarrier<JSC::Structure> _workerConstructorStructure;
    JSC::WriteBarrier<JSC::Structure> _workerPrototypeStructure;
    JSC::WriteBarrier<JSC::Structure> _workerInstanceStructure;

    JSC::WriteBarrier<JSC::Structure> _unmanagedInstanceStructure;

    std::map<Class, JSC::Strong<ObjCConstructorBase>> _objCConstructors;

    std::map<const Protocol*, JSC::Strong<ObjCProtocolWrapper>> _objCProtocolWrappers;

    WTF::Deque<std::map<std::string, std::unique_ptr<ReleasePoolBase>>> _releasePools;

    JSC::Identifier _commonJSModuleFunctionIdentifier;

    WTF::HashMap<WTF::String, WTF::String, WTF::ASCIICaseInsensitiveHash> _modulePathCache;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__GlobalObject__) */
