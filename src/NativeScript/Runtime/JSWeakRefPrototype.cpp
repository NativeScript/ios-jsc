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

const ClassInfo JSWeakRefPrototype::s_info = { "WeakRef", &Base::s_info, 0, CREATE_METHOD_TABLE(JSWeakRefPrototype) };

void JSWeakRefPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->get, 0, weakRefProtoFuncGet, NoIntrinsic, DontEnum);
    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->clear, 0, weakRefProtoFuncClear, NoIntrinsic, DontEnum);
}

static EncodedJSValue JSC_HOST_CALL weakRefProtoFuncGet(ExecState* execState) {
    JSWeakRefInstance* self = jsDynamicCast<JSWeakRefInstance*>(execState->thisValue());
    if (!self) {
        return JSValue::encode(execState->vm().throwException(execState, createTypeError(execState, WTF::ASCIILiteral("'this' is not weak reference"))));
    }

    JSCell* cell = self->cell();
    return JSValue::encode(cell ? JSValue(cell) : jsNull());
}

static EncodedJSValue JSC_HOST_CALL weakRefProtoFuncClear(ExecState* execState) {
    JSWeakRefInstance* self = jsDynamicCast<JSWeakRefInstance*>(execState->thisValue());
    if (!self) {
        return JSValue::encode(execState->vm().throwException(execState, createTypeError(execState, WTF::ASCIILiteral("'this' is not weak reference"))));
    }

    self->clear();
    return JSValue::encode(jsUndefined());
}
}