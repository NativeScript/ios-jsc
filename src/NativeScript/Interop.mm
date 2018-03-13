//
//  Interop.mm
//  NativeScript
//
//  Created by Jason Zhekov on 8/20/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "Interop.h"
#include "FFIFunctionCall.h"
#include "FFISimpleType.h"
#include "FFIType.h"
#include "FunctionReferenceConstructor.h"
#include "FunctionReferenceInstance.h"
#include "FunctionReferenceTypeConstructor.h"
#include "FunctionReferenceTypeInstance.h"
#include "IndexedRefInstance.h"
#include "IndexedRefPrototype.h"
#include "NSErrorWrapperConstructor.h"
#include "ObjCBlockCall.h"
#include "ObjCBlockType.h"
#include "ObjCBlockTypeConstructor.h"
#include "ObjCConstructorBase.h"
#include "ObjCConstructorNative.h"
#include "ObjCProtocolWrapper.h"
#include "ObjCTypes.h"
#include "ObjCWrapperObject.h"
#include "PointerConstructor.h"
#include "PointerInstance.h"
#include "PointerPrototype.h"
#include "RecordConstructor.h"
#include "RecordInstance.h"
#include "ReferenceConstructor.h"
#include "ReferenceInstance.h"
#include "ReferencePrototype.h"
#include "ReferenceTypeConstructor.h"
#include "ReferenceTypeInstance.h"
#include "TypeFactory.h"
#include <JavaScriptCore/BuiltinNames.h>
#include <JavaScriptCore/FunctionPrototype.h>
#include <JavaScriptCore/JSArrayBuffer.h>
#include <JavaScriptCore/ObjectConstructor.h>
#include <sstream>

namespace NativeScript {
using namespace JSC;

void* tryHandleofValue(VM& vm, const JSValue& value, bool* hasHandle) {
    void* handle;

    if (ObjCWrapperObject* wrapper = jsDynamicCast<ObjCWrapperObject*>(vm, value)) {
        *hasHandle = true;
        handle = static_cast<void*>(wrapper->wrappedObject());
    } else if (ObjCConstructorBase* constructor = jsDynamicCast<ObjCConstructorBase*>(vm, value)) {
        *hasHandle = true;
        handle = static_cast<void*>(constructor->klass());
    } else if (ObjCProtocolWrapper* protocolWrapper = jsDynamicCast<ObjCProtocolWrapper*>(vm, value)) {
        *hasHandle = true;
        handle = static_cast<void*>(protocolWrapper->protocol());
    } else if (FFIFunctionCall* functionCall = jsDynamicCast<FFIFunctionCall*>(vm, value)) {
        *hasHandle = true;
        handle = const_cast<void*>(functionCall->functionPointer());
    } else if (ObjCBlockCall* blockCall = jsDynamicCast<ObjCBlockCall*>(vm, value)) {
        *hasHandle = true;
        handle = static_cast<void*>(blockCall->block());
    } else if (RecordInstance* recordInstance = jsDynamicCast<RecordInstance*>(vm, value)) {
        *hasHandle = true;
        handle = recordInstance->data();
    } else if (PointerInstance* pointer = jsDynamicCast<PointerInstance*>(vm, value)) {
        *hasHandle = true;
        handle = pointer->data();
    } else if (ReferenceInstance* referenceInstance = jsDynamicCast<ReferenceInstance*>(vm, value)) {
        *hasHandle = referenceInstance->data() != nullptr;
        handle = referenceInstance->data();
    } else if (IndexedRefInstance* indexedRefInstance = jsDynamicCast<IndexedRefInstance*>(vm, value)) {
        *hasHandle = indexedRefInstance->data() != nullptr;
        handle = indexedRefInstance->data();
    } else if (FunctionReferenceInstance* functionReferenceInstance = jsDynamicCast<FunctionReferenceInstance*>(vm, value)) {
        *hasHandle = functionReferenceInstance->functionPointer() != nullptr;
        handle = const_cast<void*>(functionReferenceInstance->functionPointer());
    } else if (JSArrayBuffer* arrayBuffer = jsDynamicCast<JSArrayBuffer*>(vm, value)) {
        *hasHandle = true;
        handle = arrayBuffer->impl()->data();
    } else if (JSArrayBufferView* arrayBufferView = jsDynamicCast<JSArrayBufferView*>(vm, value)) {
        *hasHandle = true;
        if (arrayBufferView->hasArrayBuffer()) {
            handle = arrayBufferView->possiblySharedBuffer()->data();
        } else {
            handle = arrayBufferView->vector();
        }
    } else if (value.isNull()) {
        *hasHandle = true;
        handle = nullptr;
    } else {
        *hasHandle = false;
        handle = nullptr;
    }

    return handle;
}

size_t sizeofValue(VM& vm, const JSC::JSValue& value) {
    size_t size;

    if (value.inherits(vm, ObjCWrapperObject::info()) || value.inherits(vm, ObjCConstructorBase::info()) || value.inherits(vm, ObjCProtocolWrapper::info()) || value.inherits(vm, FFIFunctionCall::info()) || value.inherits(vm, ObjCBlockCall::info()) || value.inherits(vm, ObjCBlockType::info()) || value.inherits(vm, PointerConstructor::info()) || value.inherits(vm, PointerInstance::info()) || value.inherits(vm, ReferenceConstructor::info()) || value.inherits(vm, ReferenceInstance::info()) || value.inherits(vm, FunctionReferenceConstructor::info()) || value.inherits(vm, FunctionReferenceInstance::info())) {
        size = sizeof(void*);
    } else if (FFISimpleType* simpleType = jsDynamicCast<FFISimpleType*>(vm, value)) {
        const ffi_type* ffiType = simpleType->ffiTypeMethodTable().ffiType;
        size = ffiType->type == FFI_TYPE_VOID ? 0 : ffiType->size;
    } else if (RecordConstructor* recordConstructor = jsDynamicCast<RecordConstructor*>(vm, value)) {
        size = recordConstructor->ffiTypeMethodTable().ffiType->size;
    } else if (RecordInstance* recordInstance = jsDynamicCast<RecordInstance*>(vm, value)) {
        size = recordInstance->size();
    } else {
        size = 0;
    }

    return size;
}

const char* getCompilerEncoding(VM& vm, JSCell* value) {
    const FFITypeMethodTable* table;
    tryGetFFITypeMethodTable(vm, value, &table);
    return table->encode(vm, value);
}

std::string getCompilerEncoding(JSC::JSGlobalObject* globalObject, const Metadata::MethodMeta* method) {
    const Metadata::TypeEncodingsList<Metadata::ArrayCount>* encodings = method->encodings();
    GlobalObject* nsGlobalObject = jsCast<GlobalObject*>(globalObject);
    const Metadata::TypeEncoding* currentEncoding = encodings->first();
    JSCell* returnTypeCell = nsGlobalObject->typeFactory()->parseType(nsGlobalObject, currentEncoding);
    const WTF::Vector<JSCell*> parameterTypesCells = nsGlobalObject->typeFactory()->parseTypes(nsGlobalObject, currentEncoding, encodings->count - 1);

    std::stringstream compilerEncoding;

    compilerEncoding << getCompilerEncoding(globalObject->vm(), returnTypeCell);
    compilerEncoding << "@:"; // id self, SEL _cmd

    for (JSCell* cell : parameterTypesCells) {
        compilerEncoding << getCompilerEncoding(globalObject->vm(), cell);
    }

    return compilerEncoding.str();
}

const ClassInfo Interop::s_info = { "interop", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(Interop) };

static EncodedJSValue JSC_HOST_CALL interopFuncAlloc(ExecState* execState) {
    size_t size = static_cast<size_t>(execState->argument(0).toUInt32(execState));
    void* value = calloc(size, 1);

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    JSValue result = globalObject->interop()->pointerInstanceForPointer(execState->vm(), value);
    if (PointerInstance* pointer = jsDynamicCast<PointerInstance*>(execState->vm(), result)) {
        pointer->setAdopted(true);
    }

    return JSValue::encode(result);
}

static EncodedJSValue JSC_HOST_CALL interopFuncFree(ExecState* execState) {
    JSValue pointerValue = execState->argument(0);
    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    if (!pointerValue.inherits(vm, PointerInstance::info())) {
        const char* className = PointerInstance::info()->className;
        return JSValue::encode(scope.throwException(execState, createError(execState, WTF::String::format("Argument must be a %s.", className))));
    }

    PointerInstance* pointer = jsCast<PointerInstance*>(pointerValue);
    if (pointer->isAdopted()) {
        const char* className = PointerInstance::info()->className;
        return JSValue::encode(scope.throwException(execState, createError(execState, WTF::String::format("%s is adopted.", className))));
    }

    free(pointer->data());

    return JSValue::encode(jsUndefined());
}

static EncodedJSValue JSC_HOST_CALL interopFuncAdopt(ExecState* execState) {
    JSValue pointerValue = execState->argument(0);

    JSC::VM& vm = execState->vm();
    if (!pointerValue.inherits(vm, PointerInstance::info())) {
        auto scope = DECLARE_THROW_SCOPE(vm);

        const char* className = PointerInstance::info()->className;
        return JSValue::encode(scope.throwException(execState, createError(execState, WTF::String::format("Argument must be a %s", className))));
    }

    PointerInstance* pointer = jsCast<PointerInstance*>(pointerValue);
    pointer->setAdopted(true);

    return JSValue::encode(pointer);
}

static EncodedJSValue JSC_HOST_CALL interopFuncHandleof(ExecState* execState) {
    JSValue value = execState->argument(0);
    JSC::VM& vm = execState->vm();

    bool hasHandle;
    void* handle = tryHandleofValue(vm, value, &hasHandle);
    if (!hasHandle) {
        auto scope = DECLARE_THROW_SCOPE(vm);

        return JSValue::encode(scope.throwException(execState, createError(execState, WTF::ASCIILiteral("Unknown type"))));
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    JSValue pointer = globalObject->interop()->pointerInstanceForPointer(execState->vm(), handle);
    return JSValue::encode(pointer);
}

static EncodedJSValue JSC_HOST_CALL interopFuncSizeof(ExecState* execState) {
    JSC::VM& vm = execState->vm();
    JSValue value = execState->argument(0);
    size_t size = sizeofValue(vm, value);

    if (size == 0) {
        auto scope = DECLARE_THROW_SCOPE(vm);

        return JSValue::encode(scope.throwException(execState, createError(execState, WTF::ASCIILiteral("Unknown type"))));
    }

    return JSValue::encode(jsNumber(size));
}

static EncodedJSValue JSC_HOST_CALL interopFuncBufferFromData(ExecState* execState) {
    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    id object = toObject(execState, execState->argument(0));
    if (scope.exception()) {
        return JSValue::encode(jsUndefined());
    }

    if ([object isKindOfClass:[NSData class]]) {
        JSArrayBuffer* buffer = jsCast<GlobalObject*>(execState->lexicalGlobalObject())->interop()->bufferFromData(execState, object);
        return JSValue::encode(buffer);
    }

    return throwVMTypeError(execState, scope, WTF::ASCIILiteral("Argument must be an NSData instance."));
}

void Interop::finishCreation(VM& vm, GlobalObject* globalObject) {
    Base::finishCreation(vm);

    PointerConstructor* pointerConstructor = globalObject->typeFactory()->pointerConstructor();
    this->_pointerInstanceStructure.set(vm, this, PointerInstance::createStructure(globalObject, pointerConstructor->get(globalObject->globalExec(), vm.propertyNames->prototype)));
    this->putDirect(vm, Identifier::fromString(&vm, pointerConstructor->name()), pointerConstructor, ReadOnly | DontDelete);

    ReferencePrototype* referencePrototype = ReferencePrototype::create(vm, globalObject, ReferencePrototype::createStructure(vm, globalObject, globalObject->objectPrototype()));
    this->_referenceInstanceStructure.set(vm, this, ReferenceInstance::createStructure(vm, globalObject, referencePrototype));

    IndexedRefPrototype* indexedRefPrototype = IndexedRefPrototype::create(vm, globalObject, IndexedRefPrototype::createStructure(vm, globalObject, globalObject->objectPrototype()));
    this->_indexedRefInstanceStructure.set(vm, this, IndexedRefInstance::createStructure(vm, globalObject, indexedRefPrototype));
    this->_extVectorInstanceStructure.set(vm, this, IndexedRefInstance::createStructure(vm, globalObject, indexedRefPrototype));

    ReferenceConstructor* referenceConstructor = ReferenceConstructor::create(vm, ReferenceConstructor::createStructure(vm, globalObject, globalObject->functionPrototype()), referencePrototype);
    this->putDirect(vm, Identifier::fromString(&vm, referenceConstructor->name()), referenceConstructor, ReadOnly | DontDelete);
    referencePrototype->putDirect(vm, vm.propertyNames->constructor, referenceConstructor, DontEnum);

    JSObject* functionReferencePrototype = jsCast<JSObject*>(constructEmptyObject(globalObject->globalExec(), globalObject->functionPrototype()));
    this->_functionReferenceInstanceStructure.set(vm, this, FunctionReferenceInstance::createStructure(vm, globalObject, functionReferencePrototype));

    FunctionReferenceConstructor* functionReferenceConstructor = FunctionReferenceConstructor::create(vm, FunctionReferenceConstructor::createStructure(vm, globalObject, globalObject->functionPrototype()), functionReferencePrototype);
    this->putDirect(vm, Identifier::fromString(&vm, functionReferenceConstructor->name()), functionReferenceConstructor, ReadOnly | DontDelete);
    functionReferencePrototype->putDirect(vm, vm.propertyNames->constructor, functionReferenceConstructor, DontEnum);

    this->_nsErrorWrapperConstructor.set(vm, this, NSErrorWrapperConstructor::create(vm, NSErrorWrapperConstructor::createStructure(vm, globalObject, globalObject->functionPrototype())));
    this->putDirect(vm, Identifier::fromString(&vm, "NSErrorWrapper"), this->_nsErrorWrapperConstructor.get());

    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, WTF::ASCIILiteral("alloc")), 0, &interopFuncAlloc, NoIntrinsic, ReadOnly | DontDelete);
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, WTF::ASCIILiteral("free")), 0, &interopFuncFree, NoIntrinsic, ReadOnly | DontDelete);
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, WTF::ASCIILiteral("adopt")), 0, &interopFuncAdopt, NoIntrinsic, ReadOnly | DontDelete);
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, WTF::ASCIILiteral("handleof")), 0, &interopFuncHandleof, NoIntrinsic, ReadOnly | DontDelete);
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, WTF::ASCIILiteral("sizeof")), 0, &interopFuncSizeof, NoIntrinsic, ReadOnly | DontDelete);
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, WTF::ASCIILiteral("bufferFromData")), 1, &interopFuncBufferFromData, NoIntrinsic, ReadOnly | DontDelete);

    JSObject* types = constructEmptyObject(globalObject->globalExec());
    this->putDirect(vm, Identifier::fromString(&vm, WTF::ASCIILiteral("types")), types, None);

    JSObject* voidType = globalObject->typeFactory()->voidType();
    types->putDirect(vm, Identifier::fromString(&vm, voidType->methodTable()->className(voidType)), voidType, None);
    JSObject* boolType = globalObject->typeFactory()->boolType();
    types->putDirect(vm, Identifier::fromString(&vm, boolType->methodTable()->className(boolType)), boolType, None);
    JSObject* utf8CStringType = globalObject->typeFactory()->utf8CStringType();
    types->putDirect(vm, Identifier::fromString(&vm, utf8CStringType->methodTable()->className(utf8CStringType)), utf8CStringType, None);
    JSObject* unicharType = globalObject->typeFactory()->unicharType();
    types->putDirect(vm, Identifier::fromString(&vm, unicharType->methodTable()->className(unicharType)), unicharType, None);
    JSObject* int8Type = globalObject->typeFactory()->int8Type();
    types->putDirect(vm, Identifier::fromString(&vm, int8Type->methodTable()->className(int8Type)), int8Type, None);
    JSObject* uint8Type = globalObject->typeFactory()->uint8Type();
    types->putDirect(vm, Identifier::fromString(&vm, uint8Type->methodTable()->className(uint8Type)), uint8Type, None);
    JSObject* int16Type = globalObject->typeFactory()->int16Type();
    types->putDirect(vm, Identifier::fromString(&vm, int16Type->methodTable()->className(int16Type)), int16Type, None);
    JSObject* uint16Type = globalObject->typeFactory()->uint16Type();
    types->putDirect(vm, Identifier::fromString(&vm, uint16Type->methodTable()->className(uint16Type)), uint16Type, None);
    JSObject* int32Type = globalObject->typeFactory()->int32Type();
    types->putDirect(vm, Identifier::fromString(&vm, int32Type->methodTable()->className(int32Type)), int32Type, None);
    JSObject* uint32Type = globalObject->typeFactory()->uint32Type();
    types->putDirect(vm, Identifier::fromString(&vm, uint32Type->methodTable()->className(uint32Type)), uint32Type, None);
    JSObject* int64Type = globalObject->typeFactory()->int64Type();
    types->putDirect(vm, Identifier::fromString(&vm, int64Type->methodTable()->className(int64Type)), int64Type, None);
    JSObject* uint64Type = globalObject->typeFactory()->uint64Type();
    types->putDirect(vm, Identifier::fromString(&vm, uint64Type->methodTable()->className(uint64Type)), uint64Type, None);
    JSObject* floatType = globalObject->typeFactory()->floatType();
    types->putDirect(vm, Identifier::fromString(&vm, floatType->methodTable()->className(floatType)), floatType, None);
    JSObject* doubleType = globalObject->typeFactory()->doubleType();
    types->putDirect(vm, Identifier::fromString(&vm, doubleType->methodTable()->className(doubleType)), doubleType, None);

    JSObject* objCIdType = globalObject->typeFactory()->NSObjectConstructor(globalObject);
    types->putDirect(vm, Identifier::fromString(&vm, WTF::ASCIILiteral("id")), objCIdType, None);
    JSObject* objCProtocolType = globalObject->typeFactory()->objCProtocolType();
    types->putDirect(vm, Identifier::fromString(&vm, objCProtocolType->methodTable()->className(objCProtocolType)), objCProtocolType, None);
    JSObject* objCClassType = globalObject->typeFactory()->objCClassType();
    types->putDirect(vm, Identifier::fromString(&vm, objCClassType->methodTable()->className(objCClassType)), objCClassType, None);
    JSObject* objCSelectorType = globalObject->typeFactory()->objCSelectorType();
    types->putDirect(vm, Identifier::fromString(&vm, objCSelectorType->methodTable()->className(objCSelectorType)), objCSelectorType, None);

    JSObject* referenceTypePrototype = constructEmptyObject(globalObject->globalExec());
    ReferenceTypeConstructor* referenceTypeConstructor = ReferenceTypeConstructor::create(vm, ReferenceTypeConstructor::createStructure(vm, globalObject, globalObject->functionPrototype()), referenceTypePrototype);
    types->putDirect(vm, Identifier::fromString(&vm, referenceTypeConstructor->name()), referenceTypeConstructor, ReadOnly | DontDelete);
    referenceTypePrototype->putDirect(vm, vm.propertyNames->constructor, referenceTypeConstructor, DontEnum);

    JSObject* functionReferenceTypePrototype = constructEmptyObject(globalObject->globalExec());
    FunctionReferenceTypeConstructor* functionReferenceTypeConstructor = FunctionReferenceTypeConstructor::create(vm, FunctionReferenceTypeConstructor::createStructure(vm, globalObject, globalObject->functionPrototype()), functionReferenceTypePrototype);
    types->putDirect(vm, Identifier::fromString(&vm, functionReferenceTypeConstructor->name()), functionReferenceTypeConstructor, ReadOnly | DontDelete);
    functionReferenceTypePrototype->putDirect(vm, vm.propertyNames->constructor, functionReferenceTypeConstructor, DontEnum);

    JSObject* objCBlockTypePrototype = constructEmptyObject(globalObject->globalExec());
    ObjCBlockTypeConstructor* objCBlockTypeConstructor = ObjCBlockTypeConstructor::create(vm, ObjCBlockTypeConstructor::createStructure(vm, globalObject, globalObject->functionPrototype()), objCBlockTypePrototype);
    types->putDirect(vm, Identifier::fromString(&vm, objCBlockTypeConstructor->name()), objCBlockTypeConstructor, ReadOnly | DontDelete);
    objCBlockTypePrototype->putDirect(vm, vm.propertyNames->constructor, objCBlockTypeConstructor, DontEnum);
}

JSValue Interop::pointerInstanceForPointer(VM& vm, void* value) {
    if (!value) {
        return jsNull();
    }

    if (PointerInstance* pointerInstance = this->_pointerToInstance.get(value)) {
        return pointerInstance;
    }

    PointerInstance* pointerInstance = PointerInstance::create(vm, this->_pointerInstanceStructure.get(), value);
    this->_pointerToInstance.set(value, pointerInstance);
    return pointerInstance;
}

void Interop::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    Interop* interop = jsCast<Interop*>(cell);

    visitor.append(interop->_pointerInstanceStructure);
    visitor.append(interop->_referenceInstanceStructure);
    visitor.append(interop->_indexedRefInstanceStructure);
    visitor.append(interop->_extVectorInstanceStructure);
    visitor.append(interop->_functionReferenceInstanceStructure);
    visitor.append(interop->_nsErrorWrapperConstructor);
}

ErrorInstance* Interop::wrapError(ExecState* execState, NSError* error) const {
    return this->_nsErrorWrapperConstructor->createError(execState, error);
}

JSArrayBuffer* Interop::bufferFromData(ExecState* execState, NSData* data) const {
    JSArrayBuffer* arrayBuffer = JSArrayBuffer::create(execState->vm(), execState->lexicalGlobalObject()->arrayBufferStructure(ArrayBufferSharingMode::Default), ArrayBuffer::createFromBytes([data bytes], [data length], [](void*) {}));

    // make the ArrayBuffer hold on to the NSData instance so as to keep its bytes alive
    arrayBuffer->putDirect(execState->vm(), execState->propertyNames().builtinNames().homeObjectPrivateName(), NativeScript::toValue(execState, data));
    return arrayBuffer;
}
}
