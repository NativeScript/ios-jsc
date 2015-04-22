//
//  GlobalObject.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 14.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "GlobalObject.h"
#include <string>
#include <JavaScriptCore/FunctionPrototype.h>
#include <JavaScriptCore/FunctionConstructor.h>
#include <JavaScriptCore/JSGlobalObjectInspectorController.h>
#include <JavaScriptCore/Microtask.h>
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/StrongInlines.h>
#include "ObjCProtocolWrapper.h"
#include "ObjCConstructorNative.h"
#include "ObjCPrototype.h"
#include "Metadata.h"
#include "SymbolLoader.h"
#include "FFIFunctionCall.h"
#include "RecordConstructor.h"
#include "RecordPrototypeFunctions.h"
#include "Interop.h"
#include "ObjCExtend.h"
#include "ObjCTypeScriptExtend.h"
#include "__extends.h"
#include "ObjCMethodCall.h"
#include "ObjCConstructorCall.h"
#include "ObjCBlockCall.h"
#include "ObjCBlockCallback.h"
#include "ObjCMethodCallback.h"
#include "FFIFunctionCallback.h"
#include "JSWeakRefConstructor.h"
#include "JSWeakRefPrototype.h"
#include "JSWeakRefInstance.h"
#include "TypeFactory.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

const ClassInfo GlobalObject::s_info = { "NativeScriptGlobal", &Base::s_info, 0, ExecState::globalObjectTable, CREATE_METHOD_TABLE(GlobalObject) };

const unsigned GlobalObject::StructureFlags = OverridesVisitChildren | OverridesGetOwnPropertySlot | Base::StructureFlags;

const GlobalObjectMethodTable GlobalObject::globalObjectMethodTable = { &allowsAccessFrom, &supportsProfiling, &supportsRichSourceInfo, &shouldInterruptScript, &javaScriptExperimentsEnabled, &queueTaskToEventLoop, &shouldInterruptScriptBeforeTimeout };

GlobalObject::GlobalObject(VM& vm, Structure* structure)
    : JSGlobalObject(vm, structure, &GlobalObject::globalObjectMethodTable) {
}

GlobalObject::~GlobalObject() {
    this->_inspectorController->globalObjectDestroyed();
}

Structure* GlobalObject::createStructure(VM& vm, JSValue prototype) {
    return Structure::create(vm, 0, prototype, TypeInfo(GlobalObjectType, GlobalObject::StructureFlags), GlobalObject::info());
}

GlobalObject* GlobalObject::create(VM& vm, Structure* structure) {
    GlobalObject* object = new (NotNull, allocateCell<GlobalObject>(vm.heap)) GlobalObject(vm, structure);
    object->finishCreation(vm);
    vm.heap.addFinalizer(object, destroy);
    return object;
}

extern "C" void JSSynchronousGarbageCollectForDebugging(ExecState*);
static EncodedJSValue JSC_HOST_CALL collectGarbage(ExecState* execState) {
    JSSynchronousGarbageCollectForDebugging(execState->lexicalGlobalObject()->globalExec());
    return JSValue::encode(jsUndefined());
}

void GlobalObject::finishCreation(VM& vm) {
    Base::finishCreation(vm);

    ExecState* globalExec = this->globalExec();

    this->_inspectorController = std::make_unique<Inspector::JSGlobalObjectInspectorController>(*this);
    this->setConsoleClient(this->_inspectorController->consoleClient());
    this->putDirect(vm, vm.propertyNames->global, this, DontEnum | ReadOnly | DontDelete);

    this->_objCMethodCallStructure.set(vm, this, ObjCMethodCall::createStructure(vm, this, this->functionPrototype()));
    this->_objCConstructorCallStructure.set(vm, this, ObjCConstructorCall::createStructure(vm, this, this->functionPrototype()));
    this->_objCBlockCallStructure.set(vm, this, ObjCBlockCall::createStructure(vm, this, this->functionPrototype()));
    this->_ffiFunctionCallStructure.set(vm, this, FFIFunctionCall::createStructure(vm, this, this->functionPrototype()));
    this->_objCBlockCallbackStructure.set(vm, this, ObjCBlockCallback::createStructure(vm, this, jsNull()));
    this->_objCMethodCallbackStructure.set(vm, this, ObjCMethodCallback::createStructure(vm, this, jsNull()));
    this->_ffiFunctionCallbackStructure.set(vm, this, FFIFunctionCallback::createStructure(vm, this, jsNull()));
    this->_recordFieldGetterStructure.set(vm, this, RecordProtoFieldGetter::createStructure(vm, this, this->functionPrototype()));
    this->_recordFieldSetterStructure.set(vm, this, RecordProtoFieldSetter::createStructure(vm, this, this->functionPrototype()));

    this->_typeFactory.set(vm, this, TypeFactory::create(vm, this, TypeFactory::createStructure(vm, this, jsNull())));

    this->_weakRefConstructorStructure.set(vm, this, JSWeakRefConstructor::createStructure(vm, this, Base::functionPrototype()));
    this->_weakRefPrototypeStructure.set(vm, this, JSWeakRefPrototype::createStructure(vm, this, Base::objectPrototype()));
    JSWeakRefPrototype* weakRefPrototype = JSWeakRefPrototype::create(vm, this, this->weakRefPrototypeStructure());
    this->_weakRefInstanceStructure.set(vm, this, JSWeakRefInstance::createStructure(vm, this, weakRefPrototype));
    this->putDirect(vm, Identifier(&vm, WTF::ASCIILiteral("WeakRef")), JSWeakRefConstructor::create(vm, this->weakRefConstructorStructure(), weakRefPrototype));

    this->_interopIdentifier = Identifier(&vm, Interop::info()->className);
    this->_interop.set(vm, this, Interop::create(vm, this, Interop::createStructure(vm, this, this->objectPrototype())));

    this->putDirectNativeFunction(vm, this, Identifier(globalExec, WTF::ASCIILiteral("__collect")), 0, &collectGarbage, NoIntrinsic, DontEnum | Attribute::Function);

#if DEBUG
    SourceCode sourceCode = makeSource(WTF::String(__extends_js, __extends_js_len), WTF::ASCIILiteral("__extends.ts"));
#else
    SourceCode sourceCode = makeSource(WTF::String(__extends_js, __extends_js_len));
#endif
    this->_typeScriptOriginalExtendsFunction.set(vm, this, jsCast<JSFunction*>(evaluate(globalExec, sourceCode, globalExec->thisValue())));
    this->putDirectNativeFunction(vm, this, Identifier(globalExec, WTF::ASCIILiteral("__extends")), 2, ObjCTypeScriptExtendFunction, NoIntrinsic, DontEnum | DontDelete | ReadOnly | Attribute::Function);

    ObjCConstructorNative* NSObjectConstructor = this->typeFactory()->NSObjectConstructor(this);
    NSObjectConstructor->putDirectNativeFunction(vm, this, Identifier(&vm, WTF::ASCIILiteral("extend")), 2, ObjCExtendFunction, NoIntrinsic, DontEnum | Attribute::Function);

    MarkedArgumentBuffer descriptionFunctionArgs;
    descriptionFunctionArgs.append(jsString(globalExec, WTF::ASCIILiteral("return this.description;")));
    ObjCPrototype* NSObjectPrototype = jsCast<ObjCPrototype*>(NSObjectConstructor->get(globalExec, vm.propertyNames->prototype));
    NSObjectPrototype->putDirect(vm, vm.propertyNames->toString, constructFunction(globalExec, this, descriptionFunctionArgs), DontEnum);

    MarkedArgumentBuffer staticDescriptionFunctionArgs;
    staticDescriptionFunctionArgs.append(jsString(globalExec, WTF::ASCIILiteral("return Function.prototype.toString.call(this);")));
    NSObjectConstructor->putDirect(vm, vm.propertyNames->toString, constructFunction(globalExec, this, staticDescriptionFunctionArgs), DontEnum);

    NSObjectConstructor->setPrototype(vm, NSObjectPrototype);
}

void GlobalObject::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(cell);
    Base::visitChildren(globalObject, visitor);

    visitor.append(&globalObject->_interop);
    visitor.append(&globalObject->_typeFactory);
    visitor.append(&globalObject->_typeScriptOriginalExtendsFunction);
    visitor.append(&globalObject->_objCMethodCallStructure);
    visitor.append(&globalObject->_objCConstructorCallStructure);
    visitor.append(&globalObject->_objCBlockCallStructure);
    visitor.append(&globalObject->_ffiFunctionCallStructure);
    visitor.append(&globalObject->_objCBlockCallbackStructure);
    visitor.append(&globalObject->_objCMethodCallbackStructure);
    visitor.append(&globalObject->_ffiFunctionCallbackStructure);
    visitor.append(&globalObject->_recordFieldGetterStructure);
    visitor.append(&globalObject->_recordFieldSetterStructure);
    visitor.append(&globalObject->_weakRefConstructorStructure);
    visitor.append(&globalObject->_weakRefPrototypeStructure);
    visitor.append(&globalObject->_weakRefInstanceStructure);
}

void GlobalObject::destroy(JSCell* cell) {
    static_cast<GlobalObject*>(cell)->GlobalObject::~GlobalObject();
}

bool GlobalObject::getOwnPropertySlot(JSObject* object, ExecState* execState, PropertyName propertyName, PropertySlot& propertySlot) {
    if (Base::getOwnPropertySlot(object, execState, propertyName, propertySlot)) {
        return true;
    }

    GlobalObject* globalObject = jsCast<GlobalObject*>(object);
    VM& vm = execState->vm();

    if (propertyName == globalObject->_interopIdentifier) {
        propertySlot.setValue(object, DontEnum | ReadOnly | DontDelete, globalObject->interop());
        return true;
    }

    StringImpl* symbolName = propertyName.publicName();
    const Meta* symbolMeta = getMetadata()->findMeta(symbolName);
    if (!symbolMeta)
        return false;

    JSValue symbolWrapper;

    switch (symbolMeta->type()) {
    case Interface: {
        Class klass = objc_getClass(symbolMeta->name());
        if (!klass) {
            SymbolLoader::instance().ensureFramework(symbolMeta->framework());
            klass = objc_getClass(symbolMeta->name());
        }

        if (klass) {
            symbolWrapper = globalObject->_typeFactory.get()->getObjCNativeConstructor(globalObject, symbolMeta->jsName());
            globalObject->_objCConstructors.insert(std::pair<Class, Strong<ObjCConstructorBase>>(klass, Strong<ObjCConstructorBase>(vm, jsCast<ObjCConstructorBase*>(symbolWrapper))));
        }
        break;
    }
    case ProtocolType: {
        Protocol* aProtocol = objc_getProtocol(symbolMeta->name());
        if (!aProtocol) {
            SymbolLoader::instance().ensureFramework(symbolMeta->framework());
            aProtocol = objc_getProtocol(symbolMeta->name());
        }

        symbolWrapper = ObjCProtocolWrapper::create(vm, ObjCProtocolWrapper::createStructure(vm, globalObject, globalObject->objectPrototype()), static_cast<const ProtocolMeta*>(symbolMeta), aProtocol);
        if (aProtocol) {
            auto pair = std::pair<const Protocol*, Strong<ObjCProtocolWrapper>>(aProtocol, Strong<ObjCProtocolWrapper>(vm, jsCast<ObjCProtocolWrapper*>(symbolWrapper)));
            globalObject->_objCProtocolWrappers.insert(pair);
        }
        break;
    }
    case Union: {
        //        symbolWrapper = globalObject->typeFactory()->createOrGetUnionConstructor(globalObject, symbolName);
        break;
    }
    case Struct: {
        symbolWrapper = globalObject->typeFactory()->getStructConstructor(globalObject, symbolName);
        break;
    }
    case MetaType::Function: {
        void* functionSymbol = SymbolLoader::instance().loadFunctionSymbol(symbolMeta->framework(), symbolMeta->name());
        if (functionSymbol) {
            const FunctionMeta* functionMeta = static_cast<const FunctionMeta*>(symbolMeta);
            Metadata::MetaFileOffset cursor = functionMeta->encodingOffset();
            JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, cursor);
            const WTF::Vector<JSCell*> parametersTypes = globalObject->typeFactory()->parseTypes(globalObject, cursor, functionMeta->encodingCount() - 1);
            symbolWrapper = FFIFunctionCall::create(vm, globalObject->ffiFunctionCallStructure(), functionSymbol, functionMeta->jsName(), returnType, parametersTypes, functionMeta->ownsReturnedCocoaObject());
        }
        break;
    }
    case Var: {
        const VarMeta* varMeta = static_cast<const VarMeta*>(symbolMeta);
        void* varSymbol = SymbolLoader::instance().loadDataSymbol(varMeta->framework(), varMeta->name());
        if (varSymbol) {
            MetaFileOffset cursor = varMeta->encodingOffset();
            JSCell* symbolType = globalObject->typeFactory()->parseType(globalObject, cursor);
            symbolWrapper = getFFITypeMethodTable(symbolType).read(execState, varSymbol, symbolType);
        }
        break;
    }
    case JsCode: {
        WTF::String source = WTF::String(static_cast<const JsCodeMeta*>(symbolMeta)->jsCode());
        symbolWrapper = evaluate(execState, makeSource(source));
        break;
    }
    default: {
        break;
    }
    }

    if (symbolWrapper) {
        object->putDirectWithoutTransition(vm, propertyName, symbolWrapper);
        propertySlot.setValue(object, None, symbolWrapper);
        return true;
    }

    return false;
}

