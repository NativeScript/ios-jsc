//
//  NativeErrorWrapperConstructor.h
//  NativeScript
//
//  Created by Yavor Georgiev on 30.12.15 г..
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#pragma once

@class NSError;

namespace NativeScript {
class NativeErrorWrapperConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static NativeErrorWrapperConstructor* create(JSC::VM& vm, JSC::Structure* structure) {
        NativeErrorWrapperConstructor* cell = new (NotNull, JSC::allocateCell<NativeErrorWrapperConstructor>(vm.heap)) NativeErrorWrapperConstructor(vm, structure);
        cell->finishCreation(vm, structure->globalObject());
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    JSC::Structure* errorStructure() const {
        return this->_errorStructure.get();
    }

    JSC::ErrorInstance* createError(JSC::ExecState*, NSError*) const;

    JSC::ErrorInstance* createError(JSC::ExecState*, NSException*) const;

private:
    NativeErrorWrapperConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell);

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static JSC::ConstructType getConstructData(JSC::JSCell*, JSC::ConstructData&);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);

    JSC::WriteBarrier<JSC::Structure> _errorStructure;
};
}