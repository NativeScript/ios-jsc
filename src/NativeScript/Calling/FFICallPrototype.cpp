//
//  FFICallPrototype.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 25.09.15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "FFICallPrototype.h"
#include "FFICall.h"
#include "FunctionWrapper.h"
#include <JavaScriptCore/Interpreter.h>
#include <JavaScriptCore/interpreter/Interpreter.h>

namespace NativeScript {
using namespace JSC;

const ClassInfo FFICallPrototype::s_info = { "FFIFunction", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(FFICallPrototype) };

EncodedJSValue JSC_HOST_CALL FFICallPrototypeFuncAsync(ExecState*);

void FFICallPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);
    didBecomePrototype();

    JSC_NATIVE_FUNCTION(Identifier::fromString(&vm, "async"), FFICallPrototypeFuncAsync, static_cast<unsigned>(PropertyAttribute::DontEnum), 0);
}

EncodedJSValue JSC_HOST_CALL FFICallPrototypeFuncAsync(ExecState* execState) {
    auto call = jsCast<FunctionWrapper*>(execState->thisValue());
    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    JSValue array = execState->argument(1);

    MarkedArgumentBuffer applyArgs;
    if (!array.isUndefinedOrNull()) {
        if (!array.isObject())
            return throwVMTypeError(execState, scope);
        if (isJSArray(array)) {
            if (asArray(array)->length() > JSC::maxArguments)
                return JSValue::encode(throwStackOverflowError(execState, scope));
            asArray(array)->fillArgList(execState, applyArgs);
        } else {
            unsigned length = asObject(array)->get(execState, vm.propertyNames->length).toUInt32(execState);
            if (length > JSC::maxArguments)
                return JSValue::encode(throwStackOverflowError(execState, scope));

            for (unsigned i = 0; i < length; ++i)
                applyArgs.append(asObject(array)->get(execState, i));
        }
    }

    return JSValue::encode(call->async(execState, execState->argument(0), applyArgs));
}
} // namespace NativeScript
