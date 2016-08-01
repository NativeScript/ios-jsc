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
#include "ReleasePool.h"
#include <JavaScriptCore/StrongInlines.h>
#include <stdlib.h>

namespace NativeScript {

using namespace std;
using namespace JSC;

typedef struct JSBlock {

    typedef struct {
        uintptr_t reserved;
        uintptr_t size;
        void (*copy)(struct JSBlock*, const struct JSBlock*);
        void (*dispose)(struct JSBlock*);
    } JSBlockDescriptor;

    enum {
        BLOCK_NEEDS_FREE = (1 << 24), // runtime
        BLOCK_HAS_COPY_DISPOSE = (1 << 25), // compiler
    };

    void* isa;
    volatile int32_t flags; // contains ref count
    int32_t reserved;
    const void* invoke;
    JSBlockDescriptor* descriptor;

    Strong<ObjCBlockCallback> callback;

    static JSBlockDescriptor kJSBlockDescriptor;

    static CFTypeRef createBlock(ExecState* execState, JSCell* function, ObjCBlockType* blockType) {

        GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
        ObjCBlockCallback* blockCallback = ObjCBlockCallback::create(execState->vm(), globalObject, globalObject->objCBlockCallbackStructure(), function, blockType);

        JSBlock* blockPointer = reinterpret_cast<JSBlock*>(calloc(1, sizeof(JSBlock)));

        *blockPointer = {
            .isa = nullptr,
            .flags = BLOCK_HAS_COPY_DISPOSE | BLOCK_NEEDS_FREE | (1 /* ref count */ << 1),
            .reserved = 0,
            .invoke = blockCallback->functionPointer(),
            .descriptor = &kJSBlockDescriptor,
        };

        blockPointer->callback.set(execState->vm(), blockCallback);

        object_setClass(reinterpret_cast<id>(blockPointer), objc_getClass("__NSMallocBlock__"));

        return blockPointer;
    }

    static void copyBlock(JSBlock* dst, const JSBlock* src) {
        ASSERT_NOT_REACHED();
    }

    static void disposeBlock(JSBlock* block) {
        JSLockHolder locker(block->callback->vm());
        block->callback.clear();
    }

    static JSC::JSCell* getJSFunction(id block) {
        JSBlock* jsBlock = reinterpret_cast<JSBlock*>(block);
        if (jsBlock->descriptor == &kJSBlockDescriptor) {
            return jsBlock->callback.get()->function();
        }
        return nullptr;
    }

} JSBlock;

JSBlock::JSBlockDescriptor JSBlock::kJSBlockDescriptor = {
    .reserved = 0,
    .size = sizeof(JSBlock),
    .copy = &copyBlock,
    .dispose = &disposeBlock
};

const ClassInfo ObjCBlockType::s_info = { "ObjCBlockType", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCBlockType) };

JSValue ObjCBlockType::read(ExecState* execState, const void* buffer, JSCell* self) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    ObjCBlockType* blockType = jsCast<ObjCBlockType*>(self);
    id block = *static_cast<const id*>(buffer);

    if (block == nil) {
        return jsNull();
    }

    if (JSValue objCBlockCallback = JSBlock::getJSFunction(block)) {
        return objCBlockCallback;
    }

    return ObjCBlockCall::create(execState->vm(), globalObject->objCBlockCallStructure(), block, blockType);
}

void ObjCBlockType::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    ObjCBlockType* blockType = jsCast<ObjCBlockType*>(self);

    CallData callData;
    if (value.isCell() && value.asCell()->methodTable()->getCallData(value.asCell(), callData) != CallTypeNone) {
        *static_cast<CFTypeRef*>(buffer) = CFAutorelease(JSBlock::createBlock(execState, value.asCell(), blockType));
    } else if (value.isUndefinedOrNull()) {
        *static_cast<CFTypeRef*>(buffer) = nullptr;
    } else {
        JSValue exception = createError(execState, WTF::ASCIILiteral("Value is not a function."));
        execState->vm().throwException(execState, exception);
        return;
    }
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
