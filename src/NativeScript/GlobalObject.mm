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
#include <JavaScriptCore/Microtask.h>
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/StrongInlines.h>
#include <JavaScriptCore/JSGlobalObjectFunctions.h>
#include <JavaScriptCore/runtime/JSConsole.h>
#include <JavaScriptCore/inspector/JSGlobalObjectConsoleClient.h>
#include "ObjCProtocolWrapper.h"
#include "ObjCConstructorNative.h"
#include "ObjCPrototype.h"
#include "Metadata.h"
#include "SymbolLoader.h"
#include "FFIFunctionCall.h"
#include "RecordConstructor.h"
#include "RecordPrototypeFunctions.h"
#include "Interop.h"
#include "inspector/GlobalObjectInspectorController.h"
#include "ObjCExtend.h"
#include "ObjCTypeScriptExtend.h"
#include "__extends.h"
#include "ObjCMethodCall.h"
#include "ObjCConstructorCall.h"
#include "ObjCConstructorDerived.h"
#include "ObjCBlockCall.h"
#include "ObjCBlockCallback.h"
#include "ObjCMethodCallback.h"
#include "FFIFunctionCallback.h"
#include "JSWeakRefConstructor.h"
#include "JSWeakRefPrototype.h"
#include "JSWeakRefInstance.h"
#include "TypeFactory.h"
#include "ObjCFastEnumerationIterator.h"
#include "ObjCFastEnumerationIteratorPrototype.h"
#include "AllocatedPlaceholder.h"
#include "ObjCTypes.h"
#include "FFICallPrototype.h"
#include "UnmanagedType.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

JSC::EncodedJSValue JSC_HOST_CALL NSObjectAlloc(JSC::ExecState* execState) {
    ObjCConstructorBase* constructor = jsCast<ObjCConstructorBase*>(execState->thisValue().asCell());
    Class klass = constructor->klass();
    id instance = [klass alloc];
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    if (ObjCConstructorDerived* constructorDerived = jsDynamicCast<ObjCConstructorDerived*>(constructor)) {
        [instance release];
        JSValue jsValue = toValue(execState, instance, ^{
          return constructorDerived->instancesStructure();
        });
        return JSValue::encode(jsValue);
    } else if (ObjCConstructorNative* nativeConstructor = jsDynamicCast<ObjCConstructorNative*>(constructor)) {
        AllocatedPlaceholder* allocatedPlaceholder = AllocatedPlaceholder::create(execState->vm(), globalObject, nativeConstructor->allocatedPlaceholderStructure(), instance, nativeConstructor->instancesStructure());
        return JSValue::encode(allocatedPlaceholder);
    }

    ASSERT_NOT_REACHED();
    return JSValue::encode(jsUndefined());
}

const ClassInfo GlobalObject::s_info = { "NativeScriptGlobal", &Base::s_info, 0, CREATE_METHOD_TABLE(GlobalObject) };

const unsigned GlobalObject::StructureFlags = OverridesGetOwnPropertySlot | Base::StructureFlags;

const GlobalObjectMethodTable GlobalObject::globalObjectMethodTable = { &allowsAccessFrom, &supportsProfiling, &supportsRichSourceInfo, &shouldInterruptScript, &javaScriptRuntimeFlags, &queueTaskToEventLoop, &shouldInterruptScriptBeforeTimeout, 0, 0, 0, 0, 0 };

GlobalObject::GlobalObject(VM& vm, Structure* structure)
    : JSGlobalObject(vm, structure, &GlobalObject::globalObjectMethodTable)
{
}

GlobalObject::~GlobalObject() {
    this->_inspectorController->globalObjectDestroyed();
}

Structure* GlobalObject::createStructure(VM& vm, JSValue prototype) {
    return Structure::create(vm, 0, prototype, TypeInfo(GlobalObjectType, GlobalObject::StructureFlags), GlobalObject::info());
}

GlobalObject* GlobalObject::create(WTF::String applicationPath, VM& vm, Structure* structure) {
    GlobalObject* object = new (NotNull, allocateCell<GlobalObject>(vm.heap)) GlobalObject(vm, structure);
    object->finishCreation(applicationPath, vm);
    vm.heap.addFinalizer(object, destroy);
    return object;
}

