//
//  FFICallPrototype.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 25.09.15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "FFICallPrototype.h"
#include "FFICall.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo FFICallPrototype::s_info = { "FFIFunction", &Base::s_info, 0, CREATE_METHOD_TABLE(FFICallPrototype) };

EncodedJSValue JSC_HOST_CALL FFICallPrototypeFuncAsync(ExecState*);

void FFICallPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);
    vm.prototypeMap.addPrototype(this);

    JSC_NATIVE_FUNCTION(Identifier::fromString(&vm, "async"), FFICallPrototypeFuncAsync, DontEnum, 0);
}

EncodedJSValue JSC_HOST_CALL FFICallPrototypeFuncAsync(ExecState* execState) {
    auto call = jsCast<FFICall*>(execState->thisValue());

    JSValue array = execState->argument(1);

    MarkedArgumentBuffer applyArgs;
    if (!array.isUndefinedOrNull()) {
        if (!array.isObject())
            return throwVMTypeError(execState);
        if (isJSArray(array)) {
            if (asArray(array)->length() > JSC::maxArguments)
                return JSValue::encode(throwStackOverflowError(execState));
            asArray(array)->fillArgList(execState, applyArgs);
        } else {
            unsigned length = asObject(array)->get(execState, execState->propertyNames().length).toUInt32(execState);
            if (length > JSC::maxArguments)
                return JSValue::encode(throwStackOverflowError(execState));

            for (unsigned i = 0; i < length; ++i)
                applyArgs.append(asObject(array)->get(execState, i));
        }
    }

    return JSValue::encode(call->async(execState, execState->argument(0), applyArgs));
}
}