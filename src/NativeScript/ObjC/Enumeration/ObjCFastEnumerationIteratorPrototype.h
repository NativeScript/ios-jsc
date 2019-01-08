//
//  ObjCFastEnumerationIteratorPrototype.h
//  NativeScript
//
//  Created by Yavor Georgiev on 14.07.15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCFastEnumerationIteratorPrototype__
#define __NativeScript__ObjCFastEnumerationIteratorPrototype__

#include <JavaScriptCore/JSObject.h>

namespace NativeScript {
class ObjCFastEnumerationIteratorPrototype : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static const unsigned StructureFlags = Base::StructureFlags;

    static JSC::Strong<ObjCFastEnumerationIteratorPrototype> create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure) {
        JSC::Strong<ObjCFastEnumerationIteratorPrototype> prototype(vm, new (NotNull, JSC::allocateCell<ObjCFastEnumerationIteratorPrototype>(globalObject->vm().heap)) ObjCFastEnumerationIteratorPrototype(globalObject->vm(), structure));
        prototype->finishCreation(vm, globalObject);
        return prototype;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

private:
    ObjCFastEnumerationIteratorPrototype(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*);
};
} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCFastEnumerationIteratorPrototype__) */
