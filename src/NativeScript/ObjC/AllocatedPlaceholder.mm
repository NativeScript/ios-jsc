//
//  AllocatedPlaceholder.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 7/9/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "AllocatedPlaceholder.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo AllocatedPlaceholder::s_info = { "AllocatedPlaceholder", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(AllocatedPlaceholder) };

void AllocatedPlaceholder::visitChildren(JSCell* cell, JSC::SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    AllocatedPlaceholder* object = jsCast<AllocatedPlaceholder*>(cell);

    visitor.append(object->_instanceStructure);
}

void AllocatedPlaceholder::destroy(JSC::JSCell* cell) {
    static_cast<AllocatedPlaceholder*>(cell)->~AllocatedPlaceholder();
}

void AllocatedPlaceholder::finishCreation(JSC::VM& vm, GlobalObject* globalObject, id wrappedObject, JSC::Structure* instanceStructure) {
    Base::finishCreation(vm);
    this->_wrappedObject = wrappedObject;
    this->_instanceStructure.set(vm, this, instanceStructure);
}

AllocatedPlaceholder::~AllocatedPlaceholder() {
}

} // namespace NativeScript
