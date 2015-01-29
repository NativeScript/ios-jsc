//
//  ObjCTypes.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 13.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include <JavaScriptCore/JSArrayBuffer.h>
#include "ObjCTypes.h"
#include "ObjCSuperObject.h"
#include "ObjCConstructorBase.h"
#include "ObjCConstructorCall.h"
#include "ObjCProtocolWrapper.h"
#include "ObjCConstructorDerived.h"

using namespace JSC;

class TNSValueWrapperWeakHandleOwner : public WeakHandleOwner {
    virtual void finalize(Handle<Unknown> handle, void* context) {
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
    Weak<NativeScript::ObjCWrapperObject> _valueWrapper;
    id _host;
    void* _associationKey;
}

+ (void)attachValue:(NativeScript::ObjCWrapperObject*)value toHost:(id)host {
    TNSValueWrapper* wrapper = [[self alloc] initWithValue:value
                                                      host:host];
    objc_setAssociatedObject(host, value->globalObject()->JSC::JSScope::vm(), wrapper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
#if DEBUG_MEMORY
    NSLog(@"TNSValueWrapper attached to %@(%p)", object_getClass(host), host);
#endif
    [wrapper release];
}

- (instancetype)initWithValue:(NativeScript::ObjCWrapperObject*)value host:(id)host {
    if (self = [super init]) {
        self->_valueWrapper = Weak<NativeScript::ObjCWrapperObject>(value, weakHandleOwner(), self);
        self->_host = host;
        self->_associationKey = value->globalObject()->JSC::JSScope::vm();
    }

    return self;
}

- (NativeScript::ObjCWrapperObject*)value {
    return self->_valueWrapper.get();
}

- (void)detach {
    objc_setAssociatedObject(self->_host, self->_associationKey, nil, OBJC_ASSOCIATION_ASSIGN);
#if DEBUG_MEMORY
    NSLog(@"TNSValueWrapper detached from %@(%p)", object_getClass(self->_host), self->_host);
#endif
}

@end

namespace NativeScript {
static NSArray* toObject(ExecState* execState, JSArray* array) {
    MarkedArgumentBuffer buffer;
    array->fillArgList(execState, buffer);

    NSMutableArray* mutableArray = [NSMutableArray arrayWithCapacity:buffer.size()];
    for (size_t i = 0; i < buffer.size(); i++) {
        mutableArray[i] = toObject(execState, buffer.at(i));
    }

    return [mutableArray copy];
}

static NSData* toObject(ExecState* execState, ArrayBuffer* arrayBuffer) {
    return [NSData dataWithBytes:arrayBuffer->data()
                          length:arrayBuffer->byteLength()];
}

static NSData* toObject(ExecState* execState, JSArrayBuffer* arrayBuffer) {
    return toObject(execState, arrayBuffer->impl());
}

static NSData* toObject(ExecState* execState, JSArrayBufferView* arrayBufferView) {
    return toObject(execState, arrayBufferView->buffer());
}

id toObject(ExecState* execState, const JSValue& value) {
    if (value.inherits(ObjCWrapperObject::info())) {
        return jsCast<ObjCWrapperObject*>(value.asCell())->wrappedObject();
    }

    if (value.inherits(ObjCConstructorBase::info())) {
        return jsCast<ObjCConstructorBase*>(value.asCell())->klass();
    }

    if (value.isUndefinedOrNull()) {
        return nil;
    }

    if (value.isInt32()) {
        return @(value.toInt32(execState));
    }

    if (value.isUInt32()) {
        return @(value.toUInt32(execState));
    }

    if (value.isDouble()) {
        return @(value.asDouble());
    }

    if (value.isBoolean()) {
        return @((BOOL)value.asBoolean());
    }

    if (value.isString()) {
        return [NSString stringWithString:(NSString*)value.toString(execState)->value(execState).createCFString().get()];
    }

    if (value.inherits(JSArray::info())) {
        return toObject(execState, jsCast<JSArray*>(value.asCell()));
    }

    if (value.inherits(ObjCSuperObject::info())) {
        return jsCast<ObjCSuperObject*>(value.asCell())->wrapperObject()->wrappedObject();
    }

    if (value.inherits(JSArrayBuffer::info())) {
        return toObject(execState, jsCast<JSArrayBuffer*>(value.asCell()));
    }

    if (value.inherits(JSArrayBufferView::info())) {
        return toObject(execState, jsCast<JSArrayBufferView*>(value.asCell()));
    }

    RELEASE_ASSERT_NOT_REACHED();
}

JSValue toValue(ExecState* execState, id object, Class klass) {
    if (object == nil) {
        return jsNull();
    }

    if (object == [NSNull null]) {
        return jsNull();
    }

    if ([object isKindOfClass:[NSString class]]) {
        return jsString(execState, (CFStringRef)object);
    }

    if ([object isKindOfClass:[@YES class]]) {
        return jsBoolean([object boolValue]);
    }

    if ([object isKindOfClass:[NSNumber class]]) {
        return jsNumber([object doubleValue]);
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    if (class_isMetaClass(object_getClass(object))) {
        return globalObject->constructorFor(object_getClass(object), klass);
    }

    return toValue(execState, object, ^{ return globalObject->constructorFor(object_getClass(object), klass)->instancesStructure(); });
}

JSValue toValue(ExecState* execState, id object, Structure* (^structureResolver)()) {
    if (ObjCWrapperObject* wrapper = [static_cast<TNSValueWrapper*>(objc_getAssociatedObject(object, execState->scope()->vm())) value]) {
        return wrapper;
    }

    if (object == nil) {
        return jsNull();
    }

    ObjCWrapperObject* wrapper = ObjCWrapperObject::create(execState->vm(), structureResolver(), object);
    [TNSValueWrapper attachValue:wrapper
                          toHost:object];
    return wrapper;
}
}
