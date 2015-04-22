//
//  RecordPrototypeFunctions.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/13/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "RecordPrototypeFunctions.h"
#include "RecordField.h"
#include "RecordInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo RecordProtoFieldSetter::s_info = { "RecordProtoFieldSetter", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(RecordProtoFieldSetter) };

void RecordProtoFieldSetter::finishCreation(VM& vm, RecordField* field) {
    Base::finishCreation(vm, WTF::emptyString());

    this->_recordField.set(vm, this, field);
    this->putDirect(vm, vm.propertyNames->length, jsNumber(1), ReadOnly | DontEnum | DontDelete);
}

static EncodedJSValue JSC_HOST_CALL recordProtoFuncFieldSetter(ExecState* execState) {
    RecordProtoFieldSetter* setter = jsCast<RecordProtoFieldSetter*>(execState->callee());
    RecordInstance* record = jsCast<RecordInstance*>(execState->thisValue());
    void* data = record->data();

    RecordField* recordField = setter->recordField();
    ptrdiff_t fieldOffset = recordField->offset();
    JSCell* fieldType = recordField->fieldType();

    void* buffer = reinterpret_cast<void*>(reinterpret_cast<char*>(data) + fieldOffset);
    recordField->ffiTypeMethodTable().write(execState, execState->argument(0), buffer, fieldType);
    return JSValue::encode(jsUndefined());
}

CallType RecordProtoFieldSetter::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = recordProtoFuncFieldSetter;
    return CallTypeHost;
}

void RecordProtoFieldSetter::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    RecordProtoFieldSetter* object = jsCast<RecordProtoFieldSetter*>(cell);
    visitor.append(&object->_recordField);
}

const ClassInfo RecordProtoFieldGetter::s_info = { "RecordProtoFieldGetter", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(RecordProtoFieldGetter) };

void RecordProtoFieldGetter::finishCreation(VM& vm, RecordField* fieldMetadata) {
    Base::finishCreation(vm, WTF::emptyString());

    this->_recordField.set(vm, this, fieldMetadata);
    this->putDirect(vm, vm.propertyNames->length, jsNumber(0), ReadOnly | DontEnum | DontDelete);
}

static EncodedJSValue JSC_HOST_CALL recordProtoFuncFieldGetter(ExecState* execState) {
    RecordProtoFieldGetter* getter = jsCast<RecordProtoFieldGetter*>(execState->callee());
    RecordInstance* record = jsCast<RecordInstance*>(execState->thisValue());
    void* data = record->data();

    RecordField* recordField = getter->recordField();
    ptrdiff_t fieldOffset = recordField->offset();
    JSCell* fieldType = recordField->fieldType();

    const void* buffer = reinterpret_cast<void*>(reinterpret_cast<char*>(data) + fieldOffset);
    JSValue value = recordField->ffiTypeMethodTable().read(execState, buffer, fieldType);
    return JSValue::encode(value);
}

CallType RecordProtoFieldGetter::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = recordProtoFuncFieldGetter;
    return CallTypeHost;
}

void RecordProtoFieldGetter::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    RecordProtoFieldGetter* object = jsCast<RecordProtoFieldGetter*>(cell);
    visitor.append(&object->_recordField);
}
}