//
//  FFICallPrototype.h
//  NativeScript
//
//  Created by Yavor Georgiev on 25.09.15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#ifndef __NativeScript__FFICallPrototype__
#define __NativeScript__FFICallPrototype__

#include <JavaScriptCore/JSObject.h>

namespace NativeScript {
class FFICallPrototype : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static const unsigned StructureFlags = Base::StructureFlags;

    static FFICallPrototype* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure) {
        FFICallPrototype* prototype = new (NotNull, JSC::allocateCell<FFICallPrototype>(globalObject->vm().heap)) FFICallPrototype(globalObject->vm(), structure);
        prototype->finishCreation(vm, globalObject);
        return prototype;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    FFICallPrototype(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*);
};
}

#endif /* defined(__NativeScript__FFICallPrototype__) */
