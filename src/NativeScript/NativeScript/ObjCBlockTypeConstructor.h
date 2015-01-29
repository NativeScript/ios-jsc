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
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSObject*);

    static JSC::ConstructType getConstructData(JSC::JSCell*, JSC::ConstructData&);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);
};
}

#endif /* defined(__NativeScript__ObjCBlockTypeConstructor__) */
