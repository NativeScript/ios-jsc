//
//  Interop.h
//  NativeScript
//
//  Created by Jason Zhekov on 8/20/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__Interop__
#define __NativeScript__Interop__

#include <string>
#include "Metadata.h"

namespace NativeScript {
class PointerInstance;
class ReferenceInstance;

void* tryHandleofValue(const JSC::JSValue&, bool*);

size_t sizeofValue(const JSC::JSValue&);

const char* getCompilerEncoding(JSC::JSCell*);

std::string getCompilerEncoding(JSC::JSGlobalObject*, const Metadata::MethodMeta*);

class Interop : public JSC::JSObject {
public:
    typedef JSC::JSObject Base;

    static Interop* create(JSC::VM& vm, GlobalObject* globalObject, JSC::Structure* structure) {
        Interop* object = new (NotNull, JSC::allocateCell<Interop>(vm.heap)) Interop(vm, structure);
        object->finishCreation(vm, globalObject);
        return object;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    JSC::JSValue pointerInstanceForPointer(JSC::VM&, void*);

    JSC::Structure* referenceInstanceStructure() const {
        return this->_referenceInstanceStructure.get();
    }

    JSC::Structure* functionReferenceInstanceStructure() const {
        return this->_functionReferenceInstanceStructure.get();
    }

    JSC::WeakGCMap<id, JSC::JSObject>& objectMap() {
        return this->_objectMap;
    }

private:
    Interop(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure)
        , _pointerToInstance(vm)
        , _objectMap(vm) {
    }

    void finishCreation(JSC::VM&, GlobalObject*);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    JSC::WriteBarrier<JSC::Structure> _pointerInstanceStructure;

    JSC::WriteBarrier<JSC::Structure> _referenceInstanceStructure;

    JSC::WriteBarrier<JSC::Structure> _functionReferenceInstanceStructure;

    JSC::WeakGCMap<const void*, PointerInstance> _pointerToInstance;

    JSC::WeakGCMap<id, JSC::JSObject> _objectMap;
};

static inline Interop* interop(JSC::ExecState* execState) {
    return JSC::jsCast<GlobalObject*>(execState->lexicalGlobalObject())->interop();
}
}

#endif /* defined(__NativeScript__Interop__) */
