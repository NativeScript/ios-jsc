//
//  TNSDictionaryAdapter.m
//  NativeScript
//
//  Created by Yavor Georgiev on 28.03.15.
//  Copyright (c) 2015 г. Telerik. All rights reserved.
//

#import "TNSDictionaryAdapter.h"
#include "Interop.h"
#include "ObjCTypes.h"
#include "TNSRuntime+Private.h"
#include <JavaScriptCore/JSMap.h>
#include <JavaScriptCore/JSMapIterator.h>

using namespace JSC;
using namespace NativeScript;

@interface TNSDictionaryAdapterMapKeysEnumerator : NSEnumerator

@end

@implementation TNSDictionaryAdapterMapKeysEnumerator {
    Strong<JSMapIterator> _iterator;
    ExecState* _execState;
}

- (instancetype)initWithMap:(JSMap*)map execState:(ExecState*)execState {
    if (self) {
        _iterator.set(execState->vm(), JSMapIterator::create(execState->vm(), execState->vm().mapIteratorStructure.get(), map, JSC::IterateKey));
        self->_execState = execState;
    }

    return self;
}

- (id)nextObject {
    JSLockHolder lock(self->_execState);

    JSValue key, value;
    if (_iterator->nextKeyValue(self->_execState, key, value)) {
        return toObject(_execState, key);
    }

    return nil;
}

@end

@interface TNSDictionaryAdapterObjectKeysEnumerator : NSEnumerator

@end

@implementation TNSDictionaryAdapterObjectKeysEnumerator {
    RefPtr<PropertyNameArrayData> _properties;
    NSUInteger _index;
}

- (instancetype)initWithProperties:(RefPtr<PropertyNameArrayData>&&)properties {
    if (self) {
        self->_properties = properties.get();
        self->_index = 0;
    }

    return self;
}

- (id)nextObject {
    if (self->_index < self->_properties->propertyNameVector().size()) {
        Identifier& identifier = self->_properties->propertyNameVector().at(self->_index);
        self->_index++;
        return reinterpret_cast<const NSString*>(identifier.string().createCFString().autorelease());
    }

    return nil;
}

- (NSArray*)allObjects {
    NSMutableArray* array = [NSMutableArray array];
    for (Identifier& identifier : self->_properties->propertyNameVector()) {
        [array addObject:reinterpret_cast<const NSString*>(identifier.string().createCFString().autorelease())];
    }

    return array;
}

@end

@implementation TNSDictionaryAdapter {
    Strong<JSObject> _object;
    ExecState* _execState;
    VM* _vm;
}

- (instancetype)initWithJSObject:(JSObject*)jsObject execState:(ExecState*)execState {
    if (self) {
        self->_object = Strong<JSObject>(execState->vm(), jsObject);
        self->_execState = execState;
        self->_vm = &execState->vm();
        [TNSRuntime runtimeForVM:self->_vm] -> _objectMap.get()->set(self, jsObject);
    }

    return self;
}

- (NSUInteger)count {
    JSLockHolder lock(self->_execState);

    JSObject* object = self->_object.get();
    if (JSMap* map = jsDynamicCast<JSMap*>(self->_execState->vm(), object)) {
        return map->size();
    }

    PropertyNameArray properties(&self->_execState->vm(), PropertyNameMode::Strings, PrivateSymbolMode::Include);
    object->methodTable(*self->_vm)->getOwnPropertyNames(object, self->_execState, properties, EnumerationMode());
    return properties.size();
}

- (id)objectForKey:(id)aKey {
    RELEASE_ASSERT_WITH_MESSAGE([TNSRuntime runtimeForVM:self->_vm], "The runtime is deallocated.");
    JSLockHolder lock(self->_execState);

    JSObject* object = self->_object.get();
    if (JSMap* map = jsDynamicCast<JSMap*>(self->_execState->vm(), object)) {
        JSValue key = toValue(self->_execState, aKey);
        return toObject(self->_execState, map->get(self->_execState, key));
    } else if ([aKey isKindOfClass:[NSString class]]) {
        Identifier key{ Identifier::fromString(self->_execState, WTF::String(reinterpret_cast<CFStringRef>(aKey))) };
        return toObject(self->_execState, object->get(self->_execState, key));
    } else if ([aKey isKindOfClass:[NSNumber class]]) {
        NSUInteger key = [aKey unsignedIntegerValue];
        return toObject(self->_execState, object->get(self->_execState, key));
    }

    return nil;
}

- (NSEnumerator*)keyEnumerator {
    RELEASE_ASSERT_WITH_MESSAGE([TNSRuntime runtimeForVM:self->_vm], "The runtime is deallocated.");
    JSLockHolder lock(self->_execState);

    JSObject* object = self->_object.get();
    if (JSMap* map = jsDynamicCast<JSMap*>(self->_execState->vm(), object)) {
        return [[[TNSDictionaryAdapterMapKeysEnumerator alloc] initWithMap:map execState:self->_execState] autorelease];
    }

    PropertyNameArray properties(&self->_execState->vm(), PropertyNameMode::Strings, PrivateSymbolMode::Include);
    object->methodTable(*self->_vm)->getOwnPropertyNames(object, self->_execState, properties, EnumerationMode());
    return [[[TNSDictionaryAdapterObjectKeysEnumerator alloc] initWithProperties:properties.releaseData()] autorelease];
}

- (void)dealloc {
    {
        if (TNSRuntime* runtime = [TNSRuntime runtimeForVM:self->_vm]) {
            JSLockHolder lock(self->_execState);
            runtime->_objectMap.get()->remove(self);
        }
    }

    [super dealloc];
}

@end
