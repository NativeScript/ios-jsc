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
#include <objc/runtime.h>
#include <map>
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

    friend class ObjCClassBuilder;

    static GlobalObject* create(WTF::String applicationPath, JSC::VM& vm, JSC::Structure* structure);

    static const bool needsDestruction = false;

    DECLARE_INFO;

    static const unsigned StructureFlags;

    static const JSC::GlobalObjectMethodTable globalObjectMethodTable;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSValue prototype);

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

    JSC::Structure* unmanagedInstanceStructure() const {
        return this->_unmanagedInstanceStructure.get();
    }

    JSC::JSFunction* typeScriptOriginalExtendsFunction() const {
        return this->_typeScriptOriginalExtendsFunction.get();
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

    void setMicrotaskRunLoopAndMode(CFRunLoopRef runLoop, CFTypeRef mode) {
        this->_microtaskRunLoop = runLoop;
        this->_microtaskRunLoopMode = mode;
    }

    WTF::Deque<std::map<std::string, std::unique_ptr<ReleasePoolBase>>>& releasePools() {
        return this->_releasePools;
    }

private:
    GlobalObject(JSC::VM& vm, JSC::Structure* structure);

    ~GlobalObject();

    void finishCreation(WTF::String applicationPath, JSC::VM& vm);

    static void destroy(JSC::JSCell* cell);

    static void queueTaskToEventLoop(const JSC::JSGlobalObject* globalObject, WTF::PassRefPtr<JSC::Microtask> task);

    std::unique_ptr<GlobalObjectInspectorController> _inspectorController;

    WTF::String _applicationPath;

    WTF::RetainPtr<CFRunLoopRef> _microtaskRunLoop;
    WTF::RetainPtr<CFTypeRef> _microtaskRunLoopMode;

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

    JSC::WriteBarrier<JSC::Structure> _weakRefConstructorStructure;
    JSC::WriteBarrier<JSC::Structure> _weakRefPrototypeStructure;
    JSC::WriteBarrier<JSC::Structure> _weakRefInstanceStructure;

    JSC::WriteBarrier<JSC::Structure> _unmanagedInstanceStructure;

    std::map<Class, JSC::Strong<ObjCConstructorBase>> _objCConstructors;

    std::map<const Protocol*, JSC::Strong<ObjCProtocolWrapper>> _objCProtocolWrappers;

    WTF::Deque<std::map<std::string, std::unique_ptr<ReleasePoolBase>>> _releasePools;
};
}

#endif /* defined(__NativeScript__GlobalObject__) */
