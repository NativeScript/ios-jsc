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
    JSGlobalObject* _globalObject;
}

- (instancetype)initWithMap:(JSMap*)map execState:(ExecState*)execState {
    if (self) {
        self->_globalObject = execState->lexicalGlobalObject();
        VM& vm = execState->vm();
        _iterator.set(vm, JSMapIterator::create(vm, vm.mapIteratorStructure(), map, JSC::IterateKey));
    }

    return self;
}

- (id)nextObject {
    JSLockHolder lock(self->_globalObject->vm());

    JSValue key, value;
    ExecState* exec = self->_globalObject->globalExec();
    if (_iterator->nextKeyValue(exec, key, value)) {
        return toObject(exec, key);
    }

    return nil;
}

- (void)dealloc {
    {
        VM& vm = self->_globalObject->vm();
        JSLockHolder lock(vm);
        if (TNSRuntime* runtime = [TNSRuntime runtimeForVM:&vm]) {
            runtime->_objectMap.get()->remove(self);
        }
        // Clear Strong reference inside the locked section. Otherwise it would be done when the
        // C++ members' destructros are run. This races with other threads and can corrupt the VM's heap.
        self->_iterator.clear();
    }

    [super dealloc];
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
    JSGlobalObject* _globalObject;
    RefPtr<VM> _vm;
}

- (instancetype)initWithJSObject:(JSObject*)jsObject execState:(ExecState*)execState {
    if (self) {
        self->_object = Strong<JSObject>(execState->vm(), jsObject);
        self->_globalObject = execState->lexicalGlobalObject();
        self->_vm = &execState->vm();
        auto runtime = [TNSRuntime runtimeForVM:self->_vm.get()];
        RELEASE_ASSERT_WITH_MESSAGE(runtime, "The runtime is deallocated.");
        runtime->_objectMap.get()->set(self, jsObject);
    }

    return self;
}

- (NSUInteger)count {
    JSLockHolder lock(self->_vm.get());

    JSObject* object = self->_object.get();
    if (JSMap* map = jsDynamicCast<JSMap*>(*self->_vm, object)) {
        return map->size();
    }

    PropertyNameArray properties(self->_vm.get(), PropertyNameMode::Strings, PrivateSymbolMode::Include);
    object->methodTable(*self->_vm)->getOwnPropertyNames(object, self->_globalObject->globalExec(), properties, EnumerationMode());
    return properties.size();
}

- (id)objectForKey:(id)aKey {
    RELEASE_ASSERT_WITH_MESSAGE([TNSRuntime runtimeForVM:self->_vm.get()], "The runtime is deallocated.");
    JSLockHolder lock(self->_vm.get());

    JSObject* object = self->_object.get();
    if (JSMap* map = jsDynamicCast<JSMap*>(*self->_vm.get(), object)) {
        JSValue key = toValue(self->_globalObject->globalExec(), aKey);
        return toObject(self->_globalObject->globalExec(), map->get(self->_globalObject->globalExec(), key));
    } else if ([aKey isKindOfClass:[NSString class]]) {
        Identifier key{ Identifier::fromString(_globalObject->globalExec(), WTF::String(reinterpret_cast<CFStringRef>(aKey))) };
        return toObject(_globalObject->globalExec(), object->get(self->_globalObject->globalExec(), key));
    } else if ([aKey isKindOfClass:[NSNumber class]]) {
        NSUInteger key = [aKey unsignedIntegerValue];
        return toObject(self->_globalObject->globalExec(), object->get(self->_globalObject->globalExec(), key));
    }

    return nil;
}

- (NSEnumerator*)keyEnumerator {
    RELEASE_ASSERT_WITH_MESSAGE([TNSRuntime runtimeForVM:self->_vm.get()], "The runtime is deallocated.");
    JSLockHolder lock(self->_globalObject->globalExec());

    JSObject* object = self->_object.get();
    if (JSMap* map = jsDynamicCast<JSMap*>(*self->_vm.get(), object)) {
        return [[[TNSDictionaryAdapterMapKeysEnumerator alloc] initWithMap:map execState:self->_globalObject->globalExec()] autorelease];
    }

    PropertyNameArray properties(self->_vm.get(), PropertyNameMode::Strings, PrivateSymbolMode::Include);
    object->methodTable(*self->_vm.get())->getOwnPropertyNames(object, self->_globalObject->globalExec(), properties, EnumerationMode());
    return [[[TNSDictionaryAdapterObjectKeysEnumerator alloc] initWithProperties:properties.releaseData()] autorelease];
}

- (void)dealloc {
    {
        JSLockHolder lock(self->_vm.get());
        if (TNSRuntime* runtime = [TNSRuntime runtimeForVM:self->_vm.get()]) {
            runtime->_objectMap.get()->remove(self);
        }
        // Clear Strong reference inside the locked section. Otherwise it would be done when the
        // C++ members' destructros are run. This races with other threads and can corrupt the VM's heap.
        self->_object.clear();
    }

    [super dealloc];
}

@end
