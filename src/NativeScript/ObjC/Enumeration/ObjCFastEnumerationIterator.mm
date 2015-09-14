//
//  ObjCFastEnumerationIterator.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 14.07.15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "ObjCFastEnumerationIterator.h"
#include "ObjCTypes.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCFastEnumerationIterator::s_info = { "NSFastEnumeration Iterator", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCFastEnumerationIterator) };

void ObjCFastEnumerationIterator::finishCreation(VM& vm, JSGlobalObject* globalObject, id object) {
    Base::finishCreation(vm);

    this->_object = object;
#ifdef DEBUG_MEMORY
    NSLog(@"ObjCFastEnumerationIterator retained %@(%p)", object_getClass(object), object);
#endif

    if ((this->_count = [this->_object.get() countByEnumeratingWithState:&this->_state objects:this->_buffer.data() count:this->_buffer.size()])) {
        this->_mutationSentinel = *this->_state.mutationsPtr;
    }
}

bool ObjCFastEnumerationIterator::next(ExecState* execState, JSValue& value) {
    if (this->_index == this->_count && this->_count) {
        this->_count = [this->_object.get() countByEnumeratingWithState:&this->_state objects:this->_buffer.data() count:this->_buffer.size()];

        if (this->_mutationSentinel != *this->_state.mutationsPtr) {
            execState->vm().throwException(execState, createError(execState, WTF::ASCIILiteral("The iterable was changed during enumeration.")));
            return false;
        }

        this->_index = 0;
    }

    if (this->_index < this->_count) {
        value = toValue(execState, this->_state.itemsPtr[this->_index++]);
        return true;
    }

    return false;
}

ObjCFastEnumerationIterator::~ObjCFastEnumerationIterator() {
#ifdef DEBUG_MEMORY
    NSLog(@"ObjCFastEnumerationIterator soon releasing %@(%p)", object_getClass(this->_object.get()), this->_object.get());
#endif
    Heap::heap(this)->releaseSoon(std::move(this->_object));
}
}