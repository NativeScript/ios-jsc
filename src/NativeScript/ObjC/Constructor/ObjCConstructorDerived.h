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

    static ObjCConstructorDerived* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, JSC::JSObject* prototype, Class klass) {
        ObjCConstructorDerived* cell = new (NotNull, JSC::allocateCell<ObjCConstructorDerived>(vm.heap)) ObjCConstructorDerived(vm, structure);
        cell->finishCreation(vm, globalObject, prototype, klass);
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
        static_cast<ObjCConstructorDerived*>(cell)->~ObjCConstructorDerived();
    }
};
} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCConstructorDerived__) */
