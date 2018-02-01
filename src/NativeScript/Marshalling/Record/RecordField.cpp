//
//  RecordField.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/13/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "RecordField.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo RecordField::s_info = { "RecordField", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(RecordField) };

void RecordField::finishCreation(VM& vm, const WTF::String& fieldName, JSCell* fieldType, ptrdiff_t offset) {
    Base::finishCreation(vm);

    this->_fieldName = fieldName;
    this->_fieldType.set(vm, this, fieldType);
    this->_offset = offset;
    this->_ffiTypeMethodTable = getFFITypeMethodTable(vm, fieldType);
}

void RecordField::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    RecordField* object = jsCast<RecordField*>(cell);
    visitor.append(object->_fieldType);
}
} // namespace NativeScript
