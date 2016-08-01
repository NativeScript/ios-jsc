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

namespace NativeScript {
class ObjCConstructorNative : public ObjCConstructorBase {
public:
    typedef ObjCConstructorBase Base;

    static ObjCConstructorNative* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, JSC::JSObject* prototype, Class klass) {
        ASSERT(klass);
        ObjCConstructorNative* cell = new (NotNull, JSC::allocateCell<ObjCConstructorNative>(vm.heap)) ObjCConstructorNative(vm, structure);
        cell->finishCreation(vm, globalObject, prototype, klass);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    JSC::Structure* allocatedPlaceholderStructure() const {
        return _allocatedPlaceholderStructure.get();
    }

    void materializeProperties(JSC::VM&, GlobalObject*);

protected:
    ObjCConstructorNative(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, JSC::JSObject* prototype, Class);

    static void getOwnPropertyNames(JSC::JSObject*, JSC::ExecState*, JSC::PropertyNameArray&, JSC::EnumerationMode);

    static void put(JSC::JSCell*, JSC::ExecState*, JSC::PropertyName, JSC::JSValue, JSC::PutPropertySlot&);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

private:
    static bool getOwnPropertySlot(JSC::JSObject*, JSC::ExecState*, JSC::PropertyName, JSC::PropertySlot&);

    JSC::WriteBarrier<JSC::Structure> _allocatedPlaceholderStructure;
};
}

#endif /* defined(__NativeScript__ObjCConstructorNative__) */
