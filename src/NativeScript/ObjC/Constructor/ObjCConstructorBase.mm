//
//  ObjCConstructor.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 17.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "ObjCConstructorBase.h"
#include <JavaScriptCore/JSMap.h>
#include <JavaScriptCore/JSArrayBuffer.h>
#include "ObjCWrapperObject.h"
#include "ObjCMethodCall.h"
#include "ObjCConstructorCall.h"
#include "ObjCTypes.h"
#include "Interop.h"
#include "PointerInstance.h"

#import "TNSArrayAdapter.h"
#import "TNSDictionaryAdapter.h"
#import "TNSDataAdapter.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCConstructorBase::s_info = { "Function", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCConstructorBase) };

// TODO: Use the current class in finish creation
JSValue ObjCConstructorBase::read(ExecState* execState, void const* buffer, JSCell* self) {
    ObjCConstructorBase* type = jsCast<ObjCConstructorBase*>(self);
    id value = *static_cast<const id*>(buffer);
    return toValue(execState, value, type->_klass);
}

void ObjCConstructorBase::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    *static_cast<id*>(buffer) = NativeScript::toObject(execState, value);
}

template <typename TAdapter>
static void writeAdapter(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    if (ObjCWrapperObject* wrapper = jsDynamicCast<ObjCWrapperObject*>(value)) {
        *static_cast<id*>(buffer) = wrapper->wrappedObject();
    } else if (JSObject* object = jsDynamicCast<JSObject*>(value)) {
        *static_cast<id*>(buffer) = [[[TAdapter alloc] initWithJSObject:object
                                                              execState:execState->lexicalGlobalObject()->globalExec()] autorelease];
    } else {
        *static_cast<id*>(buffer) = nil;
    }
}

bool ObjCConstructorBase::canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    ObjCConstructorBase* type = jsCast<ObjCConstructorBase*>(self);

    if (!type->_klass || value.isUndefinedOrNull()) {
        return true;
    }

    if (value.inherits(ObjCWrapperObject::info())) {
        return [jsCast<ObjCWrapperObject*>(value.asCell())->wrappedObject() isKindOfClass:type->_klass];
    }

    if (value.isString()) {
        return [type->_klass isSubclassOfClass:[NSString class]];
    }

    if (value.isNumber() || value.isBoolean()) {
        return [type->_klass isSubclassOfClass:[NSNumber class]];
    }

    if (value.inherits(JSArray::info())) {
        return [type->_klass isSubclassOfClass:[NSArray class]];
    }

    if (value.inherits(JSMap::info())) {
        return [type->_klass isSubclassOfClass:[NSDictionary class]];
    }

    if (value.inherits(JSArrayBuffer::info()) || value.inherits(JSArrayBufferView::info())) {
        return [type->_klass isSubclassOfClass:[NSData class]];
    }

    return false;
}

const char* ObjCConstructorBase::encode(JSCell* cell) {
    return "@";
}

void ObjCConstructorBase::finishCreation(VM& vm, JSGlobalObject* globalObject, JSObject* prototype, Class klass) {
    Base::finishCreation(vm, WTF::String(class_getName(klass)));

    this->_prototype.set(vm, this, prototype);
    this->_instancesStructure.set(vm, this, ObjCWrapperObject::createStructure(vm, globalObject, prototype));

    this->_klass = klass;

    this->_ffiTypeMethodTable.ffiType = &ffi_type_pointer;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.canConvert = &canConvert;
    this->_ffiTypeMethodTable.encode = &encode;

    if (klass == [NSArray class]) {
        this->_ffiTypeMethodTable.write = &writeAdapter<TNSArrayAdapter>;
    } else if (klass == [NSDictionary class]) {
        this->_ffiTypeMethodTable.write = &writeAdapter<TNSDictionaryAdapter>;
    } else if (klass == [NSData class] || klass == [NSMutableData class]) {
        this->_ffiTypeMethodTable.write = &writeAdapter<TNSDataAdapter>;
    } else {
        this->_ffiTypeMethodTable.write = &write;
    }
}

