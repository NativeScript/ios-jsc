//
//  FunctionReferenceInstance.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/19/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__FunctionReferenceInstance__
#define __NativeScript__FunctionReferenceInstance__

#include "FFIFunctionCallback.h"

namespace NativeScript {

class FunctionReferenceInstance : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static FunctionReferenceInstance* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, JSC::JSCell* function) {
        FunctionReferenceInstance* cell = new (NotNull, JSC::allocateCell<FunctionReferenceInstance>(vm.heap)) FunctionReferenceInstance(vm, structure);
        cell->finishCreation(vm, globalObject, function);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    JSC::JSCell* function() const {
        return this->_function.get();
    }

    const void* functionPointer() const {
        return this->_functionCallback ? this->_functionCallback->functionPointer() : nullptr;
    }

    void setCallback(JSC::VM&, FFIFunctionCallback*);

    ~FunctionReferenceInstance();

private:
    FunctionReferenceInstance(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<FunctionReferenceInstance*>(cell)->~FunctionReferenceInstance();
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, JSC::JSCell* function);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);

    JSC::WriteBarrier<FFIFunctionCallback> _functionCallback;

    JSC::WriteBarrier<JSC::JSCell> _function;
};
}

#endif /* defined(__NativeScript__FunctionReferenceInstance__) */
