//
//  AllocatedPlaceholder.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 7/9/15.
//
//

#include "AllocatedPlaceholder.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo AllocatedPlaceholder::s_info = { "AllocatedPlaceholder", &Base::s_info, 0, CREATE_METHOD_TABLE(AllocatedPlaceholder) };

void AllocatedPlaceholder::visitChildren(JSCell* cell, JSC::SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    AllocatedPlaceholder* object = jsCast<AllocatedPlaceholder*>(cell);

    visitor.append(&object->_instanceStructure);
}
}