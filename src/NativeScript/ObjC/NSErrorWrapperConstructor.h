//
//  NSErrorWrapperConstructor.h
//  NativeScript
//
//  Created by Yavor Georgiev on 30.12.15 г..
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#pragma once

#include "JavaScriptCore/IsoSubspace.h"

@class NSError;

namespace NativeScript {
class NSErrorWrapperConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static JSC::Strong<NSErrorWrapperConstructor> create(JSC::VM& vm, JSC::Structure* structure) {
        JSC::Strong<NSErrorWrapperConstructor> cell(vm, new (NotNull, JSC::allocateCell<NSErrorWrapperConstructor>(vm.heap)) NSErrorWrapperConstructor(vm, structure));
        cell->finishCreation(vm, structure->globalObject());
        return cell;
    }

    DECLARE_INFO;

    template <typename CellType>
    static JSC::IsoSubspace* subspaceFor(JSC::VM& vm) {
        return &vm.tnsNSErrorWrapperConstructorSpace;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

    JSC::Structure* errorStructure() const {
        return this->_errorStructure.get();
    }

    JSC::ErrorInstance* createError(JSC::ExecState*, NSError*) const;

private:
    NSErrorWrapperConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure, &constructErrorWrapper, &constructErrorWrapper) {
    }

    static void destroy(JSC::JSCell* cell);

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    JSC::WriteBarrier<JSC::Structure> _errorStructure;

    static JSC::EncodedJSValue JSC_HOST_CALL constructErrorWrapper(JSC::ExecState* execState);
};
} // namespace NativeScript
