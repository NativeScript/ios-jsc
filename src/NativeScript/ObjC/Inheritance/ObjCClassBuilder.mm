//
//  ObjCClassBuilder.mm
//  NativeScript
//
//  Created by Jason Zhekov on 9/8/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCClassBuilder.h"
#include <JavaScriptCore/StrongInlines.h>
#include <sstream>
#include "Metadata.h"
#include "TypeFactory.h"
#include "ObjCConstructorNative.h"
#include "ObjCConstructorDerived.h"
#include "ObjCMethodCallback.h"
#include "ObjCSuperObject.h"
#include "ObjCProtocolWrapper.h"
#include "ObjCTypes.h"
#include "FFIType.h"
#include "Interop.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

static WTF::CString generateAnonymousSubclassName(const char* className) {
    int i = 0;
    WTF::CString anonymousName;

    do {
        anonymousName = WTF::String::format("%s%d", className, ++i).utf8();
    } while (objc_getClass(anonymousName.data()));

    return anonymousName;
}

static IMP findNotOverridenMethod(Class klass, SEL method) {
    while (class_conformsToProtocol(klass, @protocol(TNSDerivedClass))) {
        klass = class_getSuperclass(klass);
    }

    return class_getMethodImplementation(klass, method);
}

static void attachDerivedMachinery(GlobalObject* globalObject, Class newKlass, JSValue superPrototype) {
    __block Class metaClass = object_getClass(newKlass);

    __block Class blockKlass = newKlass;
    IMP allocWithZone = findNotOverridenMethod(metaClass, @selector(allocWithZone:));
    IMP newAllocWithZone = imp_implementationWithBlock (^(id self, NSZone * nsZone) {
        id instance = allocWithZone(self, @selector(allocWithZone:), nsZone);
        VM& vm = globalObject->vm();
        JSLockHolder lockHolder(vm);

        Structure* instancesStructure = globalObject->constructorFor(blockKlass)->instancesStructure();
        ObjCWrapperObject* derivedWrapper = ObjCWrapperObject::create(vm, instancesStructure, instance);
        gcProtect(derivedWrapper);

        Structure* superStructure = ObjCSuperObject::createStructure(vm, globalObject, superPrototype);
        ObjCSuperObject* superObject = ObjCSuperObject::create(vm, superStructure, derivedWrapper);
        derivedWrapper->putDirect(vm, vm.propertyNames->superKeyword, superObject, ReadOnly | DontEnum | DontDelete);

        [TNSValueWrapper attachValue:derivedWrapper toHost:instance];
        return instance;
    });
    class_addMethod(metaClass, @selector(allocWithZone:), newAllocWithZone, "@@:");

    IMP retain = findNotOverridenMethod(newKlass, @selector(retain));
    IMP newRetain = imp_implementationWithBlock (^(id self) {
        if ([self retainCount] == 1) {
            if (TNSValueWrapper* wrapper = objc_getAssociatedObject(self, globalObject->JSScope::vm())) {
                JSLockHolder lockHolder(globalObject->vm());
                gcProtect(wrapper.value);
            }
        }

        return retain(self, @selector(retain));
    });
    class_addMethod(newKlass, @selector(retain), newRetain, "@@:");

    void (*release)(id, SEL) = (void (*)(id, SEL))findNotOverridenMethod(newKlass, @selector(release));
    IMP newRelease = imp_implementationWithBlock (^(id self) {
        if ([self retainCount] == 2) {
            if (TNSValueWrapper* wrapper = objc_getAssociatedObject(self, globalObject->JSScope::vm())) {
                JSLockHolder lockHolder(globalObject->vm());
                gcUnprotect(wrapper.value);
            }
        }

        release(self, @selector(release));
    });
    class_addMethod(newKlass, @selector(release), newRelease, "v@:");
}

static bool isValidType(ExecState* execState, JSValue& value) {
    const FFITypeMethodTable* table;
    if (!tryGetFFITypeMethodTable(value, &table)) {
        execState->vm().throwException(execState, createError(execState, WTF::ASCIILiteral("Invalid type")));
        return false;
    }
    return true;
}

