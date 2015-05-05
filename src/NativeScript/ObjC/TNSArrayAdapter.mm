//
//  TNSArrayAdapter.m
//  NativeScript
//
//  Created by Yavor Georgiev on 27.03.15.
//  Copyright (c) 2015 г. Telerik. All rights reserved.
//

#import "TNSArrayAdapter.h"
#include "ObjCTypes.h"
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
        [TNSValueWrapper attachValue:jsObject toHost:self];
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
    JSLockHolder lock(self->_execState);

    return toObject(self->_execState, self->_object.get()->get(self->_execState, index));
}

@end
