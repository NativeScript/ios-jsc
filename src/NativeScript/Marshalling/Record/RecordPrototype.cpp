//
//  RecordPrototype.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 9/29/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "RecordPrototype.h"
#include "RecordConstructor.h"
#include "RecordField.h"
#include "RecordInstance.h"
#include "RecordPrototypeFunctions.h"
#include <JavaScriptCore/ObjectConstructor.h>

namespace NativeScript {
using namespace JSC;

const ClassInfo RecordPrototype::s_info = { "record", &Base::s_info, 0, CREATE_METHOD_TABLE(RecordPrototype) };

static EncodedJSValue JSC_HOST_CALL recordProtoFuncToString(ExecState* execState) {
    RecordInstance* record = jsCast<RecordInstance*>(execState->thisValue());
    RecordConstructor* recordConstructor = jsCast<RecordConstructor*>(record->get(execState, execState->vm().propertyNames->constructor));

    const RecordType type = recordConstructor->recordType();
    const char* typeName = type == RecordType::Struct ? "struct" : type == RecordType::Union ? "union" : "record";
    CString name = recordConstructor->name(execState).utf8();

    return JSValue::encode(jsString(execState, WTF::String::format("<%s %s: %p>", typeName, name.data(), record->data())));
}

static EncodedJSValue JSC_HOST_CALL recordProtoFuncToJSON(ExecState* execState) {
    RecordInstance* record = jsCast<RecordInstance*>(execState->thisValue());
    RecordPrototype* recordPrototype = jsCast<RecordPrototype*>(record->prototype());

    JSObject* result = constructEmptyObject(execState);

    for (RecordField* field : recordPrototype->fields()) {
        const Identifier fieldName = Identifier::fromString(execState, field->fieldName());
        JSValue fieldValue = record->get(execState, fieldName);
        result->putDirect(execState->vm(), fieldName, fieldValue);
    }

    return JSValue::encode(result);
}

void RecordPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->toString, 0, recordProtoFuncToString, NoIntrinsic, DontEnum);
    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->toJSON, 0, recordProtoFuncToJSON, NoIntrinsic, DontEnum);
}

void RecordPrototype::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);

    RecordPrototype* object = jsCast<RecordPrototype*>(cell);
    visitor.append(object->_fields.begin(), object->_fields.end());
}

void RecordPrototype::setFields(VM& vm, GlobalObject* globalObject, const WTF::Vector<RecordField*>& fields) {
    for (RecordField* field : fields) {
        this->_fields.append(WriteBarrier<RecordField>(vm, this, field));

        PropertyDescriptor descriptor;
        descriptor.setEnumerable(true);

        RecordProtoFieldGetter* getter = RecordProtoFieldGetter::create(vm, globalObject->recordFieldGetterStructure(), field);
        descriptor.setGetter(getter);

        RecordProtoFieldSetter* setter = RecordProtoFieldSetter::create(vm, globalObject->recordFieldSetterStructure(), field);
        descriptor.setSetter(setter);

        Base::defineOwnProperty(this, globalObject->globalExec(), Identifier::fromString(&vm, field->fieldName()), descriptor, false);
    }
}
}
