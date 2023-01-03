//
//  JSWeakRefPrototype.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 02.10.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "JSWeakRefPrototype.h"
#include "JSWeakRefInstance.h"

namespace NativeScript {
using namespace JSC;

static EncodedJSValue JSC_HOST_CALL weakRefProtoFuncGet(ExecState* execState);
static EncodedJSValue JSC_HOST_CALL weakRefProtoFuncClear(ExecState* execState);

const ClassInfo JSWeakRefPrototype::s_info = { "WeakRef", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(JSWeakRefPrototype) };

void JSWeakRefPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->get, 0, weakRefProtoFuncGet, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum));
    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->deref, 0, weakRefProtoFuncGet, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum));
    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->clear, 0, weakRefProtoFuncClear, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum));
}

static EncodedJSValue JSC_HOST_CALL weakRefProtoFuncGet(ExecState* execState) {
    VM& vm = execState->vm();
    JSC::JSValue thisValue = execState->thisValue();
    JSWeakRefInstance* self = jsDynamicCast<JSWeakRefInstance*>(vm, thisValue);
    if (!self) {
        auto scope = DECLARE_THROW_SCOPE(vm);
        return JSValue::encode(scope.throwException(execState, createError(execState, thisValue, "'this' is not weak reference"_s, defaultSourceAppender)));
    }

    JSCell* cell = self->cell();
    return JSValue::encode(cell ? JSValue(cell) : jsNull());
}

static EncodedJSValue JSC_HOST_CALL weakRefProtoFuncClear(ExecState* execState) {
    VM& vm = execState->vm();
    JSC::JSValue thisValue = execState->thisValue();
    JSWeakRefInstance* self = jsDynamicCast<JSWeakRefInstance*>(vm, thisValue);
    if (!self) {
        auto scope = DECLARE_THROW_SCOPE(vm);
        return JSValue::encode(scope.throwException(execState, createError(execState, thisValue, "'this' is not weak reference"_s, defaultSourceAppender)));
    }

    self->clear();
    return JSValue::encode(jsUndefined());
}
} // namespace NativeScript
