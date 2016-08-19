//
//  Interop.h
//  NativeScript
//
//  Created by Jason Zhekov on 8/20/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__Interop__
#define __NativeScript__Interop__

#include "Metadata.h"
#include <string>

namespace NativeScript {
class PointerInstance;
class ReferenceInstance;
class NSErrorWrapperConstructor;

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

#ifdef __OBJC__
    JSC::JSArrayBuffer* bufferFromData(JSC::ExecState*, NSData*) const;
#endif

    static JSC::WeakGCMap<id, JSC::JSObject>& objectMap(JSC::VM* vm) {
        WTF::LockHolder lockHolder(_objectMapLock);
        for (auto it = _objectMaps.begin(); it != _objectMaps.end(); it++) {
            if (it->first == vm) {
                return *it->second.get();
            }
        }
        _objectMaps.append(std::make_pair(vm, std::make_unique<JSC::WeakGCMap<id, JSC::JSObject>>(*vm)));
        return *_objectMaps.last().second.get();
    }

#ifdef __OBJC__
    JSC::ErrorInstance* wrapError(JSC::ExecState*, NSError*) const;
#endif

private:
    Interop(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure)
        , _pointerToInstance(vm) {
    }

    void finishCreation(JSC::VM&, GlobalObject*);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static WTF::Lock _objectMapLock;

    static WTF::Vector<std::pair<JSC::VM*, std::unique_ptr<JSC::WeakGCMap<id, JSC::JSObject>>>> _objectMaps;

    JSC::WriteBarrier<JSC::Structure> _pointerInstanceStructure;

    JSC::WriteBarrier<JSC::Structure> _referenceInstanceStructure;

    JSC::WriteBarrier<JSC::Structure> _functionReferenceInstanceStructure;

    JSC::WriteBarrier<NSErrorWrapperConstructor> _nsErrorWrapperConstructor;

    JSC::WeakGCMap<const void*, PointerInstance> _pointerToInstance;
};

static inline Interop* interop(JSC::ExecState* execState) {
    return JSC::jsCast<GlobalObject*>(execState->lexicalGlobalObject())->interop();
}
}

#endif /* defined(__NativeScript__Interop__) */
