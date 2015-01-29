//
//  FFISimpleType.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/24/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "FFISimpleType.h"
#include "PointerInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo FFISimpleType::s_info = { "FFISimpleType", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(FFISimpleType) };

void FFISimpleType::finishCreation(VM& vm, const WTF::String& name, const FFITypeMethodTable& ffiTypeMethodTable) {
    Base::finishCreation(vm);

    this->_name = name;
    this->_ffiTypeMethodTable = ffiTypeMethodTable;
}

WTF::String FFISimpleType::className(const JSObject* object) {
    const FFISimpleType* simpleType = jsCast<const FFISimpleType*>(object);
    return simpleType->_name;
}

CallType FFISimpleType::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &readFromPointer;
    return CallTypeHost;
}
}