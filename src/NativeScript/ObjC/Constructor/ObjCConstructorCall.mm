//
//  ObjCConstructorCall.mm
//  NativeScript
//
//  Created by Jason Zhekov on 10/6/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCConstructorCall.h"
#include <objc/message.h>
#include "Metadata.h"
#include "TypeFactory.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCConstructorCall::s_info = { "ObjCConstructorCall", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCConstructorCall) };

void ObjCConstructorCall::finishCreation(VM& vm, GlobalObject* globalObject, Class klass, const Metadata::MethodMeta* metadata) {
    Base::finishCreation(vm, metadata->jsName());
    this->_klass = klass;

    const Metadata::TypeEncoding* encodings = metadata->encodings()->first();

    JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, encodings);
    const WTF::Vector<JSCell*> parametersTypes = globalObject->typeFactory()->parseTypes(globalObject, encodings, metadata->encodings()->count - 1);

    Base::initializeFFI(vm, returnType, parametersTypes, 2);
    this->_selector = metadata->selector();
}

EncodedJSValue ObjCConstructorCall::derivedExecuteCall(ExecState* execState, uint8_t* buffer) {
    id instance = [this->_klass alloc];
    this->setArgument(buffer, 0, instance);
    this->setArgument(buffer, 1, this->selector());
    this->executeFFICall(execState, buffer, FFI_FN(&objc_msgSend));

    JSValue result = this->postCall(execState, buffer);

    // wrapping the object retains it, we need to balance the +1 from alloc-ing it
    id resultObject = *static_cast<id*>(this->getReturn(buffer));
    [resultObject release];

    return JSValue::encode(result);
}

CallType ObjCConstructorCall::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &Base::executeCall<ObjCConstructorCall>;
    return CallTypeHost;
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