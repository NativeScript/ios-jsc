//
//  ObjCConstructorCall.mm
//  NativeScript
//
//  Created by Jason Zhekov on 10/6/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCConstructorCall.h"
#include "Metadata.h"
#include "ObjCConstructorBase.h"
#include "ObjCTypes.h"
#include "TypeFactory.h"
#include <objc/message.h>

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCConstructorWrapper::s_info = { "ObjCConstructorWrapper", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCConstructorWrapper) };

void ObjCConstructorWrapper::finishCreation(VM& vm, GlobalObject* globalObject, Class klass, const Metadata::MethodMeta* metadata) {
    Base::finishCreation(vm, metadata->jsName());

    const Metadata::TypeEncoding* encodings = metadata->encodings()->first();

    JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, encodings, false);
    const WTF::Vector<JSCell*> parametersTypes = globalObject->typeFactory()->parseTypes(globalObject, encodings, metadata->encodings()->count - 1, false);

    std::unique_ptr<ObjCConstructorCall> call(new ObjCConstructorCall(this));
    call->initializeFFI(vm, { &preInvocation, &postInvocation }, returnType, parametersTypes, 2);
    call->_klass = klass;

    Base::initializeFunctionWrapper(vm, parametersTypes.size());
    call->_selector = metadata->selector();
    this->_functionsContainer.push_back(std::move(call));
}

void ObjCConstructorWrapper::preInvocation(FFICall* callee, ExecState*, FFICall::Invocation& invocation) {
    ObjCConstructorCall* call = static_cast<ObjCConstructorCall*>(callee);
    invocation.setArgument(0, [call->_klass alloc]);
    invocation.setArgument(1, call->selector());
    invocation.function = reinterpret_cast<void*>(&objc_msgSend);
}

void ObjCConstructorWrapper::postInvocation(FFICall* callee, ExecState*, FFICall::Invocation& invocation) {
    [invocation.getResult<id>() release];
}

bool ObjCConstructorWrapper::canInvoke(ExecState* execState) const {
    if (execState->argumentCount() != this->onlyFuncInContainer()->parameterTypes().size()) {
        return false;
    }

    for (size_t i = 0; i < this->onlyFuncInContainer()->parameterTypes().size(); ++i) {
        auto& paramType = this->onlyFuncInContainer()->parameterTypes()[i];
        if (!paramType.canConvert(execState, execState->uncheckedArgument(i), onlyFuncInContainer()->parameterTypesCells()[i].get())) {
            return false;
        }
    }

    return true;
}
}
