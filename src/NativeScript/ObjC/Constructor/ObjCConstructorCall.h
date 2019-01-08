//
//  ObjCConstructorCall.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/6/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCConstructorCall__
#define __NativeScript__ObjCConstructorCall__

#include "FFICall.h"
#include "FunctionWrapper.h"
#include "JavaScriptCore/IsoSubspace.h"

namespace Metadata {
struct MethodMeta;
}

namespace NativeScript {
class ObjCConstructorWrapper : public FunctionWrapper {
public:
    typedef FunctionWrapper Base;

    static JSC::Strong<ObjCConstructorWrapper> create(JSC::VM& vm, GlobalObject* globalObject, JSC::Structure* structure, Class klass, const Metadata::MethodMeta* metadata) {
        JSC::Strong<ObjCConstructorWrapper> constructor(vm, new (NotNull, JSC::allocateCell<ObjCConstructorWrapper>(vm.heap)) ObjCConstructorWrapper(vm, structure));
        constructor->finishCreation(vm, globalObject, klass, metadata);
        return constructor;
    }

    DECLARE_INFO;

    template <typename CellType>
    static JSC::IsoSubspace* subspaceFor(JSC::VM& vm) {
        return &vm.tnsObjCConstructorWrapperSpace;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

    bool canInvoke(JSC::ExecState* execState) const;

private:
    ObjCConstructorWrapper(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, GlobalObject*, Class, const Metadata::MethodMeta*);

    static void preInvocation(FFICall*, JSC::ExecState*, FFICall::Invocation&);
    static void postInvocation(FFICall*, JSC::ExecState*, FFICall::Invocation&);

    static void destroy(JSC::JSCell* cell) {
        static_cast<ObjCConstructorWrapper*>(cell)->~ObjCConstructorWrapper();
    }
};

class ObjCConstructorCall : public FFICall {

public:
    ObjCConstructorCall(FunctionWrapper* owner)
        : FFICall(owner) {
    }

    SEL selector() {
        return this->_selector;
    }

    Class klass() const {
        return this->_klass;
    }

    bool canInvoke(JSC::ExecState* execState) const;

    SEL _selector;
    Class _klass;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCConstructorCall__) */
