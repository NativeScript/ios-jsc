//
//  RecordInstance.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/13/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "RecordInstance.h"
#include "Interop.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo RecordInstance::s_info = { "record", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(RecordInstance) };

void RecordInstance::finishCreation(ExecState* execState, JSGlobalObject* globalObject, size_t size, PointerInstance* pointer) {
    Base::finishCreation(execState->vm());
    this->preventExtensions(this, execState);

    this->_size = size;
    this->_pointer.set(execState->vm(), this, pointer);
}

void RecordInstance::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    RecordInstance* object = jsCast<RecordInstance*>(cell);
    visitor.append(object->_pointer);
}
} // namespace NativeScript
