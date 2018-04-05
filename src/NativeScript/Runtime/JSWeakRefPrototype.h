//
//  JSWeakRefPrototype.h
//  NativeScript
//
//  Created by Yavor Georgiev on 02.10.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__JSWeakRefPrototype__
#define __NativeScript__JSWeakRefPrototype__

namespace NativeScript {
class JSWeakRefPrototype : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static JSWeakRefPrototype* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure) {
        JSWeakRefPrototype* prototype = new (NotNull, JSC::allocateCell<JSWeakRefPrototype>(vm.heap)) JSWeakRefPrototype(vm, structure);
        prototype->finishCreation(vm, globalObject);
        return prototype;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    JSWeakRefPrototype(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM& vm, JSC::JSGlobalObject*);
};
} // namespace NativeScript
#endif /* defined(__NativeScript__JSWeakRefPrototype__) */
