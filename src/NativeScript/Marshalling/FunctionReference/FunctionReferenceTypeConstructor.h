//
//  FunctionReferenceTypeConstructor.h
//  NativeScript
//
//  Created by Ivan Buhov on 11/3/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__FunctionReferenceTypeConstructor__
#define __NativeScript__FunctionReferenceTypeConstructor__

namespace NativeScript {

class FunctionReferenceTypeConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static FunctionReferenceTypeConstructor* create(JSC::VM& vm, JSC::Structure* structure, JSObject* functionReferenceTypePrototype) {
        FunctionReferenceTypeConstructor* constructor = new (NotNull, JSC::allocateCell<FunctionReferenceTypeConstructor>(vm.heap)) FunctionReferenceTypeConstructor(vm, structure);
        constructor->finishCreation(vm, functionReferenceTypePrototype);
        return constructor;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    FunctionReferenceTypeConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSObject*);

    static JSC::ConstructType getConstructData(JSC::JSCell*, JSC::ConstructData&);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);
};
} // namespace NativeScript

#endif /* defined(__NativeScript__FunctionReferenceTypeConstructor__) */
