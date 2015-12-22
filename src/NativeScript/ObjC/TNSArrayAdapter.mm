//
//  TNSArrayAdapter.m
//  NativeScript
//
//  Created by Yavor Georgiev on 27.03.15.
//  Copyright (c) 2015 г. Telerik. All rights reserved.
//

#import "TNSArrayAdapter.h"
#include "ObjCTypes.h"
#include "Interop.h"
#include <JavaScriptCore/StrongInlines.h>

using namespace NativeScript;
using namespace JSC;

@implementation TNSArrayAdapter {
    Strong<JSObject> _object;
    ExecState* _execState;
}

- (instancetype)initWithJSObject:(JSObject*)jsObject execState:(ExecState*)execState {
    if (self) {
        self->_object = Strong<JSObject>(execState->vm(), jsObject);
        self->_execState = execState;
        interop(execState)->objectMap().set(self, jsObject);
    }

    return self;
}

- (NSUInteger)count {
    JSLockHolder lock(self->_execState);

    JSObject* object = self->_object.get();
    if (JSArray* array = jsDynamicCast<JSArray*>(object)) {
        return array->length();
    }

    return object->get(self->_execState, self->_execState->propertyNames().length).toUInt32(self->_execState);
}

- (id)objectAtIndex:(NSUInteger)index {
    if (!(index < [self count])) {
        @throw [NSException exceptionWithName:NSRangeException reason:[NSString stringWithFormat:@"Index (%tu) out of bounds", index] userInfo:nil];
    }

    JSLockHolder lock(self->_execState);
    return toObject(self->_execState, self->_object.get()->get(self->_execState, index));
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(id[])buffer count:(NSUInteger)len {
    if (state->state == 0) { // uninitialized
        state->state = 1;
        state->mutationsPtr = reinterpret_cast<unsigned long*>(self);
        state->extra[0] = 0; // current index
        state->extra[1] = self->_object->get(self->_execState, self->_execState->propertyNames().length).toUInt32(self->_execState);
    }

    NSUInteger currentIndex = state->extra[0];
    unsigned int length = state->extra[1];
    NSUInteger count = 0;
    state->itemsPtr = buffer;

    JSLockHolder lock(self->_execState);
    while (count < len && currentIndex < length) {
        *buffer++ = toObject(self->_execState, self->_object->get(self->_execState, currentIndex));
        currentIndex++;
        count++;
    }

    state->extra[0] = currentIndex;

    return count;
}

- (void)dealloc {
    {
        JSLockHolder lock(self->_execState);
        interop(self->_execState)->objectMap().remove(self);
    }

    [super dealloc];
}

@end
