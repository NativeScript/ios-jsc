//
//  ObjCPrototype.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 17.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "ObjCPrototype.h"
#include "Interop.h"
#include "Metadata.h"
#include "ObjCConstructorBase.h"
#include "ObjCFastEnumerationIterator.h"
#include "ObjCMethodCall.h"
#include "ObjCMethodCallback.h"
#include "ObjCTypes.h"
#include "SymbolLoader.h"
#include "TypeFactory.h"
#include <JavaScriptCore/BuiltinNames.h>
#include <JavaScriptCore/runtime/GetterSetter.h>
#include <objc/runtime.h>

#include "StopwatchLogger.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

const unsigned ObjCPrototype::StructureFlags = OverridesGetOwnPropertySlot | Base::StructureFlags;

const ClassInfo ObjCPrototype::s_info = { "ObjCPrototype", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCPrototype) };

WTF::String ObjCPrototype::className(const JSObject* object, VM& vm) {
    auto execState = object->globalObject(vm)->globalExec();
    auto constructor = object->get(execState, vm.propertyNames->constructor);
    auto constructorName = constructor.get(execState, vm.propertyNames->name);
    return constructorName.toWTFString(execState) + "Prototype";
}

static EncodedJSValue JSC_HOST_CALL getIterator(ExecState* execState) {
    id object = toObject(execState, execState->thisValue());
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    auto iterator = ObjCFastEnumerationIterator::create(execState->vm(), globalObject, globalObject->fastEnumerationIteratorStructure(), object);
    return JSValue::encode(iterator.get());
}

void ObjCPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject, const BaseClassMeta* metadata) {
    Base::finishCreation(vm);

    this->_metadata = metadata;

    if ([objc_getClass(metadata->name()) instancesRespondToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        this->putDirect(vm, vm.propertyNames->iteratorSymbol, JSFunction::create(vm, globalObject, 0, vm.propertyNames->builtinNames().valuesPublicName().string(), getIterator), static_cast<unsigned>(PropertyAttribute::DontEnum));
    }
}

//const char StopwatchLabel_getOwnPropertySlot[] = "ObjCPrototype::getOwnPropertySlot";
bool ObjCPrototype::getOwnPropertySlot(JSObject* object, ExecState* execState, PropertyName propertyName, PropertySlot& propertySlot) {
    //StopwatchLogger<StopwatchLabel_getOwnPropertySlot> stopwatch("(unset)");

    if (Base::getOwnPropertySlot(object, execState, propertyName, propertySlot)) {
        return true;
    }

    if (UNLIKELY(!propertyName.publicName())) {
        return false;
    }

    ObjCPrototype* prototype = jsCast<ObjCPrototype*>(object);
    if (UNLIKELY(propertyName == prototype->_definingPropertyName)) {
        // We're currently defining it, it's still not defined
        return false;
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(prototype->globalObject());
    // Check for property
    if (auto propertyMeta = prototype->_metadata->instanceProperty(propertyName.publicName(), prototype->klasses(), true, prototype->additionalProtocols())) {
        JSValue basePrototype = prototype->getPrototypeDirect(execState->vm());
        PropertySlot baseSlot(basePrototype, PropertySlot::InternalMethodType::Get);
        if (basePrototype.getPropertySlot(execState, propertyName, baseSlot)) {
            if (baseSlot.isAccessor()) {
                auto thisGetter = propertyMeta->hasGetter();
                auto thisSetter = propertyMeta->hasSetter();
                auto baseGetter = !baseSlot.getterSetter()->isGetterNull();
                auto baseSetter = !baseSlot.getterSetter()->isSetterNull();

                if ((!thisGetter || baseGetter) && (!thisSetter || baseSetter)) {
                    // condition is equivalent to (thisGetter => baseGetter) && (thisSetter => baseSetter), where '=>' means 'logically implies'
                    // I.e., If base class provides the same or more accessors than what we've found, return false and use its property via the prototype chain
                    return false;
                }
            }
        }

        prototype->_definingPropertyName = propertyName;
        prototype->defineNativeProperty(execState->vm(), globalObject, propertyMeta);
        prototype->_definingPropertyName = PropertyName(nullptr);

        //stopwatch.message << "(prop) " << prototype->metadata()->jsName() << "." << propertyMeta->jsName();

        return Base::getOwnPropertySlot(object, execState, propertyName, propertySlot);
    } else {
        // Check for base class property which is implemented in inheritor as a workaround
        // to inaccurate header information in iOS SDKs (https://github.com/NativeScript/ios-runtime/pull/1092)
        if (prototype->metadata()->type() == MetaType::Interface) {
            if (auto baseMeta = static_cast<const InterfaceMeta*>(prototype->metadata())->baseMeta()) {
                if (auto propertyMeta = baseMeta->instanceProperty(propertyName.publicName(), prototype->klasses(), true, prototype->additionalProtocols())) {
                    JSObject* basePrototype = prototype->getPrototype(execState->vm(), execState).toObject(execState);
                    PropertySlot tempPropSlot(JSValue(basePrototype), PropertySlot::InternalMethodType::GetOwnProperty);

                    if (basePrototype->methodTable(execState->vm())->getOwnPropertySlot(basePrototype, execState, propertyName, tempPropSlot)) {
                        // basePrototype has the property defined return false and let the prototype chain handle it
                        return false;
                    }

                    prototype->_definingPropertyName = propertyName;
                    prototype->defineNativeProperty(execState->vm(), globalObject, propertyMeta);
                    prototype->_definingPropertyName = PropertyName(nullptr);

                    //stopwatch.message << "(base prop) " << prototype->metadata()->jsName() << "." << propertyMeta->jsName();
                    return Base::getOwnPropertySlot(object, execState, propertyName, propertySlot);
                }
            }
        }

        MembersCollection methods = prototype->_metadata->getInstanceMethods(propertyName.publicName(), prototype->klasses(), true, prototype->additionalProtocols());

        if (methods.size() > 0) {
            SymbolLoader::instance().ensureModule((*methods.begin())->topLevelModule());

            auto method = ObjCMethodWrapper::create(globalObject->vm(), globalObject, globalObject->objCMethodWrapperStructure(), methods);
            object->putDirect(execState->vm(), propertyName, method.get());
            propertySlot.setValue(object, static_cast<unsigned>(PropertyAttribute::None), method.get());

            //stopwatch.message << "(method) " << prototype->metadata()->jsName() << "." << (*methods.begin())->jsName();
            return true;
        }
    }

    //stopwatch.message << "(not found) " << prototype->metadata()->jsName() << "." << propertyName.publicName()->utf8().data();
    return false;
}

bool ObjCPrototype::put(JSCell* cell, ExecState* execState, PropertyName propertyName, JSValue value, PutPropertySlot& propertySlot) {
    ObjCPrototype* prototype = jsCast<ObjCPrototype*>(cell);

    if (value.isCell()) {
        auto method = value.asCell();

        Class klass = jsCast<ObjCConstructorBase*>(prototype->get(execState, execState->vm().propertyNames->constructor))->klasses().realClass();
        overrideObjcMethodCalls(execState,
                                prototype,
                                propertyName,
                                method,
                                prototype->_metadata,
                                MemberType::InstanceMethod,
                                klass,
                                ProtocolMetas());
    }

    return Base::put(cell, execState, propertyName, value, propertySlot);
}

bool ObjCPrototype::defineOwnProperty(JSObject* object, ExecState* execState, PropertyName propertyName, const PropertyDescriptor& propertyDescriptor, bool shouldThrow) {
    ObjCPrototype* prototype = jsCast<ObjCPrototype*>(object);
    VM& vm = execState->vm();
    const auto& klasses = prototype->klasses();
    // Unknown (if present) is the actual object type - swizzle its selector instead of the public class' one
    const auto& klass = klasses.realClass();

    if (const PropertyMeta* propertyMeta = prototype->_metadata->instanceProperty(propertyName.publicName(), klasses, true, prototype->additionalProtocols())) {
        if (!propertyDescriptor.isAccessorDescriptor()) {
            WTFCrash();
        }

        PropertyDescriptor nativeProperty;
        prototype->getOwnPropertyDescriptor(execState, propertyName, nativeProperty);

        if (const MethodMeta* meta = propertyMeta->getter()) {
            ObjCMethodCallback* methodCallback = createProtectedMethodCallback(execState, propertyDescriptor.getter().asCell(), meta);
            std::string compilerEncoding = getCompilerEncoding(execState->lexicalGlobalObject(), meta);
            IMP nativeImp = class_replaceMethod(klass, meta->selector(), reinterpret_cast<IMP>(methodCallback->functionPointer()), compilerEncoding.c_str());

            SEL nativeSelector = sel_registerName(WTF::String::format("__%s", meta->selectorAsString()).utf8().data());
            class_addMethod(klass, nativeSelector, nativeImp, compilerEncoding.c_str());

            if (ObjCMethodWrapper* nativeMethod = jsDynamicCast<ObjCMethodWrapper*>(vm, nativeProperty.getter())) {
                static_cast<ObjCMethodCall*>(nativeMethod->onlyFuncInContainer())->setSelector(nativeSelector);
            }
        }

        if (const MethodMeta* meta = propertyMeta->setter()) {
            ObjCMethodCallback* methodCallback = createProtectedMethodCallback(execState, propertyDescriptor.setter().asCell(), meta);
            std::string compilerEncoding = getCompilerEncoding(execState->lexicalGlobalObject(), meta);
            IMP nativeImp = class_replaceMethod(klass, meta->selector(), reinterpret_cast<IMP>(methodCallback->functionPointer()), compilerEncoding.c_str());

            SEL nativeSelector = sel_registerName(WTF::String::format("__%s", meta->selectorAsString()).utf8().data());
            class_addMethod(klass, nativeSelector, nativeImp, compilerEncoding.c_str());

            if (ObjCMethodWrapper* nativeMethod = jsDynamicCast<ObjCMethodWrapper*>(vm, nativeProperty.setter())) {
                static_cast<ObjCMethodCall*>(nativeMethod->onlyFuncInContainer())->setSelector(nativeSelector);
            }
        }
    }

    return Base::defineOwnProperty(object, execState, propertyName, propertyDescriptor, shouldThrow);
}

void ObjCPrototype::getOwnPropertyNames(JSObject* object, ExecState* execState, PropertyNameArray& propertyNames, EnumerationMode enumerationMode) {
    ObjCPrototype* prototype = jsCast<ObjCPrototype*>(object);
    const auto& klasses = prototype->klasses();

    std::vector<const BaseClassMeta*> baseClassMetaStack;
    baseClassMetaStack.push_back(prototype->_metadata);

    while (!baseClassMetaStack.empty()) {
        const BaseClassMeta* baseClassMeta = baseClassMetaStack.back();
        baseClassMetaStack.pop_back();

        for (Metadata::ArrayOfPtrTo<MethodMeta>::iterator it = baseClassMeta->instanceMethods->begin(); it != baseClassMeta->instanceMethods->end(); it++) {
            if ((*it)->isAvailableInClasses(klasses, /*isStatic*/ false))
                propertyNames.add(Identifier::fromString(execState, (*it)->jsName()));
        }

        for (Metadata::ArrayOfPtrTo<PropertyMeta>::iterator it = baseClassMeta->instanceProps->begin(); it != baseClassMeta->instanceProps->end(); it++) {
            if ((*it)->isAvailableInClasses(klasses, /*isStatic*/ false))
                propertyNames.add(Identifier::fromString(execState, (*it)->jsName()));
        }

        for (Metadata::Array<Metadata::String>::iterator it = baseClassMeta->protocols->begin(); it != baseClassMeta->protocols->end(); it++) {
            const ProtocolMeta* protocolMeta = MetaFile::instance()->globalTableJs()->findProtocol((*it).valuePtr());
            if (protocolMeta != nullptr)
                baseClassMetaStack.push_back(protocolMeta);
        }
    }

    Base::getOwnPropertyNames(object, execState, propertyNames, enumerationMode);
}

void ObjCPrototype::defineNativeProperty(VM& vm, GlobalObject* globalObject, const PropertyMeta* propertyMeta) {
    SymbolLoader::instance().ensureModule(propertyMeta->topLevelModule());

    const MethodMeta* getter = (propertyMeta->hasGetter() && propertyMeta->getter()->isAvailable()) ? propertyMeta->getter() : nullptr;
    const MethodMeta* setter = (propertyMeta->hasSetter() && propertyMeta->setter()->isAvailable()) ? propertyMeta->setter() : nullptr;

    PropertyDescriptor descriptor;
    descriptor.setConfigurable(true);
    Strong<ObjCMethodWrapper> strongGetter;
    Strong<ObjCMethodWrapper> strongSetter;
    if (getter) {
        MembersCollection getters = { getter };
        strongGetter = ObjCMethodWrapper::create(vm, globalObject, globalObject->objCMethodWrapperStructure(), getters);
        descriptor.setGetter(strongGetter.get());
    }

    if (setter) {
        MembersCollection setters = { setter };
        strongSetter = ObjCMethodWrapper::create(vm, globalObject, globalObject->objCMethodWrapperStructure(), setters);
        descriptor.setSetter(strongSetter.get());
    }

    Base::defineOwnProperty(this, globalObject->globalExec(), Identifier::fromString(globalObject->globalExec(), propertyMeta->jsName()), descriptor, false);
}

void ObjCPrototype::materializeProperties(VM& vm, GlobalObject* globalObject) {
#if 0
    // The cycle here works around an issue with incorrect public headers of some iOS system frameworks.
    // In particular:
    //   * UIBarItem doesn't define 6 of its declared properties (enabled, image, imageInsets,
    //     landscapeImagePhone, landscapeImagePhoneInsets and title) but its inheritors UIBarButtonItem and
    //     UITabBarItem do
    //   * MTLRenderPassAttachmentDescriptor doesn't define 11 of its properties but it's inheritors
    //     MTLRenderPassDepthAttachmentDescriptor, MTLRenderPassColorAttachmentDescriptor and
    //     MTLRenderPassStencilAttachmentDescriptor do.
    // As a result we were not providing their implementation in JS before we started looking for missing
    // properties in the base class. This additional overhead increased the time spent in materializeProperties
    // from ~5.3 sec to ~7.5 sec (~40%) when running TestRunner with ApiIterator test enabled in RelWithDebInfo configuration
    // on an iPhone 6s device and from 3.0-3.2 to 4.4 sec (~40%) on an iPhone X

    const BaseClassMeta* meta = this->metadata();
    Class klass = this->klass();
    while (meta) {
        std::vector<const PropertyMeta*> properties = meta->instancePropertiesWithProtocols(nullptr);

        for (const PropertyMeta* propertyMeta : properties) {
            bool shouldDefine = false;

            if (klass == this->klass()) {
                // Property is coming from this class, define it if available
                shouldDefine = propertyMeta->isAvailableInClass(klass, false);
            } else {
                // Property is coming from a base class, define it as our property if isn't available there, but we've got it
                shouldDefine = !propertyMeta->isAvailableInClass(klass, false) && propertyMeta->isAvailableInClass(this->klass(), false);
                //                addedProps += shouldDefine ? 1 : 0;
            }

            if (shouldDefine) {
                this->defineNativeProperty(vm, globalObject, propertyMeta);
            }
        }

        if (klass == this->klass() && meta->type() == Interface) {
            meta = static_cast<const InterfaceMeta*>(meta)->baseMeta();
            klass = meta ? objc_getClass(meta->name()) : nullptr;
        } else {
            // Check only properties from the direct base class and then stop.
            // All the cases that we need to fix are like that so we don't have
            // to pay the additional overhead of looking intothe whole inheritance chain.
            meta = nullptr;
        }
    }
#endif
}

}