extern "C" void JSSynchronousGarbageCollectForDebugging(ExecState*);
static EncodedJSValue JSC_HOST_CALL collectGarbage(ExecState* execState) {
    JSSynchronousGarbageCollectForDebugging(execState->lexicalGlobalObject()->globalExec());
    return JSValue::encode(jsUndefined());
}

void GlobalObject::finishCreation(WTF::String applicationPath, VM& vm) {
    Base::finishCreation(vm);

    ExecState* globalExec = this->globalExec();

    this->_inspectorController = std::make_unique<GlobalObjectInspectorController>(*this);
    this->_inspectorController->setIncludesNativeCallStackWhenReportingExceptions(false);
    this->setConsoleClient(this->_inspectorController->consoleClient());
    this->putDirect(vm, vm.propertyNames->global, globalExec->globalThisValue(), DontEnum | ReadOnly | DontDelete);

    this->_applicationPath = applicationPath;

    this->_ffiCallPrototype.set(vm, this, FFICallPrototype::create(vm, this, FFICallPrototype::createStructure(vm, this, this->functionPrototype())));
    this->_objCMethodCallStructure.set(vm, this, ObjCMethodCall::createStructure(vm, this, this->ffiCallPrototype()));
    this->_objCConstructorCallStructure.set(vm, this, ObjCConstructorCall::createStructure(vm, this, this->functionPrototype()));
    this->_objCBlockCallStructure.set(vm, this, ObjCBlockCall::createStructure(vm, this, this->ffiCallPrototype()));
    this->_ffiFunctionCallStructure.set(vm, this, FFIFunctionCall::createStructure(vm, this, this->ffiCallPrototype()));
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
    this->putDirect(vm, Identifier::fromString(&vm, WTF::ASCIILiteral("WeakRef")), JSWeakRefConstructor::create(vm, this->weakRefConstructorStructure(), weakRefPrototype));

    auto fastEnumerationIteratorPrototype = ObjCFastEnumerationIteratorPrototype::create(vm, this, ObjCFastEnumerationIteratorPrototype::createStructure(vm, this, this->objectPrototype()));
    this->_fastEnumerationIteratorStructure.set(vm, this, ObjCFastEnumerationIterator::createStructure(vm, this, fastEnumerationIteratorPrototype));

    JSC::Structure* unmanagedPrototypeStructure = UnmanagedPrototype::createStructure(vm, this, this->objectPrototype());
    UnmanagedPrototype* unmanagedPrototype = UnmanagedPrototype::create(vm, this, unmanagedPrototypeStructure);
    this->_unmanagedInstanceStructure.set(vm, this, UnmanagedInstance::createStructure(this, unmanagedPrototype));

    this->_interopIdentifier = Identifier::fromString(&vm, Interop::info()->className);
    this->_interop.set(vm, this, Interop::create(vm, this, Interop::createStructure(vm, this, this->objectPrototype())));

    this->putDirectNativeFunction(vm, this, Identifier::fromString(globalExec, "__collect"), 0, &collectGarbage, NoIntrinsic, DontEnum);

#ifdef DEBUG
    SourceCode sourceCode = makeSource(WTF::String(__extends_js, __extends_js_len), WTF::ASCIILiteral("__extends.ts"));
#else
    SourceCode sourceCode = makeSource(WTF::String(__extends_js, __extends_js_len));
#endif
    this->_typeScriptOriginalExtendsFunction.set(vm, this, jsCast<JSFunction*>(evaluate(globalExec, sourceCode, globalExec->thisValue())));
    this->putDirectNativeFunction(vm, this, Identifier::fromString(globalExec, "__extends"), 2, ObjCTypeScriptExtendFunction, NoIntrinsic, DontEnum | DontDelete | ReadOnly);

    ObjCConstructorNative* NSObjectConstructor = this->typeFactory()->NSObjectConstructor(this);
    NSObjectConstructor->putDirectNativeFunction(vm, this, Identifier::fromString(&vm, WTF::ASCIILiteral("extend")), 2, ObjCExtendFunction, NoIntrinsic, DontEnum);
    NSObjectConstructor->putDirectNativeFunction(vm, this, Identifier::fromString(&vm, WTF::ASCIILiteral("alloc")), 0, NSObjectAlloc, NoIntrinsic, DontDelete);

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
    visitor.append(&globalObject->_ffiCallPrototype);
    visitor.append(&globalObject->_objCMethodCallStructure);
    visitor.append(&globalObject->_objCConstructorCallStructure);
    visitor.append(&globalObject->_objCBlockCallStructure);
    visitor.append(&globalObject->_ffiFunctionCallStructure);
    visitor.append(&globalObject->_objCBlockCallbackStructure);
    visitor.append(&globalObject->_objCMethodCallbackStructure);
    visitor.append(&globalObject->_ffiFunctionCallbackStructure);
    visitor.append(&globalObject->_recordFieldGetterStructure);
    visitor.append(&globalObject->_recordFieldSetterStructure);
    visitor.append(&globalObject->_unmanagedInstanceStructure);
    visitor.append(&globalObject->_weakRefConstructorStructure);
    visitor.append(&globalObject->_weakRefPrototypeStructure);
    visitor.append(&globalObject->_weakRefInstanceStructure);
    visitor.append(&globalObject->_fastEnumerationIteratorStructure);
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
    if (symbolName == nullptr)
        return false;
    
    const Meta* symbolMeta = Metadata::MetaFile::instance()->globalTable()->findMeta(symbolName);
    if (symbolMeta == nullptr)
        return false;

    JSValue symbolWrapper;

    switch (symbolMeta->type()) {
    case Interface: {
        Class klass = objc_getClass(symbolMeta->name());
        if (!klass) {
            SymbolLoader::instance().ensureModule(symbolMeta->topLevelModule());
            klass = objc_getClass(symbolMeta->name());
        }

        if (klass) {
            symbolWrapper = globalObject->_typeFactory.get()->getObjCNativeConstructor(globalObject, symbolMeta->jsName());
            globalObject->_objCConstructors.insert({ klass, Strong<ObjCConstructorBase>(vm, jsCast<ObjCConstructorBase*>(symbolWrapper)) });
        }
        break;
    }
    case ProtocolType: {
        Protocol* aProtocol = objc_getProtocol(symbolMeta->name());
        if (!aProtocol) {
            SymbolLoader::instance().ensureModule(symbolMeta->topLevelModule());
            aProtocol = objc_getProtocol(symbolMeta->name());
        }

        symbolWrapper = ObjCProtocolWrapper::create(vm, ObjCProtocolWrapper::createStructure(vm, globalObject, globalObject->objectPrototype()), static_cast<const ProtocolMeta*>(symbolMeta), aProtocol);
        if (aProtocol) {
            globalObject->_objCProtocolWrappers.insert({ aProtocol, Strong<ObjCProtocolWrapper>(vm, jsCast<ObjCProtocolWrapper*>(symbolWrapper)) });
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
        void* functionSymbol = SymbolLoader::instance().loadFunctionSymbol(symbolMeta->topLevelModule(), symbolMeta->name());
        if (functionSymbol) {
            const FunctionMeta* functionMeta = static_cast<const FunctionMeta*>(symbolMeta);
            const Metadata::TypeEncoding* encodingPtr = functionMeta->encodings()->first();
            JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, encodingPtr);
            const WTF::Vector<JSCell*> parametersTypes = globalObject->typeFactory()->parseTypes(globalObject, encodingPtr, (int)functionMeta->encodings()->count - 1);

            if (functionMeta->returnsUnmanaged()) {
                JSC::Structure* unmanagedStructure = UnmanagedType::createStructure(vm, globalObject, jsNull());
                returnType = UnmanagedType::create(vm, returnType, unmanagedStructure);
            }

            symbolWrapper = FFIFunctionCall::create(vm, globalObject->ffiFunctionCallStructure(), functionSymbol, functionMeta->jsName(), returnType, parametersTypes, functionMeta->ownsReturnedCocoaObject());
        }
        break;
    }
    case Var: {
        const VarMeta* varMeta = static_cast<const VarMeta*>(symbolMeta);
        void* varSymbol = SymbolLoader::instance().loadDataSymbol(varMeta->topLevelModule(), varMeta->name());
        if (varSymbol) {
            const Metadata::TypeEncoding* encoding = varMeta->encoding();
            JSCell* symbolType = globalObject->typeFactory()->parseType(globalObject, encoding);
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

    if (!symbolWrapper) {
        WTF::String errorMessage = WTF::String::format("Metadata for \"%s.%s\" found but symbol not available at runtime.",
                                                       symbolMeta->topLevelModule()->getName(), symbolMeta->name(), symbolMeta->name());
        throwVMError(execState, createReferenceError(execState, errorMessage));
        propertySlot.setValue(object, None, jsUndefined());
        return true;
    }

    object->putDirectWithoutTransition(vm, propertyName, symbolWrapper);
    propertySlot.setValue(object, None, symbolWrapper);
    return true;
}

#ifdef DEBUG
// There are more then 10000+ global object properties. When the debugger is attached,
// it calls this method on every breakpoint/step-in, which is *really* slow.
// On devices with not enough free memory, it even crashes the running application.
//
// This method is used only for testing now.
// It materializes all Objective-C classes and their methods and their parameter types.
//
// Once we start grouping declarations by modules, this can be safely restored.
void GlobalObject::getOwnPropertyNames(JSObject* object, ExecState* execState, PropertyNameArray& propertyNames, EnumerationMode enumerationMode) {
    if (!jsCast<GlobalObject*>(object)->hasDebugger()) {
        const GlobalTable* globalTable = MetaFile::instance()->globalTable();
        for (const Meta* meta : *globalTable) {
            if (meta->isAvailable()) {
                propertyNames.add(Identifier::fromString(execState, meta->jsName()));
            }
        }
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

    const Meta* meta = MetaFile::instance()->globalTable()->findMeta(class_getName(klass));
    while (!(meta && meta->type() == MetaType::Interface)) {
        klass = class_getSuperclass(klass);
        meta = MetaFile::instance()->globalTable()->findMeta(class_getName(klass));
    }

    if (klass == [NSObject class] && fallback) {
        return constructorFor(fallback);
    }

    kvp = this->_objCConstructors.find(klass);
    if (kvp != this->_objCConstructors.end()) {
        return kvp->second.get();
    }

    ObjCConstructorNative* constructor = this->_typeFactory.get()->getObjCNativeConstructor(this, meta->jsName());
    this->_objCConstructors.insert({ klass, Strong<ObjCConstructorBase>(this->vm(), constructor) });
    this->putDirect(this->vm(), Identifier::fromString(this->globalExec(), class_getName(klass)), constructor);
    return constructor;
}

ObjCProtocolWrapper* GlobalObject::protocolWrapperFor(Protocol* aProtocol) {
    ASSERT(aProtocol);

    auto kvp = this->_objCProtocolWrappers.find(aProtocol);
    if (kvp != this->_objCProtocolWrappers.end()) {
        return kvp->second.get();
    }

    CString protocolName = protocol_getName(aProtocol);
    const Meta* meta = MetaFile::instance()->globalTable()->findMeta(protocolName.data());
    if (meta && meta->type() != MetaType::ProtocolType) {
        WTF::String newProtocolname = WTF::String::format("%sProtocol", protocolName.data());

        size_t protocolIndex = 2;
        while (objc_getProtocol(newProtocolname.utf8().data())) {
            newProtocolname = WTF::String::format("%sProtocol%d", protocolName.data(), protocolIndex++);
        }

        meta = MetaFile::instance()->globalTable()->findMeta(newProtocolname.utf8().data());
    }
    ASSERT(meta && meta->type() == MetaType::ProtocolType);

    ObjCProtocolWrapper* protocolWrapper = ObjCProtocolWrapper::create(this->vm(), ObjCProtocolWrapper::createStructure(this->vm(), this, this->objectPrototype()), static_cast<const ProtocolMeta*>(meta), aProtocol);
    this->_objCProtocolWrappers.insert({ aProtocol, Strong<ObjCProtocolWrapper>(this->vm(), protocolWrapper) });
    this->putDirectWithoutTransition(this->vm(), Identifier::fromString(this->globalExec(), meta->jsName()), protocolWrapper, DontDelete | ReadOnly);

    return protocolWrapper;
}

void GlobalObject::queueTaskToEventLoop(const JSGlobalObject* globalObject, WTF::PassRefPtr<Microtask> task) {
    auto global = jsCast<const GlobalObject*>(globalObject);
    CFRunLoopRef runLoop = global->_microtaskRunLoop.get() ?: CFRunLoopGetCurrent();
    CFTypeRef mode = global->_microtaskRunLoopMode.get() ?: kCFRunLoopCommonModes;

    CFRunLoopPerformBlock(runLoop, mode, ^{
      JSLockHolder lock(globalObject->vm());
      task->run(const_cast<JSGlobalObject*>(globalObject)->globalExec());
    });
    CFRunLoopWakeUp(runLoop);
}
}
