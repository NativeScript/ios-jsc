//
//  TNSDataAdapter.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 20.07.15.
//
//

#import "TNSDataAdapter.h"
#include "ObjCTypes.h"
#include "JSErrors.h"
#include <JavaScriptCore/JSArrayBuffer.h>
#include <JavaScriptCore/StrongInlines.h>

using namespace NativeScript;
using namespace JSC;

@implementation TNSDataAdapter {
    Strong<JSObject> _object;
    ExecState* _execState;
}

- (instancetype)initWithJSObject:(JSObject*)jsObject execState:(ExecState*)execState {
    if (self) {
        self->_object.set(execState->vm(), jsObject);
        self->_execState = execState;
        [TNSValueWrapper attachValue:jsObject toHost:self];
    }

    return self;
}

- (const void*)bytes {
    return [self mutableBytes];
}

- (void*)mutableBytes {
    JSLockHolder lock(self->_execState);

    if (JSArrayBuffer* arrayBuffer = jsDynamicCast<JSArrayBuffer*>(self->_object.get())) {
        return arrayBuffer->impl()->data();
    }

    JSArrayBufferView* arrayBufferView = jsCast<JSArrayBufferView*>(self->_object.get());
    if (arrayBufferView->hasArrayBuffer()) {
        return arrayBufferView->buffer()->data();
    }

    return arrayBufferView->vector();
}

- (NSUInteger)length {
    JSLockHolder lock(self->_execState);
    NSUInteger length = self->_object->get(self->_execState, self->_execState->propertyNames().byteLength).toUInt32(self->_execState);
    reportErrorIfAny(self->_execState);
    return length;
}

@end