static void addMethodToClass(ExecState* execState, Class klass, JSCell* method, MethodMeta* meta) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    std::string compilerEncoding = getCompilerEncoding(globalObject, meta);

    TypeEncoding* encodings = meta->encodings()->first();

    JSCell* returnTypeCell = globalObject->typeFactory()->parseType(globalObject, encodings);
    const WTF::Vector<JSCell*> parameterTypesCells = globalObject->typeFactory()->parseTypes(globalObject, encodings, meta->encodings()->_count - 1);

    ObjCMethodCallback* callback = ObjCMethodCallback::create(execState->vm(), globalObject, globalObject->objCMethodCallbackStructure(), method, returnTypeCell, parameterTypesCells);
    gcProtect(callback);
    if (!class_addMethod(klass, meta->selector(), reinterpret_cast<IMP>(callback->functionPointer()), compilerEncoding.c_str())) {
        WTFCrash();
    }
}

static void addMethodToClass(ExecState* execState, Class klass, JSCell* method, SEL methodName, JSValue& typeEncoding) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    CallData callData;
    if (method->methodTable()->getCallData(method, callData) == CallTypeNone) {
        WTF::String message = WTF::String::format("Method %s is not a function.", sel_getName(methodName));
        execState->vm().throwException(execState, createError(execState, message));
        return;
    }
    if (!typeEncoding.isObject()) {
        WTF::String message = WTF::String::format("Method %s has invalid type encoding", sel_getName(methodName));
        execState->vm().throwException(execState, createError(execState, message));
        return;
    }

    JSObject* typeEncodingObj = asObject(typeEncoding);
    PropertyName returnsProp = Identifier(execState, WTF::ASCIILiteral("returns"));
    if (!typeEncodingObj->hasOwnProperty(execState, returnsProp)) {
        WTF::String message = WTF::String::format("Method %s is missing its return type encoding", sel_getName(methodName));
        execState->vm().throwException(execState, createError(execState, message));
        return;
    }

    std::stringstream compilerEncoding;

    JSValue returnTypeValue = typeEncodingObj->get(execState, returnsProp);
    if (execState->hadException() || !isValidType(execState, returnTypeValue)) {
        return;
    }

    compilerEncoding << getCompilerEncoding(returnTypeValue.asCell());
    compilerEncoding << "@:"; // id self, SEL _cmd

    JSValue parameterTypesValue = typeEncodingObj->get(execState, Identifier(execState, WTF::ASCIILiteral("params")));
    if (execState->hadException()) {
        return;
    }

    WTF::Vector<JSCell*> parameterTypesCells;
    JSArray* parameterTypesArr = jsDynamicCast<JSArray*>(parameterTypesValue);
    if (parameterTypesArr) {
        for (unsigned int i = 0; i < parameterTypesArr->length(); ++i) {
            JSValue parameterType = parameterTypesArr->get(execState, i);
            if (execState->hadException() || !isValidType(execState, parameterType)) {
                return;
            }

            parameterTypesCells.append(parameterType.asCell());
            compilerEncoding << getCompilerEncoding(parameterType.asCell());
        }
    }

    ObjCMethodCallback* callback = ObjCMethodCallback::create(execState->vm(), globalObject, globalObject->objCMethodCallbackStructure(), method, returnTypeValue.asCell(), parameterTypesCells);
    gcProtect(callback);
    if (!class_addMethod(klass, methodName, reinterpret_cast<IMP>(callback->functionPointer()), compilerEncoding.str().c_str())) {
        WTFCrash();
    }
}

ObjCClassBuilder::ObjCClassBuilder(ExecState* execState, JSValue baseConstructor, JSObject* prototype, const WTF::String& className) {
    // TODO: Inherit from derived constructor.
    if (!baseConstructor.inherits(ObjCConstructorNative::info())) {
        execState->vm().throwException(execState, createError(execState, WTF::ASCIILiteral("Extends is supported only for native classes.")));
        return;
    }

    this->_baseConstructor = Strong<ObjCConstructorNative>(execState->vm(), jsCast<ObjCConstructorNative*>(baseConstructor));

    WTF::CString classNameUTF8;
    if (className.isEmpty()) {
        classNameUTF8 = generateAnonymousSubclassName(this->_baseConstructor->metadata()->name());
    } else if (!objc_getClass(className.utf8().data())) {
        classNameUTF8 = className.utf8();
    } else {
        WTF::String errorMessage = WTF::String::format("The desired name is already in use: \"%s\".", className.utf8().data());
        execState->vm().throwException(execState, createError(execState, errorMessage));
        return;
    }

    Class klass = objc_allocateClassPair(this->_baseConstructor->klass(), classNameUTF8.data(), 0);
    class_addProtocol(klass, @protocol(TNSDerivedClass));
    class_addProtocol(object_getClass(klass), @protocol(TNSDerivedClass));

    JSValue basePrototype = this->_baseConstructor->get(execState, execState->vm().propertyNames->prototype);
    prototype->setPrototype(execState->vm(), basePrototype);

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    Structure* structure = ObjCConstructorDerived::createStructure(execState->vm(), globalObject, this->_baseConstructor.get());
    ObjCConstructorDerived* derivedConstructor = ObjCConstructorDerived::create(execState->vm(), globalObject, structure, prototype, klass, this->_baseConstructor.get());

    prototype->putDirect(execState->vm(), execState->vm().propertyNames->constructor, derivedConstructor, DontEnum);

    this->_constructor = Strong<ObjCConstructorDerived>(execState->vm(), derivedConstructor);
}

void ObjCClassBuilder::implementProtocol(ExecState* execState, JSValue protocolWrapper) {
    if (!protocolWrapper.inherits(ObjCProtocolWrapper::info())) {
        WTF::String errorMessage = WTF::String::format("Protocol \"%s\" is not a protocol object.", protocolWrapper.toWTFString(execState).utf8().data());
        execState->vm().throwException(execState, createError(execState, errorMessage));
        return;
    }

    ObjCProtocolWrapper* protocolWrapperObject = jsCast<ObjCProtocolWrapper*>(protocolWrapper);

    this->_protocols.push_back(protocolWrapperObject->metadata());

    if (Protocol* aProtocol = protocolWrapperObject->protocol()) {
        Class klass = this->_constructor.get()->klass();
        if ([klass conformsToProtocol:aProtocol]) {
            WTF::String errorMessage = WTF::String::format("Class \"%s\" already implements the \"%s\" protocol.", class_getName(klass), protocol_getName(aProtocol));
            warn(execState, errorMessage);
        } else {
            class_addProtocol(klass, aProtocol);
            class_addProtocol(object_getClass(klass), aProtocol);
        }
    }
}

void ObjCClassBuilder::implementProtocols(ExecState* execState, JSValue protocolsArray) {
    if (protocolsArray.isUndefinedOrNull()) {
        return;
    }

    if (!protocolsArray.inherits(JSArray::info())) {
        execState->vm().throwException(execState, createError(execState, WTF::ASCIILiteral("The protocols property must be an array")));
        return;
    }

    uint32_t length = protocolsArray.get(execState, execState->propertyNames().length).toUInt32(execState);
    for (uint32_t i = 0; i < length; i++) {
        JSValue protocolWrapper = protocolsArray.get(execState, i);
        this->implementProtocol(execState, protocolWrapper);

        if (execState->hadException()) {
            return;
        }
    }
}

void ObjCClassBuilder::addInstanceMethod(ExecState* execState, const Identifier& jsName, JSCell* method) {
    WTF::StringImpl* methodName = jsName.impl();
    const InterfaceMeta* currentClass = this->_baseConstructor->metadata();
    MethodMeta* methodMeta = nullptr;

    do {
        methodMeta = currentClass->instanceMethod(methodName);
        currentClass = currentClass->baseMeta();
    } while (!methodMeta && currentClass);

    if (!methodMeta && !this->_protocols.empty()) {
        for (const ProtocolMeta* aProtocol : this->_protocols) {
            if ((methodMeta = aProtocol->instanceMethod(methodName))) {
                break;
            }
        }
    }

    if (methodMeta) {
        Class klass = this->_constructor.get()->klass();
        addMethodToClass(execState, klass, method, methodMeta);
    }
}

void ObjCClassBuilder::addInstanceMethod(ExecState* execState, const Identifier& jsName, JSCell* method, JSC::JSValue& typeEncoding) {
    Class klass = this->_constructor.get()->klass();
    SEL methodName = sel_registerName(jsName.utf8().data());
    addMethodToClass(execState, klass, method, methodName, typeEncoding);
}

void ObjCClassBuilder::addProperty(ExecState* execState, const Identifier& name, const PropertyDescriptor& propertyDescriptor) {
    if (!propertyDescriptor.isAccessorDescriptor()) {
        WTFCrash();
    }

    WTF::StringImpl* propertyName = name.impl();
    const InterfaceMeta* currentClass = this->_baseConstructor->metadata();
    PropertyMeta* propertyMeta = nullptr;
    do {
        propertyMeta = currentClass->property(propertyName);
        currentClass = currentClass->baseMeta();
    } while (!propertyMeta && currentClass);

    if (!propertyMeta && !this->_protocols.empty()) {
        for (const ProtocolMeta* aProtocol : this->_protocols) {
            if ((propertyMeta = aProtocol->property(propertyName))) {
                break;
            }
        }
    }

    if (propertyMeta) {
        Class klass = this->_constructor.get()->klass();
        GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
        VM& vm = globalObject->vm();

        if (MethodMeta* getter = propertyMeta->getter()) {
            TypeEncoding* encodings = getter->encodings()->first();
            JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, encodings);
            const WTF::Vector<JSCell*> parameterTypes = globalObject->typeFactory()->parseTypes(globalObject, encodings, getter->encodings()->_count - 1);

            ObjCMethodCallback* getterCallback = ObjCMethodCallback::create(vm, globalObject, globalObject->objCMethodCallbackStructure(), propertyDescriptor.getter().asCell(), returnType, parameterTypes);
            gcProtect(getterCallback);
            std::string compilerEncoding = getCompilerEncoding(globalObject, getter);
            if (!class_addMethod(klass, getter->selector(), reinterpret_cast<IMP>(getterCallback->functionPointer()), compilerEncoding.c_str())) {
                WTFCrash();
            }
        }

        if (MethodMeta* setter = propertyMeta->setter()) {
            TypeEncoding* encodings = setter->encodings()->first();
            JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, encodings);
            const WTF::Vector<JSCell*> parameterTypes = globalObject->typeFactory()->parseTypes(globalObject, encodings, setter->encodings()->_count - 1);

            ObjCMethodCallback* setterCallback = ObjCMethodCallback::create(vm, globalObject, globalObject->objCMethodCallbackStructure(), propertyDescriptor.setter().asCell(), returnType, parameterTypes);
            gcProtect(setterCallback);
            std::string compilerEncoding = getCompilerEncoding(globalObject, setter);
            if (!class_addMethod(klass, setter->selector(), reinterpret_cast<IMP>(setterCallback->functionPointer()), compilerEncoding.c_str())) {
                WTFCrash();
            }
        }

        // TODO: class_addProperty
    }
}

void ObjCClassBuilder::addInstanceMembers(ExecState* execState, JSObject* instanceMethods, JSValue exposedMethods) {
    PropertyNameArray prototypeKeys(execState);
    instanceMethods->methodTable()->getOwnPropertyNames(instanceMethods, execState, prototypeKeys, ExcludeDontEnumProperties);

    for (Identifier key : prototypeKeys) {
        PropertySlot propertySlot(instanceMethods);

        if (!instanceMethods->methodTable()->getOwnPropertySlot(instanceMethods, execState, key, propertySlot)) {
            continue;
        }

        if (propertySlot.isAccessor()) {
            PropertyDescriptor propertyDescriptor;
            propertyDescriptor.setAccessorDescriptor(propertySlot.getterSetter(), propertySlot.attributes());

            this->addProperty(execState, key, propertyDescriptor);
        } else if (propertySlot.isValue()) {
            JSValue method = propertySlot.getValue(execState, key);
            if (method.isCell()) {
                JSValue encodingValue = jsUndefined();
                if (!exposedMethods.isUndefinedOrNull()) {
                    encodingValue = exposedMethods.get(execState, key);
                }
                if (encodingValue.isUndefined()) {
                    this->addInstanceMethod(execState, key, method.asCell());
                } else {
                    this->addInstanceMethod(execState, key, method.asCell(), encodingValue);
                }
            }
        } else {
            WTFCrash();
        }

        if (execState->hadException()) {
            return;
        }
    }

    if (exposedMethods.isObject()) {
        PropertyNameArray exposedMethodsKeys(execState);
        JSObject* exposedMethodsObject = exposedMethods.toObject(execState);
        exposedMethodsObject->methodTable()->getOwnPropertyNames(exposedMethodsObject, execState, exposedMethodsKeys, ExcludeDontEnumProperties);

        for (Identifier key : exposedMethodsKeys) {
            if (!instanceMethods->hasOwnProperty(execState, key)) {
                WTF::String errorMessage = WTF::String::format("No implementation found for exposed method \"%s\".", key.string().utf8().data());
                warn(execState, errorMessage);
            }
        }
    }
}

void ObjCClassBuilder::addStaticMethod(ExecState* execState, const Identifier& jsName, JSCell* method) {
    WTF::StringImpl* methodName = jsName.impl();
    const InterfaceMeta* currentClass = this->_baseConstructor->metadata();
    MethodMeta* methodMeta = nullptr;

    do {
        methodMeta = currentClass->staticMethod(methodName);
        currentClass = currentClass->baseMeta();
    } while (!methodMeta && currentClass);

    if (!methodMeta && !this->_protocols.empty()) {
        for (const ProtocolMeta* aProtocol : this->_protocols) {
            if ((methodMeta = aProtocol->staticMethod(methodName))) {
                break;
            }
        }
    }

    if (methodMeta) {
        Class klass = object_getClass(this->_constructor.get()->klass());
        addMethodToClass(execState, klass, method, methodMeta);
    }
}

void ObjCClassBuilder::addStaticMethod(ExecState* execState, const Identifier& jsName, JSCell* method, JSC::JSValue& typeEncoding) {
    Class klass = object_getClass(this->_constructor.get()->klass());
    SEL methodName = sel_registerName(jsName.utf8().data());
    addMethodToClass(execState, klass, method, methodName, typeEncoding);
}

void ObjCClassBuilder::addStaticMethods(ExecState* execState, JSObject* staticMethods) {
    PropertyNameArray keys(execState);
    staticMethods->methodTable()->getOwnPropertyNames(staticMethods, execState, keys, ExcludeDontEnumProperties);

    for (Identifier key : keys) {
        PropertySlot propertySlot(staticMethods);

        if (!staticMethods->methodTable()->getOwnPropertySlot(staticMethods, execState, key, propertySlot)) {
            continue;
        }

        if (propertySlot.isValue()) {
            JSValue method = propertySlot.getValue(execState, key);
            if (method.isCell()) {
                this->addStaticMethod(execState, key, method.asCell());
            }
        } else {
            WTFCrash();
        }

        if (execState->hadException()) {
            return;
        }
    }
}

ObjCConstructorDerived* ObjCClassBuilder::build(ExecState* execState) {
    Class klass = this->_constructor.get()->klass();

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    objc_registerClassPair(klass);
    globalObject->_objCConstructors.insert(std::pair<Class, Strong<ObjCConstructorBase>>(klass, Strong<ObjCConstructorBase>(execState->vm(), this->_constructor.get())));
    attachDerivedMachinery(globalObject, klass, this->_baseConstructor->get(execState, globalObject->vm().propertyNames->prototype));

    return this->_constructor.get();
}
}
