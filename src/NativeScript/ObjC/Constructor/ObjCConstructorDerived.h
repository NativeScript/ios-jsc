//
//  ObjCConstructorDerived.h
//  NativeScript
//
//  Created by Ivan Buhov on 8/12/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCConstructorDerived__
#define __NativeScript__ObjCConstructorDerived__

#include "ObjCConstructorBase.h"

namespace NativeScript {
class ObjCConstructorDerived : public ObjCConstructorBase {
public:
    typedef ObjCConstructorBase Base;

    static const unsigned StructureFlags;

    static ObjCConstructorDerived* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, JSC::JSObject* prototype, Class klass, ObjCConstructorBase* parent) {
        ObjCConstructorDerived* cell = new (NotNull, JSC::allocateCell<ObjCConstructorDerived>(vm.heap)) ObjCConstructorDerived(vm, structure);
        cell->finishCreation(vm, globalObject, prototype, klass, parent);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

protected:
    ObjCConstructorDerived(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<ObjCConstructorDerived*>(cell)->~ObjCConstructorDerived();
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, JSC::JSObject* prototype, Class, ObjCConstructorBase* parent);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

private:
    const WTF::Vector<ObjCConstructorCall*> initializersGenerator(JSC::VM&, GlobalObject*, Class);

    JSC::WriteBarrier<ObjCConstructorBase> _parent;
};
}

#endif /* defined(__NativeScript__ObjCConstructorDerived__) */
