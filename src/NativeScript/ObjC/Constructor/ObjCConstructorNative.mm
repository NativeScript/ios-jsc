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

const ClassInfo ObjCConstructorNative::s_info = { "Function", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCConstructorNative) };

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

    MembersCollection methods = constructor->_metadata->getStaticMethods(propertyName.publicName(), constructor->klass());

    if (methods.size() > 0) {
        std::unordered_map<std::string, MembersCollection> metasByJsName = Metadata::getMetasByJSNames(methods);

        for (auto& methodNameAndMetas : metasByJsName) {
            MembersCollection& metas = methodNameAndMetas.second;
            ASSERT(metas.size() > 0);

            SymbolLoader::instance().ensureModule((*metas.begin())->topLevelModule());

            GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
            auto wrapper = ObjCMethodWrapper::create(execState->vm(), globalObject, globalObject->objCMethodWrapperStructure(), metas);
            object->putDirectWithoutTransition(execState->vm(), propertyName, wrapper.get());
            propertySlot.setValue(object, static_cast<unsigned>(PropertyAttribute::None), wrapper.get());
            return true;
        }

        return true;
    }

    return false;
}

bool ObjCConstructorNative::put(JSCell* cell, ExecState* execState, PropertyName propertyName, JSValue value, PutPropertySlot& propertySlot) {
    if (value.isCell()) {
        auto method = value.asCell();
        ObjCConstructorNative* constructor = jsCast<ObjCConstructorNative*>(cell);
        Class klass = object_getClass(constructor->klass());

        overrideObjcMethodCalls(execState,
                                constructor,
                                propertyName,
                                method,
                                constructor->_metadata,
                                MemberType::StaticMethod,
                                klass,
                                nullptr);
    }

    return Base::put(cell, execState, propertyName, value, propertySlot);
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
            if (meta->isAvailableInClass(constructor->klass(), /*isStatic*/ true)) {
                propertyNames.add(Identifier::fromString(execState, meta->jsName()));
            }
        }

        for (Metadata::ArrayOfPtrTo<PropertyMeta>::iterator it = baseClassMeta->staticProps->begin(); it != baseClassMeta->staticProps->end(); it++) {
            if ((*it)->isAvailableInClass(constructor->klass(), /*isStatic*/ true)) {
                propertyNames.add(Identifier::fromString(execState, (*it)->jsName()));
            }
        }

        for (Array<Metadata::String>::iterator it = baseClassMeta->protocols->begin(); it != baseClassMeta->protocols->end(); it++) {
            const ProtocolMeta* protocolMeta = MetaFile::instance()->globalTable()->findProtocol((*it).valuePtr());
            if (protocolMeta != nullptr) {
                baseClassMetaStack.push_back(protocolMeta);
            }
        }
    }

    Base::getOwnPropertyNames(object, execState, propertyNames, enumerationMode);
}

void ObjCConstructorNative::materializeProperties(VM& vm, GlobalObject* globalObject) {
    std::vector<const PropertyMeta*> properties = this->metadata()->staticPropertiesWithProtocols(this->klass());

    for (const PropertyMeta* propertyMeta : properties) {
        SymbolLoader::instance().ensureModule(propertyMeta->topLevelModule());

        const MethodMeta* getterMeta = (propertyMeta->getter() != nullptr && propertyMeta->getter()->isAvailableInClass(this->klass(), /*isStatic*/ true)) ? propertyMeta->getter() : nullptr;
        const MethodMeta* setterMeta = (propertyMeta->setter() != nullptr && propertyMeta->setter()->isAvailableInClass(this->klass(), /*isStatic*/ true)) ? propertyMeta->setter() : nullptr;

        PropertyDescriptor descriptor;
        Strong<ObjCMethodWrapper> getter;
        Strong<ObjCMethodWrapper> setter;

        if (getterMeta) {
            MembersCollection getters = { getterMeta };
            getter = ObjCMethodWrapper::create(vm, globalObject, globalObject->objCMethodWrapperStructure(), getters);
            descriptor.setGetter(getter.get());
        }

        if (setterMeta) {
            MembersCollection setters = { setterMeta };
            setter = ObjCMethodWrapper::create(vm, globalObject, globalObject->objCMethodWrapperStructure(), setters);
            descriptor.setSetter(setter.get());
        }

        Base::defineOwnProperty(this, globalObject->globalExec(), Identifier::fromString(globalObject->globalExec(), propertyMeta->jsName()), descriptor, false);
    }
}

void ObjCConstructorNative::visitChildren(JSC::JSCell* cell, JSC::SlotVisitor& visitor) {
    Base::visitChildren(cell, visitor);
    ObjCConstructorNative* constructor = jsCast<ObjCConstructorNative*>(cell);
    visitor.append(constructor->_allocatedPlaceholderStructure);
}
}
