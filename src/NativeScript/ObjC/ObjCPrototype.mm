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
#include <objc/runtime.h>

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

const unsigned ObjCPrototype::StructureFlags = OverridesGetOwnPropertySlot | Base::StructureFlags;

const ClassInfo ObjCPrototype::s_info = { "ObjCPrototype", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCPrototype) };

WTF::String ObjCPrototype::className(const JSObject* object, VM&) {
    const char* className = jsCast<const ObjCPrototype*>(object)->_metadata->name();
    return WTF::String::format("%sPrototype", className);
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

bool ObjCPrototype::getOwnPropertySlot(JSObject* object, ExecState* execState, PropertyName propertyName, PropertySlot& propertySlot) {
    if (Base::getOwnPropertySlot(object, execState, propertyName, propertySlot)) {
        return true;
    }

    if (UNLIKELY(!propertyName.publicName())) {
        return false;
    }

    ObjCPrototype* prototype = jsCast<ObjCPrototype*>(object);

    std::vector<const MemberMeta*> methods = prototype->_metadata->getInstanceMethods(propertyName.publicName());

    if (methods.size() > 0) {

        std::unordered_map<std::string, std::vector<const MemberMeta*>> metasByJsName = Metadata::getMetasByJSNames(methods);

        for (auto& methodNameAndMetas : metasByJsName) {
            std::vector<const MemberMeta*>& metas = methodNameAndMetas.second;

            ASSERT(metas.size() > 0);
            SymbolLoader::instance().ensureModule(metas[0]->topLevelModule());

            GlobalObject* globalObject = jsCast<GlobalObject*>(prototype->globalObject());
            auto method = ObjCMethodWrapper::create(globalObject->vm(), globalObject, globalObject->objCMethodWrapperStructure(), metas);
            object->putDirect(execState->vm(), propertyName, method.get());
            propertySlot.setValue(object, static_cast<unsigned>(PropertyAttribute::None), method.get());
        }

        return true;
    }

    return false;
}

bool ObjCPrototype::put(JSCell* cell, ExecState* execState, PropertyName propertyName, JSValue value, PutPropertySlot& propertySlot) {
    ObjCPrototype* prototype = jsCast<ObjCPrototype*>(cell);

    if (value.isCell()) {
        auto method = value.asCell();

        Class klass = jsCast<ObjCConstructorBase*>(prototype->get(execState, execState->vm().propertyNames->constructor))->klass();
        overrideObjcMethodCalls(execState,
                                prototype,
                                propertyName,
                                method,
                                prototype->_metadata,
                                MemberType::InstanceMethod,
                                klass,
                                nullptr);
    }

    return Base::put(cell, execState, propertyName, value, propertySlot);
}

bool ObjCPrototype::defineOwnProperty(JSObject* object, ExecState* execState, PropertyName propertyName, const PropertyDescriptor& propertyDescriptor, bool shouldThrow) {
    ObjCPrototype* prototype = jsCast<ObjCPrototype*>(object);
    VM& vm = execState->vm();

    if (const PropertyMeta* propertyMeta = prototype->_metadata->instanceProperty(propertyName.publicName())) {
        if (!propertyDescriptor.isAccessorDescriptor()) {
            WTFCrash();
        }

        Class klass = jsCast<ObjCConstructorBase*>(prototype->get(execState, execState->vm().propertyNames->constructor))->klass();
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

    std::vector<const BaseClassMeta*> baseClassMetaStack;
    baseClassMetaStack.push_back(prototype->_metadata);

    while (!baseClassMetaStack.empty()) {
        const BaseClassMeta* baseClassMeta = baseClassMetaStack.back();
        baseClassMetaStack.pop_back();

        for (Metadata::ArrayOfPtrTo<MethodMeta>::iterator it = baseClassMeta->instanceMethods->begin(); it != baseClassMeta->instanceMethods->end(); it++) {
            if ((*it)->isAvailable())
                propertyNames.add(Identifier::fromString(execState, (*it)->jsName()));
        }

        for (Metadata::ArrayOfPtrTo<PropertyMeta>::iterator it = baseClassMeta->instanceProps->begin(); it != baseClassMeta->instanceProps->end(); it++) {
            if ((*it)->isAvailable())
                propertyNames.add(Identifier::fromString(execState, (*it)->jsName()));
        }

        for (Metadata::Array<Metadata::String>::iterator it = baseClassMeta->protocols->begin(); it != baseClassMeta->protocols->end(); it++) {
            const ProtocolMeta* protocolMeta = (const ProtocolMeta*)MetaFile::instance()->globalTable()->findMeta((*it).valuePtr());
            if (protocolMeta != nullptr)
                baseClassMetaStack.push_back(protocolMeta);
        }
    }

    Base::getOwnPropertyNames(object, execState, propertyNames, enumerationMode);
}

void ObjCPrototype::materializeProperties(VM& vm, GlobalObject* globalObject) {
    std::vector<const PropertyMeta*> properties = this->_metadata->instancePropertiesWithProtocols();

    for (const PropertyMeta* propertyMeta : properties) {
        if (propertyMeta->isAvailable()) {
            SymbolLoader::instance().ensureModule(propertyMeta->topLevelModule());

            const MethodMeta* getter = (propertyMeta->getter() != nullptr && propertyMeta->getter()->isAvailable()) ? propertyMeta->getter() : nullptr;
            const MethodMeta* setter = (propertyMeta->setter() != nullptr && propertyMeta->setter()->isAvailable()) ? propertyMeta->setter() : nullptr;

            PropertyDescriptor descriptor;
            descriptor.setConfigurable(true);
            Strong<ObjCMethodWrapper> strongGetter;
            Strong<ObjCMethodWrapper> strongSetter;
            if (getter) {
                std::vector<const MemberMeta*> getters(1, getter);
                strongGetter = ObjCMethodWrapper::create(vm, globalObject, globalObject->objCMethodWrapperStructure(), getters);
                descriptor.setGetter(strongGetter.get());
            }

            if (setter) {
                std::vector<const MemberMeta*> setters(1, setter);
                strongSetter = ObjCMethodWrapper::create(vm, globalObject, globalObject->objCMethodWrapperStructure(), setters);
                descriptor.setSetter(strongSetter.get());
            }

            Base::defineOwnProperty(this, globalObject->globalExec(), Identifier::fromString(globalObject->globalExec(), propertyMeta->jsName()), descriptor, false);
        }
    }
}
}
