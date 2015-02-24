//
//  ObjCConstructorNative.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 8/12/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCConstructorNative.h"
#include "Metadata.h"
#include "ObjCMethodCall.h"
#include "ObjCConstructorCall.h"
#include "SymbolLoader.h"
#include "ObjCMethodCallback.h"

namespace NativeScript {

using namespace JSC;
using namespace Metadata;

const unsigned ObjCConstructorNative::StructureFlags = OverridesGetOwnPropertySlot | Base::StructureFlags;

const ClassInfo ObjCConstructorNative::s_info = { "Function", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(ObjCConstructorNative) };

void ObjCConstructorNative::finishCreation(VM& vm, JSGlobalObject* globalObject, JSObject* prototype, Class klass, const InterfaceMeta* metadata) {
    Base::finishCreation(vm, globalObject, prototype, klass);
    this->_metadata = metadata;
    this->ObjCConstructorBase::_initializersGenerator = std::bind(&ObjCConstructorNative::initializersGenerator, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
}

bool ObjCConstructorNative::getOwnPropertySlot(JSObject* object, ExecState* execState, PropertyName propertyName, PropertySlot& propertySlot) {
    if (Base::getOwnPropertySlot(object, execState, propertyName, propertySlot)) {
        return true;
    }

    ObjCConstructorNative* constructor = jsCast<ObjCConstructorNative*>(object);

    if (MethodMeta* method = constructor->_metadata->staticMethod(propertyName.publicName())) {
        SymbolLoader::instance().ensureFramework(method->moduleName());

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

    if (MethodMeta* meta = constructor->_metadata->staticMethod(propertyName.publicName())) {
        Class klass = object_getClass(constructor->klass());

        ObjCMethodCallback* methodCallback = createProtectedMethodCallback(execState, value, meta);
        IMP nativeImp = class_replaceMethod(klass, meta->selector(), reinterpret_cast<IMP>(methodCallback->functionPointer()), meta->compilerEncoding());

        SEL nativeSelector = sel_registerName(WTF::String::format("__%s", meta->selectorAsString()).utf8().data());
        class_addMethod(klass, nativeSelector, nativeImp, meta->compilerEncoding());

        if (ObjCMethodCall* nativeMethod = jsDynamicCast<ObjCMethodCall*>(constructor->get(execState, propertyName))) {
            nativeMethod->setSelector(nativeSelector);
        }
    }

    Base::put(cell, execState, propertyName, value, propertySlot);
}

void ObjCConstructorNative::getOwnPropertyNames(JSObject* object, ExecState* execState, PropertyNameArray& propertyNames, EnumerationMode enumerationMode) {
    ObjCConstructorNative* constructor = jsCast<ObjCConstructorNative*>(object);

    std::vector<const BaseClassMeta*> baseClassMetaStack;
    baseClassMetaStack.push_back(constructor->_metadata);

    while (!baseClassMetaStack.empty()) {
        const BaseClassMeta* baseClassMeta = baseClassMetaStack.back();
        baseClassMetaStack.pop_back();

        for (auto methodIterator = baseClassMeta->getStaticMethodsIterator(); methodIterator.hasNext(); methodIterator.next()) {
            MethodMeta* meta = methodIterator.currentItem();
            propertyNames.add(Identifier(execState, meta->jsName()));
        }

        for (auto protocolIterator = baseClassMeta->getProtocolsIterator(); protocolIterator.hasNext(); protocolIterator.next()) {
            baseClassMetaStack.push_back(protocolIterator.currentItem());
        }
    }

    Base::getOwnPropertyNames(object, execState, propertyNames, enumerationMode);
}

const WTF::Vector<ObjCConstructorCall*> ObjCConstructorNative::initializersGenerator(VM& vm, GlobalObject* globalObject, Class target) {
    const InterfaceMeta* metadata = this->_metadata;

    WTF::Vector<ObjCConstructorCall*> constructors;

    do {
        std::vector<MethodMeta*> initializers = metadata->initializersWithProtcols();
        for (std::vector<MethodMeta*>::iterator init = initializers.begin(); init != initializers.end(); ++init) {
            MethodMeta* method = (*init);

            ObjCConstructorCall* constructorCall = ObjCConstructorCall::create(vm, globalObject, globalObject->objCConstructorCallStructure(), target, method);
            constructors.append(constructorCall);
        }

        metadata = metadata->baseMeta();

    } while (metadata);

    return constructors;
}
}
