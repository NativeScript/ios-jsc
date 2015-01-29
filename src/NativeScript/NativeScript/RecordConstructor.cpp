//
//  RecordConstructor.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 9/27/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "RecordConstructor.h"
#include <JavaScriptCore/JSGlobalObjectInspectorController.h>
#include "Interop.h"
#include "RecordPrototype.h"
#include "RecordInstance.h"
#include "RecordField.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo RecordConstructor::s_info = { "record", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(RecordConstructor) };

static bool areEqual(ExecState* execState, JSValue v1, JSValue v2, JSCell* typeCell) {
    if (RecordConstructor* recordConstructor = jsDynamicCast<RecordConstructor*>(typeCell)) {
        if (!(v1.isObject() && v2.isObject())) {
            return false;
        }

        if (v1.inherits(RecordInstance::info()) && v2.inherits(RecordInstance::info())) {
            RecordInstance* record1 = jsCast<RecordInstance*>(v1);
            RecordInstance* record2 = jsCast<RecordInstance*>(v2);

            if (record1->size() != record2->size()) {
                return false;
            }

            bool areEqual = memcmp(record1->data(), record2->data(), record1->size()) == 0;
            return areEqual;
        } else {
            if (!(v1.isObject() && v2.isObject())) {
                return false;
            }

            RecordPrototype* recordPrototype = jsDynamicCast<RecordPrototype*>(recordConstructor->get(execState, execState->vm().propertyNames->prototype));
            for (RecordField* field : recordPrototype->fields()) {
                Identifier fieldName = Identifier(execState, field->fieldName());

                JSValue fieldValue1 = v1.get(execState, fieldName);
                if (execState->hadException()) {
                    return false;
                }

                JSValue fieldValue2 = v2.get(execState, fieldName);
                if (execState->hadException()) {
                    return false;
                }

                if (!areEqual(execState, fieldValue1, fieldValue2, field->fieldType())) {
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

    bool result = areEqual(execState, arg1, arg2, recordConstructor);
    return JSValue::encode(jsBoolean(result));
}

JSValue RecordConstructor::read(ExecState* execState, const void* buffer, JSCell* self) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    RecordConstructor* constructor = jsCast<RecordConstructor*>(self);
    const size_t size = constructor->_ffiTypeMethodTable.ffiType->size;

    void* data = malloc(size);
    memcpy(data, buffer, size);
    PointerInstance* pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState->vm(), data));
    pointer->setAdopted(true);
    RecordInstance* record = RecordInstance::create(execState->vm(), globalObject, constructor->instancesStructure(), size, pointer);
    return record;
}

void RecordConstructor::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    RecordConstructor* constructor = jsCast<RecordConstructor*>(self);
    const ffi_type* ffiType = constructor->_ffiTypeMethodTable.ffiType;

    if (RecordInstance* record = jsDynamicCast<RecordInstance*>(value)) {
        if (ffiType != jsCast<RecordConstructor*>(record->get(execState, execState->vm().propertyNames->constructor))->_ffiTypeMethodTable.ffiType) {
            JSValue exception = createError(execState, "Different record types");
            jsCast<GlobalObject*>(execState->lexicalGlobalObject())->inspectorController().reportAPIException(execState, exception);
            WTFCrash();
        }

        memcpy(buffer, record->data(), record->size());
    } else {
        memset(buffer, 0, ffiType->size);

        JSObject* object = jsCast<JSObject*>(value.asCell());

        const WTF::Vector<RecordField*> fields = jsCast<RecordPrototype*>(constructor->get(execState, execState->vm().propertyNames->prototype))->fields();
        for (RecordField* field : fields) {
            Identifier propertyName(execState, field->fieldName());
            if (object->hasProperty(execState, propertyName)) {
                JSValue fieldValue = object->get(execState, propertyName);
                if (execState->hadException()) {
                    return;
                }

                field->ffiTypeMethodTable().write(execState, fieldValue, reinterpret_cast<void*>(reinterpret_cast<char*>(buffer) + field->offset()), field->fieldType());
                if (execState->hadException()) {
                    return;
                }
            }
        }
    }
}

