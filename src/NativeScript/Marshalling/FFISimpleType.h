//
//  FFISimpleType.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/24/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__FFISimpleType__
#define __NativeScript__FFISimpleType__

#include "FFIType.h"

namespace NativeScript {
class FFISimpleType : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static FFISimpleType* create(JSC::VM& vm, JSC::Structure* structure, const WTF::String& name, const FFITypeMethodTable& methodTable) {
        FFISimpleType* cell = new (NotNull, JSC::allocateCell<FFISimpleType>(vm.heap)) FFISimpleType(vm, structure);
        cell->finishCreation(vm, name, methodTable);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    const FFITypeMethodTable& ffiTypeMethodTable() const {
        return this->_ffiTypeMethodTable;
    }

    static WTF::String className(const JSC::JSObject*);

private:
    FFISimpleType(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, const WTF::String& name, const FFITypeMethodTable&);

    static JSC::CallType getCallData(JSC::JSCell* cell, JSC::CallData& callData);

    WTF::String _name;

    FFITypeMethodTable _ffiTypeMethodTable;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__FFISimpleType__) */
