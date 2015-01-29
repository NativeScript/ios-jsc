//
//  Pointer.h
//  NativeScript
//
//  Created by Jason Zhekov on 8/19/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__Pointer__
#define __NativeScript__Pointer__

namespace NativeScript {

class PointerPrototype : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static PointerPrototype* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure) {
        PointerPrototype* prototype = new (NotNull, JSC::allocateCell<PointerPrototype>(vm.heap)) PointerPrototype(vm, structure);
        prototype->finishCreation(vm, globalObject);
        return prototype;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

protected:
    void finishCreation(JSC::VM& vm, JSC::JSGlobalObject*);

private:
    PointerPrototype(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }
};

class PointerConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static PointerConstructor* create(JSC::VM& vm, JSC::Structure* structure, PointerPrototype* pointerPrototype) {
        PointerConstructor* constructor = new (NotNull, JSC::allocateCell<PointerConstructor>(vm.heap)) PointerConstructor(vm, structure);
        constructor->finishCreation(vm, pointerPrototype);
        return constructor;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

protected:
    void finishCreation(JSC::VM& vm, PointerPrototype* pointerPrototype);

private:
    PointerConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static JSC::ConstructType getConstructData(JSC::JSCell*, JSC::ConstructData&);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);
};

class PointerInstance : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    DECLARE_INFO;

    static const bool needsDestruction = false;

    static PointerInstance* create(JSC::VM& vm, JSC::Structure* structure, void* value = nullptr) {
        PointerInstance* object = new (NotNull, JSC::allocateCell<PointerInstance>(vm.heap)) PointerInstance(vm, structure);
        object->finishCreation(vm, value);
        vm.heap.addFinalizer(object, destroy);
        return object;
    }

    static JSC::Structure* createStructure(JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(globalObject->vm(), globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    static JSC::JSValue defaultValue(const JSC::JSObject*, JSC::ExecState*, JSC::PreferredPrimitiveType);

    void* data() const {
        return this->_data;
    }

    bool isAdopted() const {
        return this->_isAdopted;
    }

    void setAdopted(bool value) {
        this->_isAdopted = value;
    }

    ~PointerInstance();

protected:
    PointerInstance(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM& vm, void* value);

    void* _data;

    bool _isAdopted = false;

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<PointerInstance*>(cell)->~PointerInstance();
    }
};
}

#endif /* defined(__NativeScript__Pointer__) */
