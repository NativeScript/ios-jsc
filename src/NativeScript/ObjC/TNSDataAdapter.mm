//
//  TNSDataAdapter.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 20.07.15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import "TNSDataAdapter.h"
#include "Interop.h"
#include "JSErrors.h"
#include "TNSRuntime+Private.h"
#include <JavaScriptCore/JSArrayBuffer.h>

using namespace NativeScript;
using namespace JSC;

@implementation TNSDataAdapter {
    Strong<JSObject> _object;
    JSGlobalObject* _globalObject;
    RefPtr<VM> _vm;
}

- (instancetype)initWithJSObject:(JSObject*)jsObject execState:(ExecState*)execState {
    if (self) {
        self->_vm = &execState->vm();
        self->_object.set(*self->_vm.get(), jsObject);
        self->_globalObject = execState->lexicalGlobalObject();
        auto runtime = [TNSRuntime runtimeForVM:self->_vm.get()];
        RELEASE_ASSERT_WITH_MESSAGE(runtime, "The runtime is deallocated.");
        runtime->_objectMap.get()->set(self, jsObject);
    }

    return self;
}

- (const void*)bytes {
    return [self mutableBytes];
}

- (void*)mutableBytes {
    VM& vm = *self->_vm.get();
    RELEASE_ASSERT_WITH_MESSAGE([TNSRuntime runtimeForVM:&vm], "The runtime is deallocated.");
    JSLockHolder lock(vm);

    if (JSArrayBuffer* arrayBuffer = jsDynamicCast<JSArrayBuffer*>(vm, self->_object.get())) {
        return arrayBuffer->impl()->data();
    }

    JSArrayBufferView* arrayBufferView = jsCast<JSArrayBufferView*>(self->_object.get());
    if (arrayBufferView->hasArrayBuffer()) {
        return arrayBufferView->unsharedBuffer()->data();
    }

    return arrayBufferView->vector();
}

- (NSUInteger)length {
    VM& vm = *self->_vm.get();
    ExecState* execState = self->_globalObject->globalExec();
    RELEASE_ASSERT_WITH_MESSAGE([TNSRuntime runtimeForVM:&vm], "The runtime is deallocated.");
    JSLockHolder lock(vm);
    auto scope = DECLARE_CATCH_SCOPE(vm);
    NSUInteger length = self->_object->get(execState, vm.propertyNames->byteLength).toUInt32(execState);
    reportErrorIfAny(execState, scope);
    return length;
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
