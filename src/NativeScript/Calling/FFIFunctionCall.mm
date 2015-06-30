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

const ClassInfo FFIFunctionCall::s_info = { "FFIFunctionCall", &Base::s_info, 0, CREATE_METHOD_TABLE(FFIFunctionCall) };

void FFIFunctionCall::finishCreation(VM& vm, const void* functionPointer, const WTF::String& name, JSCell* returnType, const WTF::Vector<JSCell*>& parameterTypes, bool retainsReturnedCocoaObjects) {
    Base::finishCreation(vm, name);
    this->_functionPointer = functionPointer;
    this->_retainsReturnedCocoaObjects = retainsReturnedCocoaObjects;
    Base::initializeFFI(vm, returnType, parameterTypes);
}

EncodedJSValue FFIFunctionCall::derivedExecuteCall(ExecState* execState, uint8_t* buffer) {
    this->executeFFICall(execState, buffer, FFI_FN(this->_functionPointer));

    JSValue result = this->postCall(execState, buffer);
    if (this->retainsReturnedCocoaObjects()) {
        id returnValue = *static_cast<id*>(this->getReturn(buffer));
        [returnValue release];
    }

    return JSValue::encode(result);
}

CallType FFIFunctionCall::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &Base::executeCall<FFIFunctionCall>;
    return CallTypeHost;
}
}