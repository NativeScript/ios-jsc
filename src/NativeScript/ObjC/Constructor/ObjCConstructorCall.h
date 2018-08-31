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

namespace Metadata {
struct MethodMeta;
}

namespace NativeScript {
class ObjCConstructorCall : public FFICall {
public:
    typedef FFICall Base;

    static ObjCConstructorCall* create(JSC::VM& vm, GlobalObject* globalObject, JSC::Structure* structure, Class klass, const Metadata::MethodMeta* metadata) {
        ObjCConstructorCall* constructor = new (NotNull, JSC::allocateCell<ObjCConstructorCall>(vm.heap)) ObjCConstructorCall(vm, structure);
        constructor->finishCreation(vm, globalObject, klass, metadata);
        return constructor;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    SEL selector() {
        return this->_selector;
    }

    Class klass() const {
        return this->_klass;
    }

    bool canInvoke(JSC::ExecState* execState) const;

private:
    ObjCConstructorCall(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, GlobalObject*, Class, const Metadata::MethodMeta*);

    static void preInvocation(FFICall*, JSC::ExecState*, FFICall::Invocation&);
    static void postInvocation(FFICall*, JSC::ExecState*, FFICall::Invocation&);

    static void destroy(JSC::JSCell* cell) {
        static_cast<ObjCConstructorCall*>(cell)->~ObjCConstructorCall();
    }

    SEL _selector;
    Class _klass;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCConstructorCall__) */
