//
//  ObjCBlockType.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "ObjCBlockType.h"
#include "ObjCBlockCall.h"
#include "ObjCBlockCallback.h"
#include "PointerInstance.h"

namespace NativeScript {

using namespace JSC;

typedef struct {
    uintptr_t reserved;
    uintptr_t size;
    void (*copy)(struct JSBlock*, const struct JSBlock*);
    void (*dispose)(const struct JSBlock*);
} JSBlockDescriptor;

typedef struct JSBlock {
    void* isa;
    volatile int32_t flags; // contains ref count
    int32_t reserved;
    const void* invoke;
    JSBlockDescriptor* descriptor;

    ObjCBlockCallback* callback;
} JSBlock;

int32_t BLOCK_HAS_COPY_DISPOSE = 1 << 25;

static void copyBlock(JSBlock* dst, const JSBlock* src) {
    JSLockHolder locker(dst->callback->execState());
    gcProtect(dst->callback);
}

static void disposeBlock(const JSBlock* block) {
    JSLockHolder locker(block->callback->execState());
    gcUnprotect(block->callback);
}

JSBlockDescriptor kJSBlockDescriptor = {
    .reserved = 0,
    .size = sizeof(JSBlock),
    .copy = &copyBlock,
    .dispose = &disposeBlock
};

static JSBlock* createBlock(ExecState* execState, JSCell* function, ObjCBlockType* blockType) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    ObjCBlockCallback* blockCallback = ObjCBlockCallback::create(execState->vm(), globalObject, globalObject->objCBlockCallbackStructure(), function, blockType);

    JSBlock* block = new JSBlock({ .isa = nullptr,
                                   .flags = BLOCK_HAS_COPY_DISPOSE,
                                   .reserved = 0,
                                   .invoke = nullptr,
                                   .descriptor = &kJSBlockDescriptor,
                                   .callback = blockCallback });
    block->invoke = block->callback->functionPointer();

    object_setClass(reinterpret_cast<id>(block), objc_getClass("__NSMallocBlock__"));

    return block;
}

const ClassInfo ObjCBlockType::s_info = { "ObjCBlockType", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(ObjCBlockType) };

JSValue ObjCBlockType::read(ExecState* execState, const void* buffer, JSCell* self) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    ObjCBlockType* blockType = jsCast<ObjCBlockType*>(self);
    return ObjCBlockCall::create(execState->vm(), globalObject->objCBlockCallStructure(), *static_cast<const id*>(buffer), blockType);
}

void ObjCBlockType::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    ObjCBlockType* blockType = jsCast<ObjCBlockType*>(self);

    CallData callData;
    if (value.isCell() && value.asCell()->methodTable()->getCallData(value.asCell(), callData) != CallTypeNone) {
        *static_cast<JSBlock**>(buffer) = createBlock(execState, value.asCell(), blockType);
    } else if (value.isUndefinedOrNull()) {
        *static_cast<JSBlock**>(buffer) = nullptr;
    } else {
        JSValue exception = createError(execState, WTF::ASCIILiteral("Value is not a function."));
        execState->vm().throwException(execState, exception);
        return;
    }
}

void ObjCBlockType::postCall(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    delete *static_cast<JSBlock**>(buffer);
}

bool ObjCBlockType::canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    if (value.isCell()) {
        CallData callData;
        return value.asCell()->methodTable()->getCallData(value.asCell(), callData) != CallTypeNone;
    }

    return value.isUndefinedOrNull();
}

const char* ObjCBlockType::encode(JSCell* cell) {
    return "@?";
}

void ObjCBlockType::finishCreation(VM& vm, JSCell* returnType, const WTF::Vector<JSCell*>& parameterTypes) {
    Base::finishCreation(vm);

    this->_ffiTypeMethodTable.ffiType = &ffi_type_pointer;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.write = &write;
    this->_ffiTypeMethodTable.postCall = &postCall;
    this->_ffiTypeMethodTable.canConvert = &canConvert;
    this->_ffiTypeMethodTable.encode = &encode;

    this->_returnType.set(vm, this, returnType);

    for (JSCell* parameterType : parameterTypes) {
        this->_parameterTypes.append(WriteBarrier<JSCell>(vm, this, parameterType));
    }
}

void ObjCBlockType::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    ObjCBlockType* object = jsCast<ObjCBlockType*>(cell);
    visitor.append(&object->_returnType);
    visitor.append(object->_parameterTypes.begin(), object->_parameterTypes.end());
}

CallType ObjCBlockType::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &readFromPointer;
    return CallTypeHost;
}
}
