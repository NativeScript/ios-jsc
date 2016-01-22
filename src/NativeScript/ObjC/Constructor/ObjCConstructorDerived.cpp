//
//  ObjCConstructorDerived.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 8/12/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "NativeScript-Prefix.h"
#include "ObjCConstructorDerived.h"

namespace NativeScript {

using namespace JSC;

const ClassInfo ObjCConstructorDerived::s_info = { "Function", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCConstructorDerived) };

const unsigned ObjCConstructorDerived::StructureFlags = OverridesGetOwnPropertySlot | Base::StructureFlags;

void ObjCConstructorDerived::finishCreation(VM& vm, JSGlobalObject* globalObject, JSObject* prototype, Class klass, ObjCConstructorBase* parent) {
    Base::finishCreation(vm, globalObject, prototype, klass);

    this->_parent.set(vm, this, parent);
    this->ObjCConstructorBase::_initializersGenerator = std::bind(&ObjCConstructorDerived::initializersGenerator, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
}

void ObjCConstructorDerived::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);
    ObjCConstructorDerived* constructor = jsCast<ObjCConstructorDerived*>(cell);
    visitor.append(&constructor->_parent);
}

const WTF::Vector<ObjCConstructorCall*> ObjCConstructorDerived::initializersGenerator(VM& vm, GlobalObject* globalObject, Class target) {
    return this->_parent.get()->generateInitializers(vm, globalObject, target);
}
}