//
//  ObjCConstructor.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 17.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "ObjCConstructorBase.h"
#include "AllocatedPlaceholder.h"
#include "Interop.h"
#include "Metadata/Metadata.h"
#include "ObjCConstructorCall.h"
#include "ObjCConstructorDerived.h"
#include "ObjCConstructorNative.h"
#include "ObjCMethodCall.h"
#include "ObjCPrototype.h"
#include "ObjCTypes.h"
#include "ObjCWrapperObject.h"
#include "PointerInstance.h"
#include <JavaScriptCore/Identifier.h>
#include <JavaScriptCore/JSArrayBuffer.h>
#include <JavaScriptCore/JSMap.h>
#include <wtf/text/StringBuilder.h>

#import "IsObjcObject.h"
#import "TNSArrayAdapter.h"
#import "TNSDataAdapter.h"
#import "TNSDictionaryAdapter.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCConstructorBase::s_info = { "Function", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCConstructorBase) };

const unsigned ObjCConstructorBase::StructureFlags = OverridesGetOwnPropertySlot | Base::StructureFlags;

// TODO: Use the current class in finish creation
JSValue ObjCConstructorBase::read(ExecState* execState, void const* buffer, JSCell* self) {
    ObjCConstructorBase* type = jsCast<ObjCConstructorBase*>(self);
    id value = *static_cast<const id*>(buffer);
    value = IsObjcObject(value) ? value : nil;
    return toValue(execState, value, type->klasses().known, type->additionalProtocols());
}

void ObjCConstructorBase::write(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    *static_cast<id*>(buffer) = NativeScript::toObject(execState, value);
}

template <typename TAdapter>
static void writeAdapter(ExecState* execState, const JSValue& value, void* buffer, JSCell* self) {
    VM& vm = execState->vm();
    if (ObjCWrapperObject* wrapper = jsDynamicCast<ObjCWrapperObject*>(vm, value)) {
        *static_cast<id*>(buffer) = wrapper->wrappedObject();
    } else if (JSObject* object = jsDynamicCast<JSObject*>(vm, value)) {
        *static_cast<id*>(buffer) = [[[TAdapter alloc] initWithJSObject:object
                                                              execState:execState->lexicalGlobalObject()->globalExec()] autorelease];
    } else {
        *static_cast<id*>(buffer) = nil;
    }
}

bool ObjCConstructorBase::canConvert(ExecState* execState, const JSValue& value, JSCell* self) {
    ObjCConstructorBase* type = jsCast<ObjCConstructorBase*>(self);
    VM& vm = execState->vm();
    Class klass = type->klasses().known;

    // FFI calls and their arguments are parsed from existing metadata and as such
    // they should never contain an `unknown` class.
    ASSERT(type->klasses().unknown == nullptr);
    ASSERT(klass != nullptr);

    if (!klass || value.isUndefinedOrNull()) {
        return true;
    }

    if (value.inherits(vm, ObjCWrapperObject::info())) {
        return [jsCast<ObjCWrapperObject*>(value.asCell())->wrappedObject() isKindOfClass:klass];
    }

    if (value.isString()) {
        return [klass isSubclassOfClass:[NSString class]];
    }

    if (value.isNumber() || value.isBoolean()) {
        return [klass isSubclassOfClass:[NSNumber class]];
    }

    if (value.inherits(vm, JSArray::info())) {
        return [klass isSubclassOfClass:[NSArray class]];
    }

    if (value.inherits(vm, JSMap::info())) {
        return [klass isSubclassOfClass:[NSDictionary class]];
    }

    if (value.inherits(vm, JSArrayBuffer::info()) || value.inherits(vm, JSArrayBufferView::info())) {
        return [klass isSubclassOfClass:[NSData class]];
    }

    return false;
}

const char* ObjCConstructorBase::encode(VM&, JSCell* cell) {
    return "@";
}