void RecordConstructor::postCall(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
}

bool RecordConstructor::canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return value.isObject() || value.inherits(RecordInstance::info());
}

void RecordConstructor::finishCreation(VM& vm, JSGlobalObject* globalObject, RecordPrototype* recordPrototype, const WTF::String& name, ffi_type* ffiType, RecordType recordType) {
    Base::finishCreation(vm, name.at(0) == '?' ? WTF::emptyString() : name);

    this->_ffiTypeMethodTable.ffiType = ffiType;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.write = &write;
    this->_ffiTypeMethodTable.postCall = &postCall;
    this->_ffiTypeMethodTable.canConvert = &canConvert;
    this->_recordType = recordType;

    this->putDirect(vm, vm.propertyNames->prototype, recordPrototype, DontEnum | DontDelete | ReadOnly);
    this->putDirect(vm, vm.propertyNames->length, jsNumber(1), ReadOnly | DontEnum | DontDelete);
    this->putDirectNativeFunction(vm, globalObject, Identifier(&vm, WTF::ASCIILiteral("equals")), 0, recordConstructorFuncEquals, NoIntrinsic, DontDelete | ReadOnly | Attribute::Function);

    this->_instancesStructure.set(vm, this, RecordInstance::createStructure(globalObject, recordPrototype));
}

EncodedJSValue JSC_HOST_CALL RecordConstructor::constructRecordInstance(ExecState* execState) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    RecordConstructor* constructor = jsCast<RecordConstructor*>(execState->callee());
    const ffi_type* ffiType = constructor->_ffiTypeMethodTable.ffiType;

    void* data = calloc(ffiType->size, 1);
    PointerInstance* pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState->vm(), data));
    pointer->setAdopted(true);

    RecordInstance* instance = RecordInstance::create(execState->vm(), globalObject, constructor->instancesStructure(), ffiType->size, pointer);

    if (execState->argumentCount() == 1) {
        JSValue value = execState->argument(0);

        if (PointerInstance* pointerArgument = jsDynamicCast<PointerInstance*>(value)) {
            memcpy(pointer->data(), pointerArgument->data(), ffiType->size);
        } else {
            constructor->_ffiTypeMethodTable.write(execState, value, instance->data(), constructor);
        }
    }

    return JSValue::encode(instance);
}

ConstructType RecordConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = &constructRecordInstance;
    return ConstructTypeHost;
}

EncodedJSValue JSC_HOST_CALL RecordConstructor::createRecordInstance(ExecState* execState) {
    if (execState->argumentCount() != 1) {
        return JSValue::encode(execState->vm().throwException(execState, createError(execState, WTF::ASCIILiteral("One argument required."))));
    }

    const JSValue value = execState->argument(0);
    if (!value.inherits(PointerInstance::info())) {
        const WTF::String message = WTF::String::format("Argument must be a %s.", PointerInstance::info()->className);
        return JSValue::encode(execState->vm().throwException(execState, createError(execState, message)));
    }

    PointerInstance* pointer = jsCast<PointerInstance*>(value);
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    RecordConstructor* constructor = jsCast<RecordConstructor*>(execState->callee());
    const ffi_type* ffiType = constructor->_ffiTypeMethodTable.ffiType;

    RecordInstance* instance = RecordInstance::create(execState->vm(), globalObject, constructor->instancesStructure(), ffiType->size, pointer);
    return JSValue::encode(instance);
}

CallType RecordConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &createRecordInstance;
    return CallTypeHost;
}

void RecordConstructor::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    RecordConstructor* object = jsCast<RecordConstructor*>(cell);
    visitor.append(&object->_instancesStructure);
}

RecordConstructor::~RecordConstructor() {
    delete this->_ffiTypeMethodTable.ffiType->elements;
    delete this->_ffiTypeMethodTable.ffiType;
}
}