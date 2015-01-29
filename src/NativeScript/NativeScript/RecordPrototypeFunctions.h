//
//  RecordPrototypeFunctions.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/13/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__RecordPrototypeFunctions__
#define __NativeScript__RecordPrototypeFunctions__

namespace NativeScript {
class RecordField;

class RecordProtoFieldGetter : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static RecordProtoFieldGetter* create(JSC::VM& vm, JSC::Structure* structure, RecordField* recordField) {
        RecordProtoFieldGetter* cell = new (NotNull, JSC::allocateCell<RecordProtoFieldGetter>(vm.heap)) RecordProtoFieldGetter(vm, structure);
        cell->finishCreation(vm, recordField);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    RecordField* recordField() const {
        return _recordField.get();
    }

private:
    RecordProtoFieldGetter(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<RecordProtoFieldGetter*>(cell)->~RecordProtoFieldGetter();
    }

    void finishCreation(JSC::VM&, RecordField*);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);

    JSC::WriteBarrier<RecordField> _recordField;
};

class RecordProtoFieldSetter : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static RecordProtoFieldSetter* create(JSC::VM& vm, JSC::Structure* structure, RecordField* recordField) {
        RecordProtoFieldSetter* cell = new (NotNull, JSC::allocateCell<RecordProtoFieldSetter>(vm.heap)) RecordProtoFieldSetter(vm, structure);
        cell->finishCreation(vm, recordField);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    RecordField* recordField() const {
        return _recordField.get();
    }

private:
    RecordProtoFieldSetter(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<RecordProtoFieldSetter*>(cell)->~RecordProtoFieldSetter();
    }

    void finishCreation(JSC::VM&, RecordField*);

    static void visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);

    JSC::WriteBarrier<RecordField> _recordField;
};
}

#endif /* defined(__NativeScript__RecordPrototypeFunctions__) */