ObjCPrototype* ObjCConstructorBase::getObjCPrototype() const {
    JSObject* proto = this->_prototype.get();
    ObjCPrototype* objcPrototype = nullptr;
    VM& vm = *this->vm();
    while (proto && !(objcPrototype = jsDynamicCast<ObjCPrototype*>(vm, proto))) {
        proto = jsDynamicCast<JSObject*>(vm, proto->getPrototypeDirect(vm));
    }
    return objcPrototype;
}

const Metadata::InterfaceMeta* ObjCConstructorBase::metadata() {
    if (this->_metadata == nullptr) {
        ObjCPrototype* objcPrototype = this->getObjCPrototype();
        ASSERT(objcPrototype != nullptr);
        const Metadata::BaseClassMeta* metadata = objcPrototype->metadata();

        ASSERT(metadata->type() == Metadata::MetaType::Interface);
        this->_metadata = static_cast<const Metadata::InterfaceMeta*>(metadata);
    }
    return this->_metadata;
}

void ObjCConstructorBase::finishCreation(VM& vm,
                                         JSGlobalObject* globalObject,
                                         JSObject* prototype,
                                         const ConstructorKey& key) {
    Base::finishCreation(vm, class_getName(key.klasses.known));

    WTF::String __constructorDescription("Known class: ");
    __constructorDescription.append(class_getName(key.klasses.known));
    if (key.klasses.unknown) {
        __constructorDescription.append(" Unknown class: ");
        __constructorDescription.append(class_getName(key.klasses.unknown));
    }

    if (key.additionalProtocols.size()) {
        __constructorDescription.append(" Additional protocols:");
        for (auto proto : key.additionalProtocols) {
            __constructorDescription.append(" ");
            __constructorDescription.append(proto->name());
        }
    }
    putDirect(vm, Identifier::fromString(&vm, "__constructorDescription"), jsString(&vm, __constructorDescription), PropertyAttribute::ReadOnly | PropertyAttribute::DontEnum);

    this->_prototype.set(vm, this, prototype);
    this->_instancesStructure.set(vm, this, ObjCWrapperObject::createStructure(vm, globalObject, prototype));

    this->_key = key;
    this->_metadata = nullptr;

    this->_ffiTypeMethodTable.ffiType = &ffi_type_pointer;
    this->_ffiTypeMethodTable.read = &read;
    this->_ffiTypeMethodTable.canConvert = &canConvert;
    this->_ffiTypeMethodTable.encode = &encode;

    if (this->klasses().known == [NSArray class]) {
        this->_ffiTypeMethodTable.write = &writeAdapter<TNSArrayAdapter>;
    } else if (this->klasses().known == [NSDictionary class]) {
        this->_ffiTypeMethodTable.write = &writeAdapter<TNSDictionaryAdapter>;
    } else if (this->klasses().known == [NSData class] || this->klasses().known == [NSMutableData class]) {
        this->_ffiTypeMethodTable.write = &writeAdapter<TNSDataAdapter>;
    } else {
        this->_ffiTypeMethodTable.write = &write;
    }
}

WTF::String ObjCConstructorBase::className(const JSObject* object, VM& vm) {
    auto name = object->getDirect(vm, vm.propertyNames->name);
    ASSERT(name.isString());
    auto global = object->globalObject(vm);
    return name.toWTFString(global->globalExec()) + "Constructor";
}

bool ObjCConstructorBase::getOwnPropertySlot(JSObject* object, ExecState* execState, PropertyName propertyName, PropertySlot& propertySlot) {
    if (Base::getOwnPropertySlot(object, execState, propertyName, propertySlot)) {
        return true;
    }

    if (propertyName == execState->vm().propertyNames->prototype) {
        ObjCConstructorBase* constructor = jsCast<ObjCConstructorBase*>(object);
        propertySlot.setValue(object, static_cast<unsigned>(PropertyAttribute::None), constructor->_prototype.get());
        return true;
    }

    return false;
}

const WTF::Vector<WriteBarrier<ObjCConstructorWrapper>>& ObjCConstructorBase::initializers(VM& vm, GlobalObject* globalObject) {
    if (this->_initializers.size() == 0) {
        JSC::DeferGCForAWhile deferGC(vm.heap);
        const Metadata::InterfaceMeta* metadata = this->metadata();

        do {
            std::vector<const Metadata::MethodMeta*> initializers = metadata->initializersWithProtocols(this->klasses(), this->additionalProtocols());
            for (const Metadata::MethodMeta* method : initializers) {
                auto constructorWrapper = ObjCConstructorWrapper::create(vm, globalObject, globalObject->objCConstructorWrapperStructure(), this->klasses().realClass(), method);
                this->_initializers.append(WriteBarrier<ObjCConstructorWrapper>(vm, this, constructorWrapper.get()));
            }

            metadata = metadata->baseMeta();

        } while (metadata);
    }

    return this->_initializers;
}

void ObjCConstructorBase::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);
    ObjCConstructorBase* constructor = jsCast<ObjCConstructorBase*>(cell);
    visitor.append(constructor->_prototype);
    visitor.append(constructor->_instancesStructure);
    visitor.append(constructor->_initializers.begin(), constructor->_initializers.end());
}

static JSValue getInitializerForSwiftStyleConstruction(ExecState* execState, ObjCConstructorBase* constructor, JSFinalObject* initializer, MarkedArgumentBuffer& arguments) {
    PropertyNameArray properties(&execState->vm(), PropertyNameMode::Strings, PrivateSymbolMode::Include);
    initializer->getOwnPropertyNames(initializer, execState, properties, EnumerationMode(DontEnumPropertiesMode::Exclude, JSObjectPropertiesMode::Include));
    if (properties.size() == 0) {
        return JSValue();
    }

    VM& vm = execState->vm();
    WTF::StringBuilder builder;
    builder.reserveCapacity(32);
    for (size_t i = 0; i < properties.size(); i++) {
        JSC::Identifier property = properties[i];
        builder.append(property.string());
        builder.append(':');
        arguments.append(initializer->getDirect(vm, property));
    }

    const WTF::CString ctorMetadata = builder.toString().utf8();
    const Metadata::InterfaceMeta* interface = constructor->metadata();
    const Metadata::MethodMeta* result = nullptr;
    std::vector<const Metadata::MethodMeta*> initializers;
    initializers.reserve(16);
    do {
        interface->initializersWithProtocols(initializers, constructor->klasses(), constructor->additionalProtocols());
        for (const Metadata::MethodMeta* method : initializers) {
            if (strcmp(method->constructorTokens(), ctorMetadata.data()) == 0) {
                result = method;
                break;
            }
        }
        initializers.clear();
        interface = interface->baseMeta();
    } while (interface && !result);

    if (result) {
        JSValue prototype = constructor->instancesStructure()->storedPrototype();
        JSValue value = prototype.get(execState, Identifier::fromString(execState, WTF::String(result->jsName())));
        if (value.isCell()) {
            return value;
        }
    }

    return JSValue();
}

EncodedJSValue JSC_HOST_CALL ObjCConstructorBase::constructObjCClass(ExecState* execState) {
    ObjCConstructorBase* constructor = jsCast<ObjCConstructorBase*>(execState->callee().asCell());
    JSC::VM& vm = execState->vm();

    /// TODO: Revisit and decide if we need to have separate channels for cases without and with arguments.
    if (execState->argumentCount() <= 1) {
        MarkedArgumentBuffer initializerArguments;
        JSValue initializer;
        if (JSFinalObject* argument = jsDynamicCast<JSFinalObject*>(vm, execState->argument(0))) {
            initializer = getInitializerForSwiftStyleConstruction(execState, constructor, argument, initializerArguments);
        } else if (execState->argumentCount() == 0) {
            initializer = constructor->instancesStructure()->storedPrototype().get(execState, Identifier::fromString(execState, "init"));
        }

        if (initializer && initializer.isCell()) {
            auto scope = DECLARE_CATCH_SCOPE(vm);
            CallData callData;
            CallType callType = JSC::getCallData(execState->vm(), initializer, callData);
            ASSERT(callType != CallType::None);

            if (initializerArguments.size() == 1 && initializerArguments.at(0).isUndefined()) {
                // methods such as -[MDLTransform initWithIdentity] are called as new MDLTransform({ identity: void 0 })
                // check to see if the method takes zero arguments and empty the arguments buffer
                if (initializer.get(execState, execState->vm().propertyNames->length).asInt32() == 0) {
                    initializerArguments.clear();
                }
            }

            ObjCConstructorBase* newTarget = jsCast<ObjCConstructorBase*>(execState->newTarget());
            id instance = [newTarget->klasses().known alloc];
            if (scope.exception()) {
                // When allocating a JS Derived native instance, it is possible to throw a JS exception.
                // Discard the native instance and do not call an initializer for it.
                return JSValue::encode(jsUndefined());
            }

            JSValue thisValue;
            Strong<AllocatedPlaceholder> allocatedPlaceHolder;
            if (ObjCConstructorNative* nativeConstructor = jsDynamicCast<ObjCConstructorNative*>(vm, constructor)) {
                allocatedPlaceHolder = AllocatedPlaceholder::create(vm, jsCast<GlobalObject*>(execState->lexicalGlobalObject()), nativeConstructor->allocatedPlaceholderStructure(), instance, constructor->instancesStructure());
                thisValue = allocatedPlaceHolder.get();
                // No release -> give ownership to AllocatedPlaceholder, it will be relinquished after the init call in ObjCMethodWrapper::postInvocation
            } else {
                thisValue = NativeScript::toValue(execState, instance, ^{
                  return constructor->instancesStructure();
                });
                // Now owned by the wrapper created in toValue
                [instance release];
            }

            return JSValue::encode(JSC::call(execState, initializer.asCell(), callType, callData, thisValue, initializerArguments));
        }
    }

    WTF::Vector<ObjCConstructorWrapper*> candidateInitializers;

    for (WriteBarrier<ObjCConstructorWrapper> initializer : constructor->initializers(vm, jsCast<GlobalObject*>(execState->lexicalGlobalObject()))) {
        if (initializer->canInvoke(execState)) {
            candidateInitializers.append(initializer.get());
        }
    }

    auto scope = DECLARE_THROW_SCOPE(vm);

    if (candidateInitializers.size() == 0) {
        return JSValue::encode(scope.throwException(execState, createError(execState, "No initializer found that matches constructor invocation."_s, defaultSourceAppender)));
    } else if (candidateInitializers.size() > 1) {
        WTF::StringBuilder errorMessage;
        errorMessage.append("More than one initializer found that matches constructor invocation:");
        for (ObjCConstructorWrapper* initializer : candidateInitializers) {
            errorMessage.append(" ");
            errorMessage.append(sel_getName(static_cast<ObjCConstructorCall*>(initializer->onlyFuncInContainer())->selector()));
        }
        return JSValue::encode(scope.throwException(execState, createError(execState, errorMessage.toString(), defaultSourceAppender)));
    } else {
        ObjCConstructorWrapper* initializer = candidateInitializers[0];

        CallData callData;
        CallType callType = initializer->methodTable(vm)->getCallData(initializer, callData);
        return JSValue::encode(call(execState, initializer, callType, callData, constructor, execState));
    }
}

EncodedJSValue JSC_HOST_CALL ObjCConstructorBase::createObjCClass(ExecState* execState) {
    JSValue argument = execState->argument(0);

    bool hasHandle;
    JSC::VM& vm = execState->vm();
    void* handle = tryHandleofValue(vm, argument, &hasHandle);
    if (!handle) {
        auto scope = DECLARE_THROW_SCOPE(vm);

        WTF::String message = WTF::String::format("Value must be a %s.", PointerInstance::info()->className);
        return throwVMError(execState, scope, createError(execState, message));
    }

    ObjCConstructorBase* constructor = jsCast<ObjCConstructorBase*>(execState->callee().asCell());
    JSValue result = toValue(execState, static_cast<id>(handle), ^Structure* {
      return constructor->instancesStructure();
    });
    return JSValue::encode(result);
}
}
