//
//  ReferenceTypeConstructor.h
//  NativeScript
//
//  Created by Ivan Buhov on 11/3/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ReferenceTypeConstructor__
#define __NativeScript__ReferenceTypeConstructor__

namespace NativeScript {

class ReferenceTypeConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static ReferenceTypeConstructor* create(JSC::VM& vm, JSC::Structure* structure, JSObject* referenceTypePrototype) {
        ReferenceTypeConstructor* constructor = new (NotNull, JSC::allocateCell<ReferenceTypeConstructor>(vm.heap)) ReferenceTypeConstructor(vm, structure);
        constructor->finishCreation(vm, referenceTypePrototype);
        return constructor;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    ReferenceTypeConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSObject*);

    static JSC::ConstructType getConstructData(JSC::JSCell*, JSC::ConstructData&);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);
};
} // namespace NativeScript

#endif /* defined(__NativeScript__ReferenceTypeConstructor__) */