WTF::String ObjCConstructorBase::className(const JSObject* object) {
    return [NSStringFromClass(((ObjCConstructorBase*)object)->_klass) stringByAppendingString:@"Constructor"];
}

bool ObjCConstructorBase::getOwnPropertySlot(JSObject* object, ExecState* execState, PropertyName propertyName, PropertySlot& propertySlot) {
    if (Base::getOwnPropertySlot(object, execState, propertyName, propertySlot)) {
        return true;
    }

    if (propertyName == execState->vm().propertyNames->prototype) {
        ObjCConstructorBase* constructor = jsCast<ObjCConstructorBase*>(object);
        propertySlot.setValue(object, None, constructor->_prototype.get());
        return true;
    }

    return false;
}

const WTF::Vector<WriteBarrier<ObjCConstructorCall>>& ObjCConstructorBase::initializers(VM& vm, GlobalObject* globalObject) {
    if (this->_initializers.size() == 0) {
        for (ObjCConstructorCall* initializer : this->generateInitializers(vm, globalObject, this->klass())) {
            this->_initializers.append(WriteBarrier<ObjCConstructorCall>(vm, this, initializer));
        }
    }

    return this->_initializers;
}

void ObjCConstructorBase::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);
    ObjCConstructorBase* constructor = jsCast<ObjCConstructorBase*>(cell);
    visitor.append(&constructor->_prototype);
    visitor.append(&constructor->_instancesStructure);
    visitor.append(constructor->_initializers.begin(), constructor->_initializers.end());
}

static EncodedJSValue JSC_HOST_CALL constructObjCClass(ExecState* execState) {
    ObjCConstructorBase* constructor = jsCast<ObjCConstructorBase*>(execState->callee());
    WTF::Vector<ObjCConstructorCall*> candidateInitializers;

    for (WriteBarrier<ObjCConstructorCall> initializer : constructor->initializers(execState->vm(), jsCast<GlobalObject*>(execState->lexicalGlobalObject()))) {
        if (initializer->canInvoke(execState)) {
            candidateInitializers.append(initializer.get());
        }
    }

    if (candidateInitializers.size() == 0) {
        return JSValue::encode(execState->vm().throwException(execState, createError(execState, WTF::ASCIILiteral("No initializer found that matches constructor invocation."))));
    } else if (candidateInitializers.size() > 1) {
        WTF::StringBuilder errorMessage;
        errorMessage.append("More than one initializer found that matches constructor invocation:");
        for (ObjCConstructorCall* initializer : candidateInitializers) {
            errorMessage.append(" ");
            errorMessage.append(sel_getName(initializer->selector()));
        }
        return JSValue::encode(execState->vm().throwException(execState, createError(execState, errorMessage.toString())));
    } else {
        ObjCConstructorCall* initializer = candidateInitializers[0];

        CallData callData;
        CallType callType = initializer->methodTable()->getCallData(initializer, callData);
        return JSValue::encode(call(execState, initializer, callType, callData, constructor, execState));
    }
}

ConstructType ObjCConstructorBase::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = constructObjCClass;

    return ConstructTypeHost;
}

static EncodedJSValue JSC_HOST_CALL createObjCClass(ExecState* execState) {
    JSValue argument = execState->argument(0);

    bool hasHandle;
    void* handle = tryHandleofValue(argument, &hasHandle);
    if (!handle) {
        WTF::String message = WTF::String::format("Value must be a %s.", PointerInstance::info()->className);
        return throwVMError(execState, createError(execState, message));
    }

    ObjCConstructorBase* constructor = jsCast<ObjCConstructorBase*>(execState->callee());
    JSValue result = toValue(execState, static_cast<id>(handle), ^Structure * {
      return constructor->instancesStructure();
    });
    return JSValue::encode(result);
}

CallType ObjCConstructorBase::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = createObjCClass;

    return CallTypeHost;
}
}
