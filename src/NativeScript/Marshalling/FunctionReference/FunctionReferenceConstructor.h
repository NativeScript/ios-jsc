//
//  FunctionReferenceConstructor.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/20/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__FunctionReferenceConstructor__
#define __NativeScript__FunctionReferenceConstructor__

namespace NativeScript {
class FunctionReferenceConstructor : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    static FunctionReferenceConstructor* create(JSC::VM& vm, JSC::Structure* structure, JSC::JSValue prototype) {
        FunctionReferenceConstructor* cell = new (NotNull, JSC::allocateCell<FunctionReferenceConstructor>(vm.heap)) FunctionReferenceConstructor(vm, structure);
        cell->finishCreation(vm, prototype);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    FunctionReferenceConstructor(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSValue);

    static JSC::ConstructType getConstructData(JSC::JSCell*, JSC::ConstructData&);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);
};
} // namespace NativeScript

#endif /* defined(__NativeScript__FunctionReferenceConstructor__) */
