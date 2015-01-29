//
//  Record.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 9/27/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "Record.h"
#include "Interop.h"

namespace NativeScript {
using namespace JSC;

RecordInstance* createRecordInstance(ExecState* execState, const WTF::String& name, RecordType recordType, const void* data) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    RecordConstructor* constructor = globalObject->recordConstructorFor(name, recordType);
    RecordInstance* record = RecordInstance::create(execState->vm(), globalObject, constructor->instancesStructure());
    record->copyFrom(data);
    return record;
}

const ClassInfo RecordConstructor::s_info = { "record", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(RecordConstructor) };

static bool areEqual(ExecState* execState, JSValue v1, JSValue v2, const FFIType* ffiType) {
    if (ffiType->type->type == FFI_TYPE_STRUCT) {
        if (!(v1.isObject() && v2.isObject())) {
            return false;
        }

        if (v1.inherits(RecordInstance::info()) && v2.inherits(RecordInstance::info())) {
            RecordInstance* record1 = jsCast<RecordInstance*>(v1);
            RecordInstance* record2 = jsCast<RecordInstance*>(v2);

            if (record1->ffiType() != record2->ffiType()) {
                return false;
            }

            size_t size = record1->ffiType()->type->size;
            bool areEqual = memcmp(record1->data(), record2->data(), size) == 0;
            return areEqual;
        } else {
            if (!(v1.isObject() && v2.isObject())) {
                return false;
            }

            const FFIRecordType* recordType = static_cast<const FFIRecordType*>(ffiType);
            for (auto kvp : recordType->fields()) {
                Identifier fieldName = Identifier(execState, kvp.first.data());

                JSValue fieldValue1 = v1.get(execState, fieldName);
                if (execState->hadException()) {
                    return false;
                }

                JSValue fieldValue2 = v2.get(execState, fieldName);
                if (execState->hadException()) {
                    return false;
                }

                if (!areEqual(execState, fieldValue1, fieldValue2, kvp.second.type)) {
                    return false;
                }
            }

            return true;
        }
    } else {
        return JSValue::equal(execState, v1, v2);
    }
}

static EncodedJSValue JSC_HOST_CALL recordConstructorFuncEquals(ExecState* execState) {
    JSValue arg1 = execState->argument(0);
    JSValue arg2 = execState->argument(1);

    if (execState->argumentCount() != 2) {
        return JSValue::encode(execState->vm().throwException(execState, createError(execState, WTF::ASCIILiteral("Two arguments required."))));
    }

    RecordConstructor* recordConstructor = jsCast<RecordConstructor*>(execState->thisValue());
    RecordPrototype* recordPrototype = jsCast<RecordPrototype*>(recordConstructor->get(execState, execState->vm().propertyNames->prototype));
    const FFIRecordType* ffiType = recordPrototype->ffiType();

    bool result = areEqual(execState, arg1, arg2, ffiType);
    return JSValue::encode(jsBoolean(result));
}

void RecordConstructor::finishCreation(VM& vm, JSGlobalObject* globalObject, RecordPrototype* recordPrototype, const WTF::String& name) {
    Base::finishCreation(vm, name);

    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, recordPrototype, DontEnum | DontDelete | ReadOnly);
    this->putDirectWithoutTransition(vm, vm.propertyNames->length, jsNumber(1), ReadOnly | DontEnum | DontDelete);
    this->putDirectNativeFunction(vm, globalObject, Identifier(&vm, "equals"), 0, recordConstructorFuncEquals, NoIntrinsic, DontDelete | ReadOnly | Attribute::Function);
    _instancesStructure.set(vm, this, RecordInstance::createStructure(globalObject, recordPrototype));
}

static EncodedJSValue JSC_HOST_CALL constructRecordInstance(ExecState* execState) {
    RecordConstructor* constructor = jsCast<RecordConstructor*>(execState->callee());
    RecordInstance* instance = RecordInstance::create(execState->vm(), jsCast<GlobalObject*>(execState->lexicalGlobalObject()), constructor->instancesStructure());

    if (execState->argumentCount() == 1) {
        const FFIRecordType* recordType = jsCast<RecordPrototype*>(constructor->get(execState, execState->vm().propertyNames->prototype))->ffiType();

        JSValue value = execState->argument(0);

        if (!value.isObject()) {
            return JSValue::encode(execState->vm().throwException(execState, createError(execState, WTF::ASCIILiteral("Argument is not an object."))));
        }

        if (PointerInstance* pointer = jsDynamicCast<PointerInstance*>(value)) {
            instance->copyFrom(pointer->data());
        } else {
            recordType->write(execState, value, instance->data());
        }
    }

    return JSValue::encode(instance);
}

ConstructType RecordConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = &constructRecordInstance;
    return ConstructTypeHost;
}

CallType RecordConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &constructRecordInstance;
    return CallTypeHost;
}

void RecordConstructor::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    RecordConstructor* constructor = jsCast<RecordConstructor*>(cell);
    visitor.append(&constructor->_instancesStructure);

    Base::visitChildren(constructor, visitor);
}

const ClassInfo RecordInstance::s_info = { "record", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(RecordInstance) };

void RecordInstance::finishCreation(VM& vm, GlobalObject* globalObject) {
    Base::finishCreation(vm);
    this->preventExtensions(vm);

    size_t size = this->ffiType()->type->size;
    void* data = calloc(size, 1);
    PointerInstance* pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(vm, data));
    pointer->setAdopted(true);
    _pointer.set(vm, this, pointer);
}

void RecordInstance::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    RecordInstance* record = jsCast<RecordInstance*>(cell);
    visitor.append(&record->_pointer);

    Base::visitChildren(record, visitor);
}

const FFIRecordType* RecordInstance::ffiType() const {
    return jsCast<RecordPrototype*>(this->prototype())->ffiType();
}

void RecordInstance::copyFrom(const void* newValue) {
    void* value = const_cast<void*>(_pointer.get()->data());
    memcpy(value, newValue, this->ffiType()->type->size);
}
}