//
//  CFunctionWrapper.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 07.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "CFunctionWrapper.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo CFunctionWrapper::s_info = { "CFunctionWrapper", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(CFunctionWrapper) };

void CFunctionWrapper::finishCreation(VM& vm, void* functionPointer, const WTF::String& name, JSCell* returnType, const WTF::Vector<Strong<JSCell>>& parameterTypes, bool retainsReturnedCocoaObjects) {
    Base::finishCreation(vm, name);
    auto call = std::make_unique<CFunctionCall>(this, functionPointer, retainsReturnedCocoaObjects);
    call->initializeFFI(vm, { &preInvocation, &postInvocation }, returnType, parameterTypes);
    this->_functionsContainer.push_back(std::move(call));
    Base::initializeFunctionWrapper(vm, parameterTypes.size());
}

void CFunctionWrapper::preInvocation(FFICall* callee, ExecState*, FFICall::Invocation& invocation) {
    invocation.function = const_cast<void*>(static_cast<CFunctionCall*>(callee)->functionPointer());
}

void CFunctionWrapper::postInvocation(FFICall* callee, ExecState*, FFICall::Invocation& invocation) {
    CFunctionCall* call = static_cast<CFunctionCall*>(callee);
    if (call->retainsReturnedCocoaObjects()) {
        [invocation.getResult<id>() release];
    }
}
}
