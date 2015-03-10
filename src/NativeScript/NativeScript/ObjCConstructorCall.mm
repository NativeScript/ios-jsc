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

const ClassInfo ObjCConstructorCall::s_info = { "ObjCConstructorCall", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(ObjCConstructorCall) };

void ObjCConstructorCall::finishCreation(VM& vm, GlobalObject* globalObject, Class klass, const Metadata::MethodMeta* metadata) {
    Base::finishCreation(vm, metadata->jsName());
    this->_klass = klass;

    Metadata::MetaFileOffset cursor = metadata->encodingOffset();

    JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, cursor);
    const WTF::Vector<JSCell*> parametersTypes = globalObject->typeFactory()->parseTypes(globalObject, cursor, metadata->encodingCount() - 1);

    Base::initializeFFI(vm, returnType, parametersTypes, 2);
    Base::setArgument(1, metadata->selector());
}

EncodedJSValue JSC_HOST_CALL ObjCConstructorCall::executeCall(ExecState* execState) {
    ObjCConstructorCall* self = jsCast<ObjCConstructorCall*>(execState->callee());

    self->preCall(execState);
    if (execState->hadException()) {
        return JSValue::encode(jsUndefined());
    }

    id instance = [self->_klass alloc];
    self->setArgument(0, instance);
    self->executeFFICall(FFI_FN(&objc_msgSend));

    JSValue result = self->postCall(execState);
    [instance release];
    return JSValue::encode(result);
}

CallType ObjCConstructorCall::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &ObjCConstructorCall::executeCall;
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