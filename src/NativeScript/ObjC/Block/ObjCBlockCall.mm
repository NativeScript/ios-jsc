//
//  ObjCBlockCall.mm
//  NativeScript
//
//  Created by Jason Zhekov on 10/6/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "NativeScript-Prefix.h"
#include "ObjCBlockCall.h"
#include "ObjCBlockType.h"

namespace NativeScript {
using namespace JSC;

struct BlockLiteral {
    void* isa;
    int32_t flags;
    int32_t reserved;
    void* invoke;
};

const ClassInfo ObjCBlockCall::s_info = { "ObjCBlockCall", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCBlockCall) };

void ObjCBlockCall::finishCreation(VM& vm, id block, ObjCBlockType* blockType) {
    Base::finishCreation(vm, WTF::emptyString());
    this->_block = adoptNS(Block_copy(block));

    const WTF::Vector<JSCell*> parameterTypes = blockType->parameterTypes();

    Base::initializeFFI(vm, { &preInvocation, nullptr }, blockType->returnType(), parameterTypes, 1);
}

void ObjCBlockCall::preInvocation(FFICall* callee, ExecState*, FFICall::Invocation& invocation) {
    ObjCBlockCall* call = jsCast<ObjCBlockCall*>(callee);

    invocation.function = reinterpret_cast<BlockLiteral*>(call->block())->invoke;
    invocation.setArgument(0, call->block());
}

ObjCBlockCall::~ObjCBlockCall() {
    Heap::heap(this)->releaseSoon(WTF::move(this->_block));
}
}
