//
//  ObjCSimpleTypes.mm
//  NativeScript
//
//  Created by Jason Zhekov on 10/16/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCPrimitiveTypes.h"
#include "AllocatedPlaceholder.h"
#include "Interop.h"
#include "ObjCConstructorBase.h"
#include "ObjCConstructorCall.h"
#include "ObjCProtocolWrapper.h"
#include "ObjCSuperObject.h"
#include "ObjCTypes.h"
#include "ObjCWrapperObject.h"
#include <JavaScriptCore/inspector/JSGlobalObjectInspectorController.h>

namespace NativeScript {
using namespace JSC;

#pragma mark objCInstancetype
static JSValue objCInstancetype_read(ExecState* execState, const void* buffer, JSCell* self) {
    id value = *static_cast<const id*>(buffer);
    if (value == nil) {
        return jsNull();
    }

    Structure* structure;

    VM& vm = execState->vm();
    if (ObjCConstructorBase* constructor = jsDynamicCast<ObjCConstructorBase*>(vm, execState->thisValue())) {
        structure = constructor->instancesStructure();
    } else if (AllocatedPlaceholder* allocatedPlaceholder = jsDynamicCast<AllocatedPlaceholder*>(vm, execState->thisValue())) {
        structure = allocatedPlaceholder->instanceStructure();
    } else if (ObjCWrapperObject* wrapperObject = jsDynamicCast<ObjCWrapperObject*>(vm, execState->thisValue())) {
        structure = wrapperObject->structure();
    } else if (ObjCSuperObject* superObject = jsDynamicCast<ObjCSuperObject*>(vm, execState->thisValue())) {
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
    JSC::VM& vm = execState->vm();
    return value.isNull() || value.inherits(vm, ObjCWrapperObject::info()) || value.inherits(vm, ObjCConstructorBase::info());
}
static const char* objCInstancetype_encode(JSC::VM&, JSC::JSCell* self) {
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
    VM& vm = execState->vm();
    if (value.inherits(vm, ObjCProtocolWrapper::info())) {
        ObjCProtocolWrapper* protocolWrapper = jsCast<ObjCProtocolWrapper*>(value);
        const Protocol* aProtocol = protocolWrapper->protocol();
        *static_cast<const Protocol**>(buffer) = aProtocol;
    } else if (value.isUndefinedOrNull()) {
        *static_cast<Protocol**>(buffer) = nullptr;
    } else {
        JSValue exception = createError(execState, "Value is not a protocol."_s);
        auto scope = DECLARE_THROW_SCOPE(vm);
        scope.throwException(execState, exception);
        return;
    }
}
static bool objCProtocol_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    VM& vm = execState->vm();
    return value.inherits(vm, ObjCProtocolWrapper::info()) || value.isUndefinedOrNull();
}
static const char* objCProtocol_encode(JSC::VM&, JSC::JSCell* self) {
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
    JSC::VM& vm = execState->vm();
    if (value.inherits(vm, ObjCConstructorBase::info())) {
        *static_cast<Class*>(buffer) = jsCast<ObjCConstructorBase*>(value.asCell())->klass();
    } else if (value.isUndefinedOrNull()) {
        *static_cast<Class*>(buffer) = nullptr;
    } else {
        JSValue exception = createError(execState, "Value is not a class."_s);
        auto scope = DECLARE_THROW_SCOPE(vm);
        scope.throwException(execState, exception);
        return;
    }
}
static bool objCClass_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    JSC::VM& vm = execState->vm();
    return value.inherits(vm, ObjCConstructorBase::info()) || value.isUndefinedOrNull();
}
static const char* objCClass_encode(JSC::VM&, JSC::JSCell* self) {
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
        VM& vm = execState->vm();
        auto scope = DECLARE_THROW_SCOPE(vm);
        JSValue exception = createError(execState, "Value is not a selector."_s);
        scope.throwException(execState, exception);
        return;
    }
}
static bool objCSelector_canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    return value.isString() || value.isUndefinedOrNull();
}
static const char* objCSelector_encode(JSC::VM&, JSC::JSCell* self) {
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
