//
//  ObjCBlockTypeConstructor.h
//  NativeScript
//
//  Created by Ivan Buhov on 11/3/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCBlockTypeConstructor__
#define __NativeScript__ObjCBlockTypeConstructor__

namespace NativeScript {

class ObjCBlockTypeConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static ObjCBlockTypeConstructor* create(JSC::VM& vm, JSC::Structure* structure, JSObject* objCBlockTypePrototype) {
        ObjCBlockTypeConstructor* constructor = new (NotNull, JSC::allocateCell<ObjCBlockTypeConstructor>(vm.heap)) ObjCBlockTypeConstructor(vm, structure);
        constructor->finishCreation(vm, objCBlockTypePrototype);
        return constructor;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    ObjCBlockTypeConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure, &constructObjCBlockTypeConstructor, &constructObjCBlockTypeConstructor) {
    }

    void finishCreation(JSC::VM&, JSObject*);

    static JSC::EncodedJSValue JSC_HOST_CALL constructObjCBlockTypeConstructor(JSC::ExecState* execState);
};
} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCBlockTypeConstructor__) */
