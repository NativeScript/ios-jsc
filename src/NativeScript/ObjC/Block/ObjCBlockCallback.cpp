//
//  ObjCBlockCallback.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/15/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCBlockCallback.h"
#include "FFICallbackInlines.h"
#include "ObjCBlockType.h"
#include "TypeFactory.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCBlockCallback::s_info = { "ObjCBlockCallback", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCBlockCallback) };

void ObjCBlockCallback::ffiClosureCallback(void* retValue, void** argValues, void* userData) {
    ObjCBlockCallback* blockCallback = reinterpret_cast<ObjCBlockCallback*>(userData);

    JSC::VM& vm = blockCallback->_globalExecState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    MarkedArgumentBuffer arguments;
    blockCallback->marshallArguments(argValues, arguments, blockCallback);
    if (scope.exception()) {
        return;
    }

    blockCallback->callFunction(blockCallback->_globalExecState->globalThisValue(), arguments, retValue);
}

void ObjCBlockCallback::finishCreation(VM& vm, JSGlobalObject* globalObject, JSCell* function, ObjCBlockType* blockType) {
    Base::finishCreation(vm, globalObject, function, blockType->returnType(), blockType->parameterTypes(), 1);
}
} // namespace NativeScript
