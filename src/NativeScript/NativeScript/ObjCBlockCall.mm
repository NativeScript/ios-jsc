//
//  ObjCBlockCall.mm
//  NativeScript
//
//  Created by Jason Zhekov on 10/6/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCBlockCall.h"
#include <JavaScriptCore/DelayedReleaseScope.h>
#include "ObjCBlockType.h"

namespace NativeScript {
using namespace JSC;

struct BlockLiteral {
    void* isa;
    int32_t flags;
    int32_t reserved;
    void* invoke;
};

const ClassInfo ObjCBlockCall::s_info = { "ObjCBlockCall", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(ObjCBlockCall) };

void ObjCBlockCall::finishCreation(VM& vm, id block, ObjCBlockType* blockType) {
    Base::finishCreation(vm, WTF::emptyString());
    this->_block = block;

    const WTF::Vector<JSCell*> parameterTypes = blockType->parameterTypes();

    Base::initializeFFI(vm, blockType->returnType(), parameterTypes, 1);
    Base::setArgument(0, this->_block.get());
}

EncodedJSValue ObjCBlockCall::executeCall(ExecState* execState) {
    ObjCBlockCall* self = jsCast<ObjCBlockCall*>(execState->callee());

    self->preCall(execState);
    if (execState->hadException()) {
        return JSValue::encode(jsUndefined());
    }

    self->executeFFICall(FFI_FN(reinterpret_cast<BlockLiteral*>(self->_block.get())->invoke));

    return JSValue::encode(self->postCall(execState));
}

CallType ObjCBlockCall::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &executeCall;
    return CallTypeHost;
}

ObjCBlockCall::~ObjCBlockCall() {
    Heap::heap(this)->releaseSoon(WTF::move(this->_block));
}
}
