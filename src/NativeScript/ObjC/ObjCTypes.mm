//
//  ObjCTypes.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 13.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "ObjCTypes.h"
#include "AllocatedPlaceholder.h"
#include "FFIType.h"
#include "Interop.h"
#include "ObjCConstructorBase.h"
#include "ObjCConstructorCall.h"
#include "ObjCConstructorDerived.h"
#include "ObjCProtocolWrapper.h"
#include "ObjCSuperObject.h"
#include "ObjCWrapperObject.h"
#include <JavaScriptCore/BooleanObject.h>
#include <JavaScriptCore/DateInstance.h>
#include <JavaScriptCore/JSArrayBuffer.h>
#include <JavaScriptCore/JSMap.h>
#include <objc/runtime.h>

#import "TNSArrayAdapter.h"
#import "TNSDataAdapter.h"
#import "TNSDictionaryAdapter.h"

using namespace JSC;

namespace NativeScript {

id toObject(ExecState* execState, const JSValue& value) {
    if (value.inherits(ObjCWrapperObject::info())) {
        return jsCast<ObjCWrapperObject*>(value.asCell())->wrappedObject();
    }

    if (value.inherits(ObjCConstructorBase::info())) {
        return jsCast<ObjCConstructorBase*>(value.asCell())->klass();
    }

    if (value.inherits(AllocatedPlaceholder::info())) {
        return jsCast<AllocatedPlaceholder*>(value.asCell())->wrappedObject();
    }

    if (value.isUndefinedOrNull()) {
        return nil;
    }

    if (value.isInt32()) {
        return @(value.asInt32());
    }

    if (value.isUInt32()) {
        return @(value.asUInt32());
    }

    if (value.isDouble()) {
        return @(value.asDouble());
    }

    if (value.isBoolean()) {
        return @((BOOL)value.asBoolean());
    }

    if (value.isString()) {
        return [[static_cast<NSString*>(jsCast<JSString*>(value)->value(execState)) copy] autorelease];
    }

    if (JSArray* array = jsDynamicCast<JSArray*>(value)) {
        return [[[TNSArrayAdapter alloc] initWithJSObject:array
                                                execState:execState->lexicalGlobalObject()->globalExec()] autorelease];
    }

    if (value.inherits(ObjCSuperObject::info())) {
        return jsCast<ObjCSuperObject*>(value.asCell())->wrapperObject()->wrappedObject();
    }

    if (value.inherits(DateInstance::info())) {
        return [NSDate dateWithTimeIntervalSince1970:(value.toNumber(execState) / 1000)];
    }

    if (value.inherits(JSArrayBuffer::info()) || value.inherits(JSArrayBufferView::info())) {
        return [[[TNSDataAdapter alloc] initWithJSObject:asObject(value)
                                               execState:execState->lexicalGlobalObject()->globalExec()] autorelease];
    }

    bool hasHandle;
    void* handle = tryHandleofValue(value, &hasHandle);
    if (hasHandle) {
        return static_cast<id>(handle);
    }

    if (value.isCell()) {
        JSCell* wrapper = value.asCell();
        const ClassInfo* wrapperInfo = wrapper->classInfo();
        if (wrapperInfo == StringObject::info() || wrapperInfo == NumberObject::info() || wrapperInfo == BooleanObject::info()) {
            return toObject(execState, jsCast<JSWrapperObject*>(value)->internalValue());
        }
    }

    if (JSObject* object = jsDynamicCast<JSObject*>(value)) {
        return [[[TNSDictionaryAdapter alloc] initWithJSObject:object
                                                     execState:execState->lexicalGlobalObject()->globalExec()] autorelease];
    }

    throwVMError(execState, createError(execState, WTF::String::format("Could not marshall \"%s\" to id.", value.toWTFString(execState).utf8().data())));
    return nil;
}

JSValue toValue(ExecState* execState, id object, Class klass) {
    if (object == nil) {
        return jsNull();
    }

    if (object == [NSNull null]) {
        return jsNull();
    }

    if ([object isKindOfClass:[NSString class]] && klass != [NSMutableString class]) {
        return jsString(execState, (CFStringRef)object);
    }

    if ([object isKindOfClass:[@YES class]]) {
        return jsBoolean([object boolValue]);
    }

    if ([object isKindOfClass:[NSNumber class]] && ![object isKindOfClass:[NSDecimalNumber class]]) {
        return jsNumber([object doubleValue]);
    }

    if ([object isKindOfClass:[NSDate class]]) {
        return DateInstance::create(execState->vm(), execState->lexicalGlobalObject()->dateStructure(), [object timeIntervalSince1970] * 1000.0);
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    if (class_isMetaClass(object_getClass(object))) {
        return globalObject->constructorFor(object_getClass(object), klass);
    }

    return toValue(execState, object, ^{
      return globalObject->constructorFor(object_getClass(object), klass)->instancesStructure();
    });
}

JSValue toValue(ExecState* execState, id object, Structure* (^structureResolver)()) {
    if (object == nil) {
        return jsNull();
    }

    auto globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    if (JSObject* wrapper = globalObject->interop()->objectMap().get(object)) {
        ASSERT(wrapper->classInfo() != ObjCWrapperObject::info() || jsCast<ObjCWrapperObject*>(wrapper)->wrappedObject() == object);
        return wrapper;
    }

    return ObjCWrapperObject::create(execState->vm(), structureResolver(), object, globalObject);
}
}
