//
//  ObjCConstructorNative.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 8/12/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCConstructorNative.h"
#include "AllocatedPlaceholder.h"
#include "Interop.h"
#include "Metadata.h"
#include "ObjCConstructorCall.h"
#include "ObjCMethodCall.h"
#include "ObjCMethodCallback.h"
#include "SymbolLoader.h"

namespace NativeScript {

using namespace JSC;
using namespace Metadata;

const ClassInfo ObjCConstructorNative::s_info = { "Function", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCConstructorNative) };

void ObjCConstructorNative::finishCreation(VM& vm, JSGlobalObject* globalObject, JSObject* prototype, Class klass) {
    Base::finishCreation(vm, globalObject, prototype, klass);
    this->_allocatedPlaceholderStructure.set(vm, this, AllocatedPlaceholder::createStructure(vm, globalObject, prototype));
}

bool ObjCConstructorNative::getOwnPropertySlot(JSObject* object, ExecState* execState, PropertyName propertyName, PropertySlot& propertySlot) {
    if (Base::getOwnPropertySlot(object, execState, propertyName, propertySlot)) {
        return true;
    }

    if (UNLIKELY(!propertyName.publicName())) {
        return false;
    }

    ObjCConstructorNative* constructor = jsCast<ObjCConstructorNative*>(object);

    if (const MethodMeta* method = constructor->metadata()->staticMethod(propertyName.publicName())) {
        SymbolLoader::instance().ensureModule(method->topLevelModule());

        GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
        ObjCMethodCall* call = ObjCMethodCall::create(execState->vm(), globalObject, globalObject->objCMethodCallStructure(), method);
        object->putDirectWithoutTransition(execState->vm(), propertyName, call);
        propertySlot.setValue(object, None, call);
        return true;
    }

    return false;
}

void ObjCConstructorNative::put(JSCell* cell, ExecState* execState, PropertyName propertyName, JSValue value, PutPropertySlot& propertySlot) {
    ObjCConstructorNative* constructor = jsCast<ObjCConstructorNative*>(cell);

    if (WTF::StringImpl* publicName = propertyName.publicName()) {
        if (const MethodMeta* meta = constructor->metadata()->staticMethod(publicName)) {
            Class klass = object_getClass(constructor->klass());

            std::string compilerEncoding = getCompilerEncoding(execState->lexicalGlobalObject(), meta);
            ObjCMethodCallback* methodCallback = createProtectedMethodCallback(execState, value, meta);
            IMP nativeImp = class_replaceMethod(klass, meta->selector(), reinterpret_cast<IMP>(methodCallback->functionPointer()), compilerEncoding.c_str());

            SEL nativeSelector = sel_registerName(WTF::String::format("__%s", meta->selectorAsString()).utf8().data());
            class_addMethod(klass, nativeSelector, nativeImp, compilerEncoding.c_str());

            if (ObjCMethodCall* nativeMethod = jsDynamicCast<ObjCMethodCall*>(constructor->get(execState, propertyName))) {
                nativeMethod->setSelector(nativeSelector);
            }
        }
    }

    Base::put(cell, execState, propertyName, value, propertySlot);
}

void ObjCConstructorNative::getOwnPropertyNames(JSObject* object, ExecState* execState, PropertyNameArray& propertyNames, EnumerationMode enumerationMode) {
    ObjCConstructorNative* constructor = jsCast<ObjCConstructorNative*>(object);

    std::vector<const BaseClassMeta*> baseClassMetaStack;
    baseClassMetaStack.push_back(constructor->metadata());

    while (!baseClassMetaStack.empty()) {
        const BaseClassMeta* baseClassMeta = baseClassMetaStack.back();
        baseClassMetaStack.pop_back();

        for (ArrayOfPtrTo<MethodMeta>::iterator it = baseClassMeta->staticMethods->begin(); it != baseClassMeta->staticMethods->end(); it++) {
            const MethodMeta* meta = (*it).valuePtr();
            if (meta->isAvailable())
                propertyNames.add(Identifier::fromString(execState, meta->jsName()));
        }

        for (Metadata::ArrayOfPtrTo<PropertyMeta>::iterator it = baseClassMeta->staticProps->begin(); it != baseClassMeta->staticProps->end(); it++) {
            if ((*it)->isAvailable())
                propertyNames.add(Identifier::fromString(execState, (*it)->jsName()));
        }

        for (Array<Metadata::String>::iterator it = baseClassMeta->protocols->begin(); it != baseClassMeta->protocols->end(); it++) {
            const ProtocolMeta* protocolMeta = (const ProtocolMeta*)MetaFile::instance()->globalTable()->findMeta((*it).valuePtr());
            if (protocolMeta != nullptr)
                baseClassMetaStack.push_back(protocolMeta);
        }
    }

    Base::getOwnPropertyNames(object, execState, propertyNames, enumerationMode);
}

void ObjCConstructorNative::materializeProperties(VM& vm, GlobalObject* globalObject) {
    std::vector<const PropertyMeta*> properties = this->metadata()->staticPropertiesWithProtocols();

    for (const PropertyMeta* propertyMeta : properties) {
        if (propertyMeta->isAvailable()) {
            SymbolLoader::instance().ensureModule(propertyMeta->topLevelModule());

            const MethodMeta* getter = (propertyMeta->getter() != nullptr && propertyMeta->getter()->isAvailable()) ? propertyMeta->getter() : nullptr;
            const MethodMeta* setter = (propertyMeta->setter() != nullptr && propertyMeta->setter()->isAvailable()) ? propertyMeta->setter() : nullptr;

            PropertyDescriptor descriptor;
            descriptor.setGetter(ObjCMethodCall::create(vm, globalObject, globalObject->objCMethodCallStructure(), getter));

            if (setter) {
                descriptor.setSetter(ObjCMethodCall::create(vm, globalObject, globalObject->objCMethodCallStructure(), setter));
            }

            Base::defineOwnProperty(this, globalObject->globalExec(), Identifier::fromString(globalObject->globalExec(), propertyMeta->jsName()), descriptor, false);
        }
    }
}

void ObjCConstructorNative::visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);
    ObjCConstructorNative* constructor = jsCast<ObjCConstructorNative*>(cell);
    visitor.append(&constructor->_allocatedPlaceholderStructure);
}
}
