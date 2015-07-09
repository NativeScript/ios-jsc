//
//  ObjCWrapperObject.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 17.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "ObjCWrapperObject.h"
#include "ObjCTypes.h"
#include "Interop.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCWrapperObject::s_info = { "ObjCWrapperObject", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCWrapperObject) };

void ObjCWrapperObject::finishCreation(VM& vm, id wrappedObject, GlobalObject* globalObject) {
    Base::finishCreation(vm);
    this->setWrappedObject(wrappedObject);
    this->_canSetObjectAtIndexedSubscript = [wrappedObject respondsToSelector:@selector(setObject:
                                                                                  atIndexedSubscript:)];
    Identifier instancesStructureIdentifier = Identifier::fromUid(globalObject->interop()->instancesStructureSymbol()->privateName());
    this->putDirect(vm, instancesStructureIdentifier, JSValue(this->structure()), ReadOnly | DontEnum | DontDelete);
}

WTF::String ObjCWrapperObject::className(const JSObject* object) {
    Class klass = [jsCast<const ObjCWrapperObject*>(object)->_wrappedObject.get() class];
    return class_getName(klass);
}

bool ObjCWrapperObject::getOwnPropertySlotByIndex(JSObject* object, ExecState* execState, unsigned propertyName, PropertySlot& propertySlot) {
    ObjCWrapperObject* wrapper = jsCast<ObjCWrapperObject*>(object);

    JSValue value = toValue(execState, [wrapper->wrappedObject() objectAtIndexedSubscript:propertyName]);
    propertySlot.setValue(object, None, value);
    return true;
}

void ObjCWrapperObject::putByIndex(JSCell* cell, ExecState* execState, unsigned propertyName, JSValue value, bool shouldThrow) {
    ObjCWrapperObject* wrapper = jsCast<ObjCWrapperObject*>(cell);
    if (wrapper->_canSetObjectAtIndexedSubscript) {
        [wrapper->wrappedObject() setObject:NativeScript::toObject(execState, value)
                         atIndexedSubscript:propertyName];
    }

    Base::putByIndex(cell, execState, propertyName, value, shouldThrow);
}

ObjCWrapperObject::~ObjCWrapperObject() {
#ifdef DEBUG_MEMORY
    NSLog(@"ObjCWrapperObject soon releasing %@(%p)", object_getClass(this->_wrappedObject.get()), this->_wrappedObject.get());
#endif
    Heap::heap(this)->releaseSoon(std::move(this->_wrappedObject));
}
}
