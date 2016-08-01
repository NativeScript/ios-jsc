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
#include <objc/runtime.h>

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

const unsigned ObjCPrototype::StructureFlags = OverridesGetOwnPropertySlot | Base::StructureFlags;

const ClassInfo ObjCPrototype::s_info = { "ObjCPrototype", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCPrototype) };

WTF::String ObjCPrototype::className(const JSObject* object) {
    const char* className = jsCast<const ObjCPrototype*>(object)->_metadata->name();
    return WTF::String::format("%sPrototype", className);
}

static EncodedJSValue JSC_HOST_CALL getIterator(ExecState* execState) {
    id object = toObject(execState, execState->thisValue());
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    ObjCFastEnumerationIterator* iterator = ObjCFastEnumerationIterator::create(execState->vm(), globalObject, globalObject->fastEnumerationIteratorStructure(), object);
    return JSValue::encode(iterator);
}

void ObjCPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject, const BaseClassMeta* metadata) {
    Base::finishCreation(vm);

    this->_metadata = metadata;

    if ([objc_getClass(metadata->name()) instancesRespondToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
        this->putDirect(vm, vm.propertyNames->iteratorSymbol, JSFunction::create(vm, globalObject, 0, vm.propertyNames->values.string(), getIterator), DontEnum);
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

    if (const MethodMeta* memberMeta = prototype->_metadata->instanceMethod(propertyName.publicName())) {
        SymbolLoader::instance().ensureModule(memberMeta->topLevelModule());

        GlobalObject* globalObject = jsCast<GlobalObject*>(prototype->globalObject());
        ObjCMethodCall* method = ObjCMethodCall::create(globalObject->vm(), globalObject, globalObject->objCMethodCallStructure(), memberMeta);
        object->putDirect(execState->vm(), propertyName, method);
        propertySlot.setValue(object, None, method);
        return true;
    }

    return false;
}

void ObjCPrototype::put(JSCell* cell, ExecState* execState, PropertyName propertyName, JSValue value, PutPropertySlot& propertySlot) {
    ObjCPrototype* prototype = jsCast<ObjCPrototype*>(cell);

    if (WTF::StringImpl* publicName = propertyName.publicName()) {
        if (const MethodMeta* meta = prototype->_metadata->instanceMethod(publicName)) {
            Class klass = jsCast<ObjCConstructorBase*>(prototype->get(execState, execState->vm().propertyNames->constructor))->klass();

            ObjCMethodCallback* methodCallback = createProtectedMethodCallback(execState, value, meta);
            std::string compilerEncoding = getCompilerEncoding(execState->lexicalGlobalObject(), meta);
            IMP nativeImp = class_replaceMethod(klass, meta->selector(), reinterpret_cast<IMP>(methodCallback->functionPointer()), compilerEncoding.c_str());

            SEL nativeSelector = sel_registerName(WTF::String::format("__%s", meta->selectorAsString()).utf8().data());
            class_addMethod(klass, nativeSelector, nativeImp, compilerEncoding.c_str());

            if (ObjCMethodCall* nativeMethod = jsDynamicCast<ObjCMethodCall*>(prototype->get(execState, propertyName))) {
                nativeMethod->setSelector(nativeSelector);
            }
        }
    }

    Base::put(cell, execState, propertyName, value, propertySlot);
}

bool ObjCPrototype::defineOwnProperty(JSObject* object, ExecState* execState, PropertyName propertyName, const PropertyDescriptor& propertyDescriptor, bool shouldThrow) {
    ObjCPrototype* prototype = jsCast<ObjCPrototype*>(object);

    if (const PropertyMeta* propertyMeta = prototype->_metadata->property(propertyName.publicName())) {
        if (!propertyDescriptor.isAccessorDescriptor()) {
            WTFCrash();
        }

        Class klass = jsCast<ObjCConstructorBase*>(prototype->get(execState, execState->vm().propertyNames->constructor))->klass();
        PropertyDescriptor nativeProperty;
        prototype->getOwnPropertyDescriptor(execState, propertyName, nativeProperty);

        if (const MethodMeta* meta = propertyMeta->getter()) {
            ObjCMethodCallback* methodCallback = createProtectedMethodCallback(execState, propertyDescriptor.getter(), meta);
            std::string compilerEncoding = getCompilerEncoding(execState->lexicalGlobalObject(), meta);
            IMP nativeImp = class_replaceMethod(klass, meta->selector(), reinterpret_cast<IMP>(methodCallback->functionPointer()), compilerEncoding.c_str());

            SEL nativeSelector = sel_registerName(WTF::String::format("__%s", meta->selectorAsString()).utf8().data());
            class_addMethod(klass, nativeSelector, nativeImp, compilerEncoding.c_str());

            if (ObjCMethodCall* nativeMethod = jsDynamicCast<ObjCMethodCall*>(nativeProperty.getter())) {
                nativeMethod->setSelector(nativeSelector);
            }
        }

        if (const MethodMeta* meta = propertyMeta->setter()) {
            ObjCMethodCallback* methodCallback = createProtectedMethodCallback(execState, propertyDescriptor.setter(), meta);
            std::string compilerEncoding = getCompilerEncoding(execState->lexicalGlobalObject(), meta);
            IMP nativeImp = class_replaceMethod(klass, meta->selector(), reinterpret_cast<IMP>(methodCallback->functionPointer()), compilerEncoding.c_str());

            SEL nativeSelector = sel_registerName(WTF::String::format("__%s", meta->selectorAsString()).utf8().data());
            class_addMethod(klass, nativeSelector, nativeImp, compilerEncoding.c_str());

            if (ObjCMethodCall* nativeMethod = jsDynamicCast<ObjCMethodCall*>(nativeProperty.setter())) {
                nativeMethod->setSelector(nativeSelector);
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

        for (Metadata::ArrayOfPtrTo<PropertyMeta>::iterator it = baseClassMeta->props->begin(); it != baseClassMeta->props->end(); it++) {
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
    std::vector<const PropertyMeta*> properties = this->_metadata->propertiesWithProtocols();

    for (const PropertyMeta* propertyMeta : properties) {
        if (propertyMeta->isAvailable()) {
            SymbolLoader::instance().ensureModule(propertyMeta->topLevelModule());

            const MethodMeta* getter = (propertyMeta->getter() != nullptr && propertyMeta->getter()->isAvailable()) ? propertyMeta->getter() : nullptr;
            const MethodMeta* setter = (propertyMeta->setter() != nullptr && propertyMeta->setter()->isAvailable()) ? propertyMeta->setter() : nullptr;

            PropertyDescriptor descriptor;
            descriptor.setConfigurable(true);
            descriptor.setGetter(ObjCMethodCall::create(vm, globalObject, globalObject->objCMethodCallStructure(), getter));

            if (setter) {
                descriptor.setSetter(ObjCMethodCall::create(vm, globalObject, globalObject->objCMethodCallStructure(), setter));
            }

            Base::defineOwnProperty(this, globalObject->globalExec(), Identifier::fromString(globalObject->globalExec(), propertyMeta->jsName()), descriptor, false);
        }
    }
}
}
