//
//  FFIRecordType.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "Record.h"

namespace NativeScript {

using namespace JSC;

FFIRecordType::FFIRecordType(const ffi_type& type, const WTF::String& name, const RecordType recordType, const std::map<std::string, Field>& fields)
    : _name(name)
    , _recordType(recordType)
    , _fields(fields) {
    FFIType::type = &this->_type;
    this->_type = type;
}

JSValue FFIRecordType::read(ExecState* execState, const void* buffer) const {
    return createRecordInstance(execState, this->_name, this->_recordType, buffer);
}

void FFIRecordType::write(ExecState* execState, const JSValue& value, void* buffer) const {
    if (RecordInstance* record = jsDynamicCast<RecordInstance*>(value)) {
        if (this != record->ffiType()) {
            JSValue exception = createError(execState, "Different record types");
            jsCast<GlobalObject*>(execState->lexicalGlobalObject())->inspectorController().reportAPIException(execState, exception);
            WTFCrash();
        }

        memcpy(buffer, record->data(), this->type->size);
    } else {
        memset(buffer, 0, this->type->size);

        JSObject* object = jsCast<JSObject*>(value.asCell());

        for (auto it = this->_fields.begin(); it != this->_fields.end(); it++) {
            const Field* field = &it->second;

            Identifier propertyName(execState, it->first.c_str());
            if (object->hasProperty(execState, propertyName)) {
                JSValue fieldValue = object->get(execState, propertyName);
                if (execState->hadException()) {
                    return;
                }

                field->type->write(execState, fieldValue, reinterpret_cast<void*>(reinterpret_cast<char*>(buffer) + field->offset));
                if (execState->hadException()) {
                    return;
                }
            }
        }
    }
}

bool FFIRecordType::canConvert(ExecState* execState, const JSValue& value) const {
    return value.isObject() || value.inherits(RecordInstance::info());
}

FFIRecordType::~FFIRecordType() {
    // delete[] this->_type.elements;
}
}
