//
//  FunctionReferenceTypeInstance.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/18/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "FunctionReferenceTypeInstance.h"
#include "FFIFunctionCall.h"
#include "FFIFunctionCallback.h"
#include "FunctionReferenceInstance.h"
#include "Interop.h"
#include "PointerInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo FunctionReferenceTypeInstance::s_info = { "FunctionReferenceTypeInstance", &Base::s_info, 0, CREATE_METHOD_TABLE(FunctionReferenceTypeInstance) };

JSValue FunctionReferenceTypeInstance::read(ExecState* execState, const void* buffer, JSCell* self) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    FunctionReferenceTypeInstance* functionReferenceType = jsCast<FunctionReferenceTypeInstance*>(self);
    const void* functionPointer = *static_cast<const id*>(buffer);
    return FFIFunctionCall::create(execState->vm(), globalObject->ffiFunctionCallStructure(), functionPointer, WTF::emptyString(), functionReferenceType->returnType(), functionReferenceType->parameterTypes(), false);
}

void FunctionReferenceTypeInstance::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    if (value.isUndefinedOrNull()) {
        *static_cast<void**>(buffer) = nullptr;
        return;
    }

    if (FunctionReferenceInstance* functionReference = jsDynamicCast<FunctionReferenceInstance*>(value)) {
        if (!functionReference->functionPointer()) {
            GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
            FunctionReferenceTypeInstance* functionReferenceType = jsCast<FunctionReferenceTypeInstance*>(self);
            FFIFunctionCallback* functionCallback = FFIFunctionCallback::create(execState->vm(), globalObject, globalObject->ffiFunctionCallbackStructure(), functionReference->function(), functionReferenceType);
            functionReference->setCallback(execState->vm(), functionCallback);
        }
    }

    bool hasHandle;
    void* handle = tryHandleofValue(value, &hasHandle);
    if (!hasHandle) {
        JSC::VM& vm = execState->vm();
        auto scope = DECLARE_THROW_SCOPE(vm);

        JSValue exception = createError(execState, WTF::ASCIILiteral("Value is not a function reference."));
        scope.throwException(execState, exception);
        return;
    }

    *static_cast<const void**>(buffer) = handle;
}

bool FunctionReferenceTypeInstance::canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return value.isUndefinedOrNull() || value.inherits(FunctionReferenceInstance::info());
}

const char* FunctionReferenceTypeInstance::encode(JSCell* cell) {
    return "^?";
}

void FunctionReferenceTypeInstance::finishCreation(VM& vm, JSCell* returnType, const WTF::Vector<JSCell*>& parameterTypes) {
    Base::finishCreation(vm);

    this->_ffiTypeMethodTable.ffiType = &ffi_type_pointer;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.write = &write;
    this->_ffiTypeMethodTable.canConvert = &canConvert;
    this->_ffiTypeMethodTable.encode = &encode;

    this->_returnType.set(vm, this, returnType);

    for (JSCell* parameterType : parameterTypes) {
        this->_parameterTypes.append(WriteBarrier<JSCell>(vm, this, parameterType));
    }
}

void FunctionReferenceTypeInstance::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    FunctionReferenceTypeInstance* object = jsCast<FunctionReferenceTypeInstance*>(cell);
    visitor.append(&object->_returnType);
    visitor.append(object->_parameterTypes.begin(), object->_parameterTypes.end());
}

CallType FunctionReferenceTypeInstance::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &readFromPointer;
    return CallType::Host;
}
}
