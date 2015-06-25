//
//  RecordConstructor.h
//  NativeScript
//
//  Created by Jason Zhekov on 9/27/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__RecordConstructor__
#define __NativeScript__RecordConstructor__

#include "FFIType.h"
#include <string>

namespace NativeScript {
class RecordPrototype;
class RecordField;

class RecordConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static RecordConstructor* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, RecordPrototype* recordPrototype, const WTF::String& name, ffi_type* ffiType, RecordType recordType) {
        RecordConstructor* cell = new (NotNull, JSC::allocateCell<RecordConstructor>(vm.heap)) RecordConstructor(vm, structure);
        cell->finishCreation(vm, globalObject, recordPrototype, name, ffiType, recordType);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    JSC::Structure* instancesStructure() const {
        return _instancesStructure.get();
    }

    RecordType recordType() const {
        return this->_recordType;
    }

    const FFITypeMethodTable& ffiTypeMethodTable() {
        return this->_ffiTypeMethodTable;
    }

private:
    RecordConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~RecordConstructor();

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<RecordConstructor*>(cell)->~RecordConstructor();
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, RecordPrototype*, const WTF::String& name, ffi_type*, RecordType);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static JSC::EncodedJSValue JSC_HOST_CALL constructRecordInstance(JSC::ExecState*);
    static JSC::ConstructType getConstructData(JSC::JSCell*, JSC::ConstructData&);

    static JSC::EncodedJSValue JSC_HOST_CALL createRecordInstance(JSC::ExecState*);
    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);

    static JSC::JSValue read(JSC::ExecState*, void const*, JSC::JSCell*);

    static void write(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell*);

    static bool canConvert(JSC::ExecState*, const JSC::JSValue&, JSC::JSCell*);

    static const char* encode(JSC::JSCell*);

    JSC::WriteBarrier<JSC::Structure> _instancesStructure;

    RecordType _recordType;

    FFITypeMethodTable _ffiTypeMethodTable;

    std::string _compilerEncoding;
};
}

#endif /* defined(__NativeScript__RecordConstructor__) */
