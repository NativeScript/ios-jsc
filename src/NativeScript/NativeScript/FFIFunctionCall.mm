//
//  FFIFunctionCall.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 07.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "FFIFunctionCall.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

const ClassInfo FFIFunctionCall::s_info = { "FFIFunctionCall", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(FFIFunctionCall) };

void FFIFunctionCall::finishCreation(VM& vm, const void* functionPointer, const WTF::String& name, JSCell* returnType, const WTF::Vector<JSCell*>& parameterTypes, bool retainsReturnedCocoaObjects) {
    Base::finishCreation(vm, name);
    this->_functionPointer = functionPointer;
    this->_retainsReturnedCocoaObjects = retainsReturnedCocoaObjects;
    Base::initializeFFI(vm, returnType, parameterTypes);
}

EncodedJSValue FFIFunctionCall::executeCall(ExecState* execState) {
    FFIFunctionCall* self = jsCast<FFIFunctionCall*>(execState->callee());

    self->preCall(execState);
    if (execState->hadException()) {
        return JSValue::encode(jsUndefined());
    }

    self->executeFFICall(FFI_FN(self->_functionPointer));

    JSValue result = self->postCall(execState);
    if (self->retainsReturnedCocoaObjects()) {
        id returnValue = *static_cast<id*>(self->getReturn());
        [returnValue release];
    }
    return JSValue::encode(result);
}

CallType FFIFunctionCall::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &executeCall;
    return CallTypeHost;
}
}