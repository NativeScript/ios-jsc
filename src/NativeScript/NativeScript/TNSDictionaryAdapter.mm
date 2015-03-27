//
//  TNSDictionaryAdapter.m
//  NativeScript
//
//  Created by Yavor Georgiev on 28.03.15.
//  Copyright (c) 2015 г. Telerik. All rights reserved.
//

#import "TNSDictionaryAdapter.h"
#include "ObjCTypes.h"
#include <JavaScriptCore/JSMap.h>
#include <JavaScriptCore/MapData.h>
#include <JavaScriptCore/StrongInlines.h>

using namespace JSC;
using namespace NativeScript;

@interface TNSDictionaryAdapterMapKeysEnumerator : NSEnumerator

@end

@implementation TNSDictionaryAdapterMapKeysEnumerator {
    Strong<MapData> _mapData;
    ExecState* _execState;
    std::unique_ptr<MapData::const_iterator> _it;
}

- (instancetype)initWithMapData:(MapData*)mapData execState:(ExecState*)execState {
    if (self) {
        self->_mapData = Strong<MapData>(execState->vm(), mapData);
        self->_execState = execState;
        self->_it = std::make_unique<MapData::const_iterator>(mapData);
    }

    return self;
}

- (id)nextObject {
    JSLockHolder lock(self->_execState);

    if (*self->_it != self->_mapData->end()) {
        id object = toObject(self->_execState, self->_it->key());
        self->_it->operator++();
        return object;
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

- (instancetype)initWithProperties:(PassRefPtr<PropertyNameArrayData>)properties {
    if (self) {
        self->_properties = properties;
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

- (NSArray *)allObjects {
    NSMutableArray *array = [NSMutableArray array];
    for (Identifier& identifier : self->_properties->propertyNameVector()) {
        [array addObject:reinterpret_cast<const NSString*>(identifier.string().createCFString().autorelease())];
    }

    return array;
}

@end

@implementation TNSDictionaryAdapter {
    Strong<JSObject> _object;
    ExecState* _execState;
}

- (instancetype)initWithJSObject:(JSObject*)jsObject execState:(ExecState*)execState {
    if (self) {
        self->_object = Strong<JSObject>(execState->vm(), jsObject);
        self->_execState = execState;
        [TNSValueWrapper attachValue:jsObject toHost:self];
    }

    return self;
}

- (NSUInteger)count {
    JSLockHolder lock(self->_execState);

    JSObject* object = self->_object.get();
    if (JSMap* map = jsDynamicCast<JSMap*>(object)) {
        return map->mapData()->size(self->_execState);
    }

    PropertyNameArray properties(self->_execState);
    object->methodTable()->getOwnPropertyNames(object, self->_execState, properties, ExcludeDontEnumProperties);
    return properties.size();
}

- (id)objectForKey:(id)aKey {
    JSLockHolder lock(self->_execState);

    JSObject* object = self->_object.get();
    if (JSMap* map = jsDynamicCast<JSMap*>(object)) {
        JSValue key = toValue(self->_execState, aKey);
        return toObject(self->_execState, map->mapData()->get(self->_execState, key));
    } else if ([aKey isKindOfClass:[NSString class]]) {
        Identifier key(self->_execState, reinterpret_cast<CFStringRef>(aKey));
        return toObject(self->_execState, object->get(self->_execState, key));
    } else if ([aKey isKindOfClass:[NSNumber class]]) {
        NSUInteger key = [aKey unsignedIntegerValue];
        return toObject(self->_execState, object->get(self->_execState, key));
    }

    return nil;
}

-(NSEnumerator *)keyEnumerator {
    JSObject* object = self->_object.get();
    if (JSMap* map = jsDynamicCast<JSMap*>(object)) {
        return [[[TNSDictionaryAdapterMapKeysEnumerator alloc] initWithMapData:map->mapData() execState:self->_execState] autorelease];
    }

    PropertyNameArray properties(self->_execState);
    object->methodTable()->getOwnPropertyNames(object, self->_execState, properties, ExcludeDontEnumProperties);
    return [[[TNSDictionaryAdapterObjectKeysEnumerator alloc] initWithProperties:properties.releaseData()] autorelease];
}

@end
