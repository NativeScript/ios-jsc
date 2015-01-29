//
//  ReferenceConstructor.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/17/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ReferenceConstructor__
#define __NativeScript__ReferenceConstructor__

namespace NativeScript {
class ReferencePrototype;

class ReferenceConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static ReferenceConstructor* create(JSC::VM& vm, JSC::Structure* structure, ReferencePrototype* referencePrototype) {
        ReferenceConstructor* constructor = new (NotNull, JSC::allocateCell<ReferenceConstructor>(vm.heap)) ReferenceConstructor(vm, structure);
        constructor->finishCreation(vm, referencePrototype);
        return constructor;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    ReferenceConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, ReferencePrototype*);

    static JSC::ConstructType getConstructData(JSC::JSCell*, JSC::ConstructData&);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);
};
}

#endif /* defined(__NativeScript__ReferenceConstructor__) */
