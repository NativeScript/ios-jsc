//
//  FFIFunctionCallback.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 15.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "FFIFunctionCallback.h"
#include "FFICallbackInlines.h"
#include "FunctionReferenceTypeInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo FFIFunctionCallback::s_info = { "FFIFunctionCallback", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(FFIFunctionCallback) };

void FFIFunctionCallback::ffiClosureCallback(void* retValue, void** argValues, void* userData) {
    FFIFunctionCallback* functionCallback = reinterpret_cast<FFIFunctionCallback*>(userData);

    JSC::VM& vm = functionCallback->execState()->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    MarkedArgumentBuffer arguments;
    functionCallback->marshallArguments(argValues, arguments, functionCallback);
    if (scope.exception()) {
        return;
    }

    ASSERT(!arguments.hasOverflowed());
    functionCallback->callFunction(functionCallback->execState()->globalThisValue(), arguments, retValue);
}

void FFIFunctionCallback::finishCreation(VM& vm, JSGlobalObject* globalObject, JSCell* function, FunctionReferenceTypeInstance* functionReferenceType) {
    Base::finishCreation(vm, globalObject, function, functionReferenceType->returnType(), functionReferenceType->parameterTypes(vm));
}
} // namespace NativeScript
