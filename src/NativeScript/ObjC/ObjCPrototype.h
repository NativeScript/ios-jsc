//
//  ObjCPrototype.h
//  NativeScript
//
//  Created by Yavor Georgiev on 17.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCPrototype__
#define __NativeScript__ObjCPrototype__

#include <JavaScriptCore/JSObject.h>
#include <wtf/RetainPtr.h>

namespace Metadata {
struct BaseClassMeta;
}

namespace NativeScript {
class ObjCPrototype : public JSC::JSDestructibleObject {
public:
    typedef JSC::JSDestructibleObject Base;

    static const unsigned StructureFlags;

    static JSC::Strong<ObjCPrototype> create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, const Metadata::BaseClassMeta* metadata, Class klass) {
        JSC::Strong<ObjCPrototype> prototype(vm, new (NotNull, JSC::allocateCell<ObjCPrototype>(globalObject->vm().heap)) ObjCPrototype(globalObject->vm(), structure, klass));
        prototype->finishCreation(vm, globalObject, metadata);
        return prototype;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    static WTF::String className(const JSObject* object, JSC::VM&);

    void materializeProperties(JSC::VM& vm, GlobalObject* globalObject);

    const Metadata::BaseClassMeta* metadata() const {
        return this->_metadata;
    }

    Class klass() const {
        return this->_klass;
    }

private:
    ObjCPrototype(JSC::VM& vm, JSC::Structure* structure, Class klass)
        : Base(vm, structure)
        , _klass(klass) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, const Metadata::BaseClassMeta*);

    static bool getOwnPropertySlot(JSC::JSObject*, JSC::ExecState*, JSC::PropertyName, JSC::PropertySlot&);

    static bool put(JSC::JSCell*, JSC::ExecState*, JSC::PropertyName, JSC::JSValue, JSC::PutPropertySlot&);

    static bool defineOwnProperty(JSC::JSObject*, JSC::ExecState*, JSC::PropertyName, const JSC::PropertyDescriptor&, bool shouldThrow);

    static void getOwnPropertyNames(JSC::JSObject*, JSC::ExecState*, JSC::PropertyNameArray&, JSC::EnumerationMode);

    const Metadata::BaseClassMeta* _metadata;

    Class _klass;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCPrototype__) */
