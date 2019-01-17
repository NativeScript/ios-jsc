//
//  RecordPrototypeFunctions.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/13/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__RecordPrototypeFunctions__
#define __NativeScript__RecordPrototypeFunctions__

#include "JavaScriptCore/IsoSubspace.h"

namespace NativeScript {
class RecordField;

class RecordProtoFieldGetter : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static JSC::Strong<RecordProtoFieldGetter> create(JSC::VM& vm, JSC::Structure* structure, RecordField* recordField) {
        JSC::Strong<RecordProtoFieldGetter> cell(vm, new (NotNull, JSC::allocateCell<RecordProtoFieldGetter>(vm.heap)) RecordProtoFieldGetter(vm, structure));
        cell->finishCreation(vm, recordField);
        return cell;
    }

    DECLARE_INFO;

    template <typename CellType>
    static JSC::IsoSubspace* subspaceFor(JSC::VM& vm) {
        return &vm.tnsRecordProtoFieldGetterSpace;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

    RecordField* recordField() const {
        return _recordField.get();
    }

private:
    RecordProtoFieldGetter(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure, recordProtoFuncFieldGetter, nullptr) {
    }

    static void destroy(JSC::JSCell* cell) {
        static_cast<RecordProtoFieldGetter*>(cell)->~RecordProtoFieldGetter();
    }

    void finishCreation(JSC::VM&, RecordField*);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    JSC::WriteBarrier<RecordField> _recordField;

    static JSC::EncodedJSValue JSC_HOST_CALL recordProtoFuncFieldGetter(JSC::ExecState* execState);
};

class RecordProtoFieldSetter : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static JSC::Strong<RecordProtoFieldSetter> create(JSC::VM& vm, JSC::Structure* structure, RecordField* recordField) {
        JSC::Strong<RecordProtoFieldSetter> cell(vm, new (NotNull, JSC::allocateCell<RecordProtoFieldSetter>(vm.heap)) RecordProtoFieldSetter(vm, structure));
        cell->finishCreation(vm, recordField);
        return cell;
    }

    DECLARE_INFO;

    template <typename CellType>
    static JSC::IsoSubspace* subspaceFor(JSC::VM& vm) {
        return &vm.tnsRecordProtoFieldSetterSpace;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

    RecordField* recordField() const {
        return _recordField.get();
    }

private:
    RecordProtoFieldSetter(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure, recordProtoFuncFieldSetter, nullptr) {
    }

    static void destroy(JSC::JSCell* cell) {
        static_cast<RecordProtoFieldSetter*>(cell)->~RecordProtoFieldSetter();
    }

    void finishCreation(JSC::VM&, RecordField*);

    static void visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor);

    JSC::WriteBarrier<RecordField> _recordField;

    static JSC::EncodedJSValue JSC_HOST_CALL recordProtoFuncFieldSetter(JSC::ExecState* execState);
};
} // namespace NativeScript

#endif /* defined(__NativeScript__RecordPrototypeFunctions__) */
