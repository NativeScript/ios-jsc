//
//  ObjCWrapperObject.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 17.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "ObjCWrapperObject.h"
#include "Interop.h"
#include "ObjCTypes.h"
#include "TNSDerivedClassProtocol.h"
#include "TNSRuntime+Private.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCWrapperObject::s_info = { "ObjCWrapperObject", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCWrapperObject) };

void ObjCWrapperObject::finishCreation(VM& vm, id wrappedObject, GlobalObject* globalObject) {
    Base::finishCreation(vm);
    this->_objectMap = [TNSRuntime runtimeForVM:&globalObject->vm()] -> _objectMap.get();
    this->setWrappedObject(wrappedObject);
    this->_canSetObjectAtIndexedSubscript = [wrappedObject respondsToSelector:@selector(setObject:
                                                                                  atIndexedSubscript:)];
}

WTF::String ObjCWrapperObject::className(const JSObject* object, VM&) {
    Class klass = [jsCast<const ObjCWrapperObject*>(object)->_wrappedObject.get() class];
    return class_getName(klass);
}

bool ObjCWrapperObject::getOwnPropertySlotByIndex(JSObject* object, ExecState* execState, unsigned propertyName, PropertySlot& propertySlot) {
    ObjCWrapperObject* wrapper = jsCast<ObjCWrapperObject*>(object);

    JSValue value = toValue(execState, [wrapper->wrappedObject() objectAtIndexedSubscript:propertyName]);
    propertySlot.setValue(object, static_cast<unsigned>(PropertyAttribute::None), value);
    return true;
}

bool ObjCWrapperObject::putByIndex(JSCell* cell, ExecState* execState, unsigned propertyName, JSValue value, bool shouldThrow) {
    ObjCWrapperObject* wrapper = jsCast<ObjCWrapperObject*>(cell);
    if (wrapper->_canSetObjectAtIndexedSubscript) {
        [wrapper->wrappedObject() setObject:NativeScript::toObject(execState, value)
                         atIndexedSubscript:propertyName];
    }

    return Base::putByIndex(cell, execState, propertyName, value, shouldThrow);
}

void ObjCWrapperObject::setWrappedObject(id wrappedObject) {
    if (this->_wrappedObject) {
        this->_objectMap->remove(this->_wrappedObject.get());

        if ([this->_wrappedObject.get() conformsToProtocol:@protocol(TNSDerivedClass)] && [this->_wrappedObject retainCount] > 1) {
            // Derived classes have additional logic for protecting JS counterparts in their retain/release methods when the retention
            // count is above 1, after we remove the old wrapped object from the objectMap it will no longer be able to unprotect us
            // and we do it here in order to become eligible for GC
            gcUnprotect(this);
        }
#ifdef DEBUG_MEMORY
        NSLog(@"ObjCWrapperObject soon releasing %@(%p)", object_getClass(this->_wrappedObject.get()), this->_wrappedObject.get());
#endif
        Heap::heap(this)->releaseSoon(std::move(this->_wrappedObject));
    }

    this->_wrappedObject = wrappedObject;

    if (wrappedObject) {
        this->_objectMap->set(wrappedObject, this);

        if ([wrappedObject conformsToProtocol:@protocol(TNSDerivedClass)] && [wrappedObject retainCount] > 1) {
            // Derived classes have additional logic for protecting JS counterparts in their retain/release methods when the retention
            // count is above 1,after we add the wrapped object to the objectMap we should add protect so that the unprotect in release
            // is balanced out
            gcProtect(this);
        }
    }
}

ObjCWrapperObject::~ObjCWrapperObject() {
    this->setWrappedObject(nil);
}

}
