//
//  ObjCConstructorNative.h
//  NativeScript
//
//  Created by Ivan Buhov on 8/12/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCConstructorNative__
#define __NativeScript__ObjCConstructorNative__

#include "ObjCConstructorBase.h"

namespace Metadata {
struct InterfaceMeta;
}

namespace NativeScript {
class ObjCConstructorNative : public ObjCConstructorBase {
public:
    typedef ObjCConstructorBase Base;

    static const unsigned StructureFlags;

    static ObjCConstructorNative* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, JSC::JSObject* prototype, Class klass, const Metadata::InterfaceMeta* metadata) {
        ASSERT(klass);
        ObjCConstructorNative* cell = new (NotNull, JSC::allocateCell<ObjCConstructorNative>(vm.heap)) ObjCConstructorNative(vm, structure);
        cell->finishCreation(vm, globalObject, prototype, klass, metadata);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    const Metadata::InterfaceMeta* metadata() const {
        return this->_metadata;
    }

    const WTF::Vector<ObjCConstructorCall*> initializersGenerator(JSC::VM&, GlobalObject*, Class);

protected:
    ObjCConstructorNative(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, JSC::JSObject* prototype, Class, const Metadata::InterfaceMeta*);

    static void getOwnPropertyNames(JSC::JSObject*, JSC::ExecState*, JSC::PropertyNameArray&, JSC::EnumerationMode);

    static void put(JSC::JSCell*, JSC::ExecState*, JSC::PropertyName, JSC::JSValue, JSC::PutPropertySlot&);

private:
    static bool getOwnPropertySlot(JSC::JSObject*, JSC::ExecState*, JSC::PropertyName, JSC::PropertySlot&);

    const Metadata::InterfaceMeta* _metadata;
};
}

#endif /* defined(__NativeScript__ObjCConstructorNative__) */
