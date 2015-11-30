//
//  ObjCTypes.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 13.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include <JavaScriptCore/JSArrayBuffer.h>
#include <JavaScriptCore/DateInstance.h>
#include <JavaScriptCore/JSMap.h>
#include <JavaScriptCore/BooleanObject.h>
#include "ObjCTypes.h"
#include "ObjCSuperObject.h"
#include "ObjCConstructorBase.h"
#include "ObjCConstructorCall.h"
#include "ObjCProtocolWrapper.h"
#include "ObjCConstructorDerived.h"
#include "Interop.h"
#include "AllocatedPlaceholder.h"

#import "TNSArrayAdapter.h"
#import "TNSDictionaryAdapter.h"
#import "TNSDataAdapter.h"

using namespace JSC;

class TNSValueWrapperWeakHandleOwner : public WeakHandleOwner {
    virtual void finalize(Handle<Unknown> handle, void* context) override {
        [reinterpret_cast<TNSValueWrapper*>(context) detach];

        WeakSet::deallocate(WeakImpl::asWeakImpl(handle.slot()));
    }
};

static WeakHandleOwner* weakHandleOwner() {
    static WeakHandleOwner* owner;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        owner = new TNSValueWrapperWeakHandleOwner();
    });

    return owner;
}

@implementation TNSValueWrapper {
    Weak<JSObject> _valueWrapper;
    id _host;
    void* _associationKey;
}

+ (void)attachValue:(JSC::JSObject*)value toHost:(id)host {
    TNSValueWrapper* wrapper = [[self alloc] initWithValue:value
                                                      host:host];

    objc_setAssociatedObject(host, value->globalObject()->JSC::JSScope::vm(), wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#ifdef DEBUG_MEMORY
    NSLog(@"TNSValueWrapper attached to %@(%p)", object_getClass(host), host);
#endif
    [wrapper release];
}

- (instancetype)initWithValue:(JSObject*)value host:(id)host {
    if (self = [super init]) {
        self->_valueWrapper = Weak<JSObject>(value, weakHandleOwner(), self);
        self->_host = host;
        self->_associationKey = value->globalObject()->JSC::JSScope::vm();
    }

    return self;
}

- (JSObject*)value {
    return self->_valueWrapper.get();
}

- (void)detach {
    objc_setAssociatedObject(self->_host, self->_associationKey, nil, OBJC_ASSOCIATION_ASSIGN);
#ifdef DEBUG_MEMORY
    NSLog(@"TNSValueWrapper detached from %@(%p)", object_getClass(self->_host), self->_host);
#endif
}

@end

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
        return [[static_cast<NSString *>(jsCast<JSString*>(value)->value(execState)) copy] autorelease];
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

    return toValue(execState, object, ^{ return globalObject->constructorFor(object_getClass(object), klass)->instancesStructure(); });
}

JSValue toValue(ExecState* execState, id object, Structure* (^structureResolver)()) {
    if (object == nil) {
        return jsNull();
    }

#if defined(__LP64__) && __LP64__
    // There is a bug in the Objective-C runtime on 64 bit architectures, which seems to be fixed in iOS 8.
    // We cannot use the association API with tagged pointers, so we fallback to an external map.
    // This workaround is kept for iOS 8 64bit, because it is faster there too and the code is easier to test/maintain.
    // For more information on tagged pointers see "objc-internal.h" in opensource.apple.com

    // This check is the same as _objc_isTaggedPointer, which is a private function.
    if (reinterpret_cast<intptr_t>(object) < 0) {
        NativeScript::GlobalObject* globalObject = jsCast<NativeScript::GlobalObject*>(execState->lexicalGlobalObject());
        if (ObjCWrapperObject* wrapper = globalObject->taggedPointers().get(object)) {
            return wrapper;
        }

        ObjCWrapperObject* wrapper = ObjCWrapperObject::create(execState->vm(), structureResolver(), object, jsCast<GlobalObject*>(execState->lexicalGlobalObject()));
        globalObject->taggedPointers().set(object, wrapper);
        return wrapper;
    } else {
#endif
        TNSValueWrapper* valueWrapper = static_cast<TNSValueWrapper*>(objc_getAssociatedObject(object, execState->lexicalGlobalObject()->JSCell::vm()));
        if (JSObject* wrapper = valueWrapper.value) {
            return wrapper;
        }

        ObjCWrapperObject* wrapper = ObjCWrapperObject::create(execState->vm(), structureResolver(), object, jsCast<GlobalObject*>(execState->lexicalGlobalObject()));
        [TNSValueWrapper attachValue:wrapper
                              toHost:object];
        return wrapper;
#if defined(__LP64__) && __LP64__
    }
#endif
}
}
