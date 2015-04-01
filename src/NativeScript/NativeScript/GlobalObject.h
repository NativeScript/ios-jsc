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

namespace Inspector {
class JSGlobalObjectInspectorController;
}

namespace NativeScript {
class ObjCConstructorBase;
class ObjCProtocolWrapper;
class RecordConstructor;
class Interop;
class TypeFactory;
class ObjCWrapperObject;

class GlobalObject : public JSC::JSGlobalObject {
public:
    typedef JSC::JSGlobalObject Base;

    friend class ObjCClassBuilder;

    static GlobalObject* create(JSC::VM& vm, JSC::Structure* structure);

    static const bool needsDestruction = false;

    DECLARE_INFO;

    static const unsigned StructureFlags;

    static const JSC::GlobalObjectMethodTable globalObjectMethodTable;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSValue prototype);

    static bool getOwnPropertySlot(JSC::JSObject* object, JSC::ExecState* execState, JSC::PropertyName propertyName, JSC::PropertySlot& propertySlot);

#if DEBUG
    static void getOwnPropertyNames(JSC::JSObject* object, JSC::ExecState* execState, JSC::PropertyNameArray& propertyNames, JSC::EnumerationMode enumerationMode);
#endif

    static void visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor);

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

    JSC::JSFunction* typeScriptOriginalExtendsFunction() const {
        return this->_typeScriptOriginalExtendsFunction.get();
    }

    Inspector::JSGlobalObjectInspectorController& inspectorController() const {
        return *this->_inspectorController.get();
    }

    TypeFactory* typeFactory() const {
        return _typeFactory.get();
    }

#if __LP64__
    JSC::WeakGCMap<const void*, ObjCWrapperObject>& taggedPointers() {
        return this->_taggedPointers;
    };
#endif

private:
    GlobalObject(JSC::VM& vm, JSC::Structure* structure);

    ~GlobalObject();

    void finishCreation(JSC::VM& vm);

    static void destroy(JSC::JSCell* cell);

    static void queueTaskToEventLoop(const JSC::JSGlobalObject* globalObject, WTF::PassRefPtr<JSC::Microtask> task);

    std::unique_ptr<Inspector::JSGlobalObjectInspectorController> _inspectorController;

    JSC::WriteBarrier<JSC::Structure> _objCMethodCallStructure;
    JSC::WriteBarrier<JSC::Structure> _objCConstructorCallStructure;
    JSC::WriteBarrier<JSC::Structure> _objCBlockCallStructure;
    JSC::WriteBarrier<JSC::Structure> _ffiFunctionCallStructure;

    JSC::WriteBarrier<JSC::Structure> _objCBlockCallbackStructure;
    JSC::WriteBarrier<JSC::Structure> _objCMethodCallbackStructure;
    JSC::WriteBarrier<JSC::Structure> _ffiFunctionCallbackStructure;

    JSC::WriteBarrier<JSC::Structure> _recordFieldGetterStructure;
    JSC::WriteBarrier<JSC::Structure> _recordFieldSetterStructure;

    JSC::WriteBarrier<TypeFactory> _typeFactory;

    JSC::Identifier _interopIdentifier;
    JSC::WriteBarrier<Interop> _interop;

    JSC::WriteBarrier<JSC::JSFunction> _typeScriptOriginalExtendsFunction;

    JSC::WriteBarrier<JSC::Structure> _weakRefConstructorStructure;
    JSC::WriteBarrier<JSC::Structure> _weakRefPrototypeStructure;
    JSC::WriteBarrier<JSC::Structure> _weakRefInstanceStructure;

    std::map<Class, JSC::Strong<ObjCConstructorBase>> _objCConstructors;

    std::map<const Protocol*, JSC::Strong<ObjCProtocolWrapper>> _objCProtocolWrappers;

#if __LP64__
    // See comment in toValue
    JSC::WeakGCMap<const void*, ObjCWrapperObject> _taggedPointers;
#endif
};
}

#endif /* defined(__NativeScript__GlobalObject__) */
