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

const ClassInfo ObjCConstructorCall::s_info = { "ObjCConstructorCall", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCConstructorCall) };

void ObjCConstructorCall::finishCreation(VM& vm, GlobalObject* globalObject, Class klass, const Metadata::MethodMeta* metadata) {
    Base::finishCreation(vm, metadata->jsName());
    this->_klass = klass;

    const Metadata::TypeEncoding* encodings = metadata->encodings()->first();

    JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, encodings);
    const WTF::Vector<JSCell*> parametersTypes = globalObject->typeFactory()->parseTypes(globalObject, encodings, metadata->encodings()->count - 1);

    Base::initializeFFI(vm, { &preInvocation, &postInvocation }, returnType, parametersTypes, 2);
    this->_selector = metadata->selector();
}

void ObjCConstructorCall::preInvocation(FFICall* callee, ExecState*, FFICall::Invocation& invocation) {
    ObjCConstructorCall* call = jsCast<ObjCConstructorCall*>(callee);
    invocation.setArgument(0, [call->_klass alloc]);
    invocation.setArgument(1, call->selector());
    invocation.function = reinterpret_cast<void*>(&objc_msgSend);
}

void ObjCConstructorCall::postInvocation(FFICall* callee, ExecState*, FFICall::Invocation& invocation) {
    [invocation.getResult<id>() release];
}

bool ObjCConstructorCall::canInvoke(ExecState* execState) const {
    if (execState->argumentCount() != this->_parameterTypes.size()) {
        return false;
    }

    for (size_t i = 0; i < this->_parameterTypes.size(); ++i) {
        if (!this->_parameterTypes[i].canConvert(execState, execState->uncheckedArgument(i), this->_parameterTypesCells[i].get())) {
            return false;
        }
    }

    return true;
}
}
