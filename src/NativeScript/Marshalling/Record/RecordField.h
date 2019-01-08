//
//  RecordField.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/13/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__RecordField__
#define __NativeScript__RecordField__

#include "FFIType.h"

namespace NativeScript {

class RecordField : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static JSC::Strong<RecordField> create(JSC::VM& vm, JSC::Structure* structure, const WTF::String& fieldName, JSCell* fieldType, ptrdiff_t offset) {
        JSC::Strong<RecordField> cell(vm, new (NotNull, JSC::allocateCell<RecordField>(vm.heap)) RecordField(vm, structure));
        cell->finishCreation(vm, fieldName, fieldType, offset);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    const WTF::String& fieldName() const {
        return this->_fieldName;
    }

    JSC::JSCell* fieldType() const {
        return this->_fieldType.get();
    }

    ptrdiff_t offset() const {
        return this->_offset;
    }

    const FFITypeMethodTable& ffiTypeMethodTable() const {
        return this->_ffiTypeMethodTable;
    }

private:
    RecordField(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        static_cast<RecordField*>(cell)->~RecordField();
    }

    void finishCreation(JSC::VM&, const WTF::String& fieldName, JSCell* fieldType, ptrdiff_t offset);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    WTF::String _fieldName;

    JSC::WriteBarrier<JSC::JSCell> _fieldType;

    FFITypeMethodTable _ffiTypeMethodTable;

    ptrdiff_t _offset;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__RecordField__) */
