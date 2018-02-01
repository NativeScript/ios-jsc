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

const ClassInfo FFIFunctionCall::s_info = { "FFIFunctionCall", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(FFIFunctionCall) };

void FFIFunctionCall::finishCreation(VM& vm, const void* functionPointer, const WTF::String& name, JSCell* returnType, const WTF::Vector<JSCell*>& parameterTypes, bool retainsReturnedCocoaObjects) {
    Base::finishCreation(vm, name);
    this->_functionPointer = functionPointer;
    this->_retainsReturnedCocoaObjects = retainsReturnedCocoaObjects;
    Base::initializeFFI(vm, { &preInvocation, &postInvocation }, returnType, parameterTypes);
}

void FFIFunctionCall::preInvocation(FFICall* callee, ExecState*, FFICall::Invocation& invocation) {
    invocation.function = const_cast<void*>(jsCast<FFIFunctionCall*>(callee)->functionPointer());
}

void FFIFunctionCall::postInvocation(FFICall* callee, ExecState*, FFICall::Invocation& invocation) {
    FFIFunctionCall* call = jsCast<FFIFunctionCall*>(callee);
    if (call->retainsReturnedCocoaObjects()) {
        [invocation.getResult<id>() release];
    }
}
}
