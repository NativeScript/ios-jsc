//
//  PointerConstructor.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/17/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__PointerConstructor__
#define __NativeScript__PointerConstructor__

#include "FFIType.h"

namespace NativeScript {
class PointerPrototype;

class PointerConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static JSC::EncodedJSValue JSC_HOST_CALL constructPointerInstance(JSC::ExecState* execState);

    static PointerConstructor* create(JSC::VM& vm, JSC::Structure* structure, PointerPrototype* pointerPrototype) {
        PointerConstructor* constructor = new (NotNull, JSC::allocateCell<PointerConstructor>(vm.heap)) PointerConstructor(vm, structure);
        constructor->finishCreation(vm, pointerPrototype);
        return constructor;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    const FFITypeMethodTable& ffiTypeMethodTable() const {
        return this->_ffiTypeMethodTable;
    }

private:
    PointerConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure, &constructPointerInstance, &constructPointerInstance) {
    }

    void finishCreation(JSC::VM&, PointerPrototype*);

    static JSC::JSValue read(JSC::ExecState*, void const*, JSC::JSCell*);

    static void write(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell*);

    static void postCall(JSC::ExecState*, const JSC::JSValue&, void*, JSC::JSCell*);

    static bool canConvert(JSC::ExecState*, const JSC::JSValue&, JSC::JSCell*);

    static const char* encode(JSC::VM&, JSC::JSCell*);

    FFITypeMethodTable _ffiTypeMethodTable;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__PointerConstructor__) */
