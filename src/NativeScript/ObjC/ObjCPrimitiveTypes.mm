//
//  ObjCSimpleTypes.mm
//  NativeScript
//
//  Created by Jason Zhekov on 10/16/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCPrimitiveTypes.h"
#include <JavaScriptCore/JSGlobalObjectInspectorController.h>
#include "ObjCTypes.h"
#include "ObjCConstructorCall.h"
#include "ObjCSuperObject.h"
#include "ObjCConstructorBase.h"
#include "ObjCProtocolWrapper.h"
#include "ObjCWrapperObject.h"
#include "Interop.h"
#include "AllocatedPlaceholder.h"

namespace NativeScript {
using namespace JSC;

#pragma mark objCInstancetype
static JSValue objCInstancetype_read(ExecState* execState, const void* buffer, JSCell* self) {
    id value = *static_cast<const id*>(buffer);
    if (value == nil) {
        return jsNull();
    }

    Structure* structure;

    if (ObjCConstructorBase* constructor = jsDynamicCast<ObjCConstructorBase*>(execState->thisValue())) {
        structure = constructor->instancesStructure();
    } else if (AllocatedPlaceholder* allocatedPlaceholder = jsDynamicCast<AllocatedPlaceholder*>(execState->thisValue())) {
        structure = allocatedPlaceholder->instanceStructure();
    } else if (ObjCWrapperObject* wrapperObject = jsDynamicCast<ObjCWrapperObject*>(execState->thisValue())) {
        structure = wrapperObject->structure();
    } else if (ObjCSuperObject* superObject = jsDynamicCast<ObjCSuperObject*>(execState->thisValue())) {
        structure = superObject->wrapperObject()->structure();
    } else {
        RELEASE_ASSERT_NOT_REACHED();
    }

    return toValue(execState, value, ^{
      return structure;
    });
}
static void objCInstancetype_write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    *static_cast<id*>(buffer) = NativeScript::toObject(execState, value);
}
static bool objCInstancetype_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return value.isNull() || value.inherits(ObjCWrapperObject::info()) || value.inherits(ObjCConstructorBase::info());
}
static const char* objCInstancetype_encode(JSC::JSCell* self) {
    return "@";
}
const FFITypeMethodTable objCInstancetypeTypeMethodTable = {
    .read = &objCInstancetype_read,
    .write = &objCInstancetype_write,
    .canConvert = &objCInstancetype_canConvert,
    .ffiType = &ffi_type_pointer,
    .encode = objCInstancetype_encode
};

#pragma mark objCProtocol
static JSValue objCProtocol_read(ExecState* execState, const void* buffer, JSCell* self) {
    Protocol* aProtocol = *static_cast<Protocol* const*>(buffer);
    if (aProtocol == nil) {
        return jsNull();
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    ObjCProtocolWrapper* protocolWrapper = globalObject->protocolWrapperFor(aProtocol);
    return protocolWrapper;
}
static void objCProtocol_write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    if (value.inherits(ObjCProtocolWrapper::info())) {
        ObjCProtocolWrapper* protocolWrapper = jsCast<ObjCProtocolWrapper*>(value);
        const Protocol* aProtocol = protocolWrapper->protocol();
        *static_cast<const Protocol**>(buffer) = aProtocol;
    } else if (value.isUndefinedOrNull()) {
        *static_cast<Protocol**>(buffer) = nullptr;
    } else {
        JSValue exception = createError(execState, WTF::ASCIILiteral("Value is not a protocol."));
        execState->vm().throwException(execState, exception);
        return;
    }
}
static bool objCProtocol_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return value.inherits(ObjCProtocolWrapper::info()) || value.isUndefinedOrNull();
}
static const char* objCProtocol_encode(JSC::JSCell* self) {
    return "@";
}
const FFITypeMethodTable objCProtocolTypeMethodTable = {
    .read = &objCProtocol_read,
    .write = &objCProtocol_write,
    .canConvert = &objCProtocol_canConvert,
    .ffiType = &ffi_type_pointer,
    .encode = objCProtocol_encode
};

#pragma mark objCClass
static JSValue objCClass_read(ExecState* execState, const void* buffer, JSCell* self) {
    Class klass = *static_cast<const Class*>(buffer);
    if (klass == Nil) {
        return jsNull();
    }

    return jsCast<GlobalObject*>(execState->lexicalGlobalObject())->constructorFor(klass);
}
static void objCClass_write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    if (value.inherits(ObjCConstructorBase::info())) {
        *static_cast<Class*>(buffer) = jsCast<ObjCConstructorBase*>(value.asCell())->klass();
    } else if (value.isUndefinedOrNull()) {
        *static_cast<Class*>(buffer) = nullptr;
    } else {
        JSValue exception = createError(execState, WTF::ASCIILiteral("Value is not a class."));
        execState->vm().throwException(execState, exception);
        return;
    }
}
static bool objCClass_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return value.inherits(ObjCConstructorBase::info()) || value.isUndefinedOrNull();
}
static const char* objCClass_encode(JSC::JSCell* self) {
    return "#";
}
const FFITypeMethodTable objCClassTypeMethodTable = {
    .read = &objCClass_read,
    .write = &objCClass_write,
    .canConvert = &objCClass_canConvert,
    .ffiType = &ffi_type_pointer,
    .encode = &objCClass_encode
};

#pragma mark objCSelector
static JSValue objCSelector_read(ExecState* execState, const void* buffer, JSCell* self) {
    const SEL sel = *static_cast<const SEL*>(buffer);
    return jsString(execState, WTF::String(sel_getName(sel)));
}
static void objCSelector_write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    if (value.isString()) {
        const SEL sel = sel_registerName(value.toString(execState)->value(execState).utf8().data());
        *static_cast<SEL*>(buffer) = sel;
    } else if (value.isUndefinedOrNull()) {
        *static_cast<SEL*>(buffer) = nullptr;
    } else {
        JSValue exception = createError(execState, WTF::ASCIILiteral("Value is not a selector."));
        execState->vm().throwException(execState, exception);
        return;
    }
}
static bool objCSelector_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return value.isString() || value.isUndefinedOrNull();
}
static const char* objCSelector_encode(JSC::JSCell* self) {
    return ":";
}
const FFITypeMethodTable objCSelectorTypeMethodTable = {
    .read = &objCSelector_read,
    .write = &objCSelector_write,
    .canConvert = &objCSelector_canConvert,
    .ffiType = &ffi_type_pointer,
    .encode = &objCSelector_encode
};
}