#if DEBUG
// There are more then 10000+ global object properties. When the debugger is attached,
// it calls this method on every breakpoint/step-in, which is *really* slow.
// On devices with not enough free memory, it even crashes the running application.
//
// This method is used only for testing now.
// It materializes all Objective-C classes and their methods and their parameter types.
//
// Once we start grouping declarations by modules, this can be safely restored.
void GlobalObject::getOwnPropertyNames(JSObject* object, ExecState* execState, PropertyNameArray& propertyNames, EnumerationMode enumerationMode) {
    MetaFileReader* metadata = getMetadata();
    for (MetaIterator it = metadata->begin(); it != metadata->end(); ++it) {
        propertyNames.add(Identifier(execState, (*it)->jsName()));
    }

    Base::getOwnPropertyNames(object, execState, propertyNames, enumerationMode);
}
#endif

ObjCConstructorBase* GlobalObject::constructorFor(Class klass, Class fallback) {
    ASSERT(klass);

    auto kvp = this->_objCConstructors.find(klass);
    if (kvp != this->_objCConstructors.end()) {
        return kvp->second.get();
    }

    const Meta* meta = getMetadata()->findMeta(class_getName(klass));
    while (!meta) {
        klass = class_getSuperclass(klass);
        meta = getMetadata()->findMeta(class_getName(klass));
    }

    if (klass == [NSObject class] && fallback) {
        return constructorFor(fallback);
    }

    kvp = this->_objCConstructors.find(klass);
    if (kvp != this->_objCConstructors.end()) {
        return kvp->second.get();
    }

    ObjCConstructorNative* constructor = this->_typeFactory.get()->getObjCNativeConstructor(this, meta->jsName());
    this->_objCConstructors.insert(std::pair<Class, Strong<ObjCConstructorBase>>(klass, Strong<ObjCConstructorBase>(this->vm(), constructor)));
    this->putDirectWithoutTransition(this->vm(), Identifier(this->globalExec(), class_getName(klass)), constructor);
    return constructor;
}

ObjCProtocolWrapper* GlobalObject::protocolWrapperFor(Protocol* aProtocol) {
    ASSERT(aProtocol);

    auto kvp = this->_objCProtocolWrappers.find(aProtocol);
    if (kvp != this->_objCProtocolWrappers.end()) {
        return kvp->second.get();
    }

    CString protocolName = protocol_getName(aProtocol);
    const Meta* meta = getMetadata()->findMeta(protocolName.data());
    if (meta && meta->type() != MetaType::ProtocolType) {
        protocolName = WTF::String::format("%sProtocol", protocolName.data()).utf8();
        meta = getMetadata()->findMeta(protocolName.data());
    }

    ObjCProtocolWrapper* protocolWrapper = ObjCProtocolWrapper::create(this->vm(), ObjCProtocolWrapper::createStructure(this->vm(), this, this->objectPrototype()), static_cast<const ProtocolMeta*>(meta), aProtocol);
    this->_objCProtocolWrappers.insert(std::pair<const Protocol*, Strong<ObjCProtocolWrapper>>(aProtocol, Strong<ObjCProtocolWrapper>(this->vm(), protocolWrapper)));
    this->putDirectWithoutTransition(this->vm(), Identifier(this->globalExec(), protocolName.data()), protocolWrapper, DontDelete | ReadOnly);

    return protocolWrapper;
}

void GlobalObject::queueTaskToEventLoop(const JSGlobalObject* globalObject, WTF::PassRefPtr<Microtask> task) {
    CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopCommonModes, ^{
            JSLockHolder lock(globalObject->vm());
            task->run(const_cast<JSGlobalObject*>(globalObject)->globalExec());
    });
}
}
