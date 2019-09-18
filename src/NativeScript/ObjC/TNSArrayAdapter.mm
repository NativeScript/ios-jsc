//
//  TNSArrayAdapter.m
//  NativeScript
//
//  Created by Yavor Georgiev on 27.03.15.
//  Copyright (c) 2015 г. Telerik. All rights reserved.
//

#import "TNSArrayAdapter.h"
#include "Interop.h"
#include "ObjCTypes.h"
#include "TNSRuntime+Private.h"

using namespace NativeScript;
using namespace JSC;

@implementation TNSArrayAdapter {
    Strong<JSObject> _object;
    JSGlobalObject* _globalObject;
}

- (instancetype)initWithJSObject:(JSObject*)jsObject execState:(ExecState*)execState {
    if (self) {
        self->_object = Strong<JSObject>(execState->vm(), jsObject);
        self->_globalObject = execState->lexicalGlobalObject();
        VM& vm = execState->vm();
        auto runtime = [TNSRuntime runtimeForVM:&vm];
        RELEASE_ASSERT_WITH_MESSAGE(runtime, "The runtime is deallocated.");
        runtime->_objectMap.get()->set(self, jsObject);
    }

    return self;
}

- (NSUInteger)count {
    VM& vm = self->_globalObject->vm();
    RELEASE_ASSERT_WITH_MESSAGE([TNSRuntime runtimeForVM:&vm], "The runtime is deallocated.");
    JSLockHolder lock(vm);

    JSObject* object = self->_object.get();
    if (JSArray* array = jsDynamicCast<JSArray*>(vm, object)) {
        return array->length();
    }
    ExecState* execState = self->_globalObject->globalExec();
    return object->get(execState, vm.propertyNames->length).toUInt32(execState);
}

- (id)objectAtIndex:(NSUInteger)index {
    VM& vm = self->_globalObject->vm();
    RELEASE_ASSERT_WITH_MESSAGE([TNSRuntime runtimeForVM:&vm], "The runtime is deallocated.");
    if (!(index < [self count])) {
        @throw [NSException exceptionWithName:NSRangeException reason:[NSString stringWithFormat:@"Index (%tu) out of bounds", index] userInfo:nil];
    }

    JSLockHolder lock(vm);
    ExecState* execState = self->_globalObject->globalExec();
    return toObject(execState, self->_object.get()->get(execState, index));
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id[])buffer count:(NSUInteger)len {
    VM& vm = self->_globalObject->vm();
    RELEASE_ASSERT_WITH_MESSAGE([TNSRuntime runtimeForVM:&vm], "The runtime is deallocated.");

    JSLockHolder lock(vm);
    ExecState* execState = self->_globalObject->globalExec();

    if (state->state == 0) { // uninitialized
        state->state = 1;
        state->mutationsPtr = reinterpret_cast<unsigned long*>(self);
        state->extra[0] = 0; // current index
        state->extra[1] = self->_object->get(execState, vm.propertyNames->length).toUInt32(execState);
    }

    NSUInteger currentIndex = state->extra[0];
    unsigned int length = state->extra[1];
    NSUInteger count = 0;
    state->itemsPtr = buffer;

    while (count < len && currentIndex < length) {
        *buffer++ = toObject(execState, self->_object->get(execState, currentIndex));
        currentIndex++;
        count++;
    }

    state->extra[0] = currentIndex;

    return count;
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
        self->_object.clear();
    }

    [super dealloc];
}

@end
