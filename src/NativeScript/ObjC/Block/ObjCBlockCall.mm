//
//  ObjCBlockCall.mm
//  NativeScript
//
//  Created by Jason Zhekov on 10/6/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

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

const ClassInfo ObjCBlockWrapper::s_info = { "ObjCBlockWrapper", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCBlockWrapper) };

void ObjCBlockWrapper::finishCreation(VM& vm, id block, ObjCBlockType* blockType) {
    Base::finishCreation(vm, WTF::emptyString());

    const WTF::Vector<JSCell*> parameterTypes = blockType->parameterTypes();
    Base::initializeFunctionWrapper(vm, parameterTypes.size());
    std::unique_ptr<ObjCBlockCall> call(new ObjCBlockCall(this));
    call->initializeFFI(vm, { &preInvocation, nullptr }, blockType->returnType(), parameterTypes, 1);
    call->_block = adoptNS(Block_copy(block));

    this->_functionsContainer.push_back(std::move(call));
}

void ObjCBlockWrapper::preInvocation(FFICall* callee, ExecState*, FFICall::Invocation& invocation) {
    ObjCBlockCall* call = static_cast<ObjCBlockCall*>(callee);

    invocation.function = reinterpret_cast<BlockLiteral*>(call->block())->invoke;
    invocation.setArgument(0, call->block());
}

ObjCBlockWrapper::~ObjCBlockWrapper() {
    for (auto const& func : this->_functionsContainer) {
        ObjCBlockCall* call = static_cast<ObjCBlockCall*>(func.get());
        Heap::heap(this)->releaseSoon(WTFMove(call->_block));
    }
}
}
