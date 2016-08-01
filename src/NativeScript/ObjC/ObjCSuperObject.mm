//
//  ObjCSuperObject.mm
//  NativeScript
//
//  Created by Panayot Cankov on 8/5/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCSuperObject.h"
#include "Interop.h"
#include "ObjCWrapperObject.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCSuperObject::s_info = { "ObjCSuperObject", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCSuperObject) };

void ObjCSuperObject::finishCreation(VM& vm, ObjCWrapperObject* wrapper, GlobalObject* globalObject) {
    Base::finishCreation(vm);
    this->_wrapperObject.set(vm, this, wrapper);
}

JSValue ObjCSuperObject::toThis(JSCell* cell, ExecState* execState, ECMAMode mode) {
    return JSValue(static_cast<ObjCSuperObject*>(cell)->wrapperObject());
}

void ObjCSuperObject::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    ObjCSuperObject* superObject = jsCast<ObjCSuperObject*>(cell);
    visitor.append(&superObject->_wrapperObject);
}
}
