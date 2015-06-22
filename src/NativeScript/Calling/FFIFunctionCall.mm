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

void FFIFunctionCall::finishCreation(VM& vm, const void* function, const WTF::String& name, JSCell* returnType, const WTF::Vector<JSCell*>& parameterTypes, bool retainsReturnedCocoaObjects) {
    Base::finishCreation(vm, name);
    this->_function = function;
    this->_retainsReturnedCocoaObjects = retainsReturnedCocoaObjects;
    Base::initializeFFI(vm, returnType, parameterTypes);
}

EncodedJSValue FFIFunctionCall::call(FFICallFrame& frame) {
    frame.setFunction(FFI_FN(_function));

    auto result = baseCall(frame);

    if (retainsReturnedCocoaObjects()) {
        id returnValue = *static_cast<id*>(frame.result());
        [returnValue release];
    }
    return result;
}

CallType FFIFunctionCall::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &executeCall;
    return CallTypeHost;
}
}