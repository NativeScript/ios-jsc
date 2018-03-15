//
//  GlobalObject.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 14.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "GlobalObject.h"
#include "AllocatedPlaceholder.h"
#include "FFICallPrototype.h"
#include "FFIFunctionCall.h"
#include "FFIFunctionCallback.h"
#include "Interop.h"
#include "JSWeakRefConstructor.h"
#include "JSWeakRefInstance.h"
#include "JSWeakRefPrototype.h"
#include "JSWorkerConstructor.h"
#include "JSWorkerInstance.h"
#include "JSWorkerPrototype.h"
#include "Metadata.h"
#include "ObjCBlockCall.h"
#include "ObjCBlockCallback.h"
#include "ObjCConstructorCall.h"
#include "ObjCConstructorDerived.h"
#include "ObjCConstructorNative.h"
#include "ObjCExtend.h"
#include "ObjCFastEnumerationIterator.h"
#include "ObjCFastEnumerationIteratorPrototype.h"
#include "ObjCMethodCall.h"
#include "ObjCMethodCallback.h"
#include "ObjCProtocolWrapper.h"
#include "ObjCPrototype.h"
#include "ObjCTypeScriptExtend.h"
#include "ObjCTypes.h"
#include "RecordConstructor.h"
#include "RecordPrototypeFunctions.h"
#include "SymbolLoader.h"
#include "TypeFactory.h"
#include "UnmanagedType.h"
#include "__extends.h"
#include "inlineFunctions.h"
#include "inspector/GlobalObjectInspectorController.h"
#include "smartStringify.h"
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/FunctionConstructor.h>
#include <JavaScriptCore/FunctionPrototype.h>
#include <JavaScriptCore/JSGlobalObjectFunctions.h>
#include <JavaScriptCore/Microtask.h>
#include <JavaScriptCore/StrongInlines.h>
#include <JavaScriptCore/inspector/JSGlobalObjectConsoleClient.h>
#include <JavaScriptCore/runtime/VMEntryScope.h>
#include <chrono>
#include <string>

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

JSC::EncodedJSValue JSC_HOST_CALL NSObjectAlloc(JSC::ExecState* execState) {
    ObjCConstructorBase* constructor = jsCast<ObjCConstructorBase*>(execState->thisValue().asCell());
    Class klass = constructor->klass();
    id instance = [klass alloc];
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    if (ObjCConstructorDerived* constructorDerived = jsDynamicCast<ObjCConstructorDerived*>(execState->vm(), constructor)) {
        [instance release];
        JSValue jsValue = toValue(execState, instance, ^{
          return constructorDerived->instancesStructure();
        });
        return JSValue::encode(jsValue);
    } else if (ObjCConstructorNative* nativeConstructor = jsDynamicCast<ObjCConstructorNative*>(execState->vm(), constructor)) {
        AllocatedPlaceholder* allocatedPlaceholder = AllocatedPlaceholder::create(execState->vm(), globalObject, nativeConstructor->allocatedPlaceholderStructure(), instance, nativeConstructor->instancesStructure());
        return JSValue::encode(allocatedPlaceholder);
    }

    ASSERT_NOT_REACHED();
    return JSValue::encode(jsUndefined());
}

static ObjCProtocolWrapper* createProtocolWrapper(GlobalObject* globalObject, const ProtocolMeta* protocolMeta, Protocol* aProtocol) {
    Structure* prototypeStructure = ObjCPrototype::createStructure(globalObject->vm(), globalObject, globalObject->objectPrototype());
    ObjCPrototype* prototype = ObjCPrototype::create(globalObject->vm(), globalObject, prototypeStructure, protocolMeta);
    Structure* protocolWrapperStructure = ObjCProtocolWrapper::createStructure(globalObject->vm(), globalObject, globalObject->objectPrototype());
    ObjCProtocolWrapper* protocolWrapper = ObjCProtocolWrapper::create(globalObject->vm(), protocolWrapperStructure, prototype, protocolMeta, aProtocol);
    prototype->materializeProperties(globalObject->vm(), globalObject);
    return protocolWrapper;
}

const ClassInfo GlobalObject::s_info = { "NativeScriptGlobal", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(GlobalObject) };

const unsigned GlobalObject::StructureFlags = OverridesGetOwnPropertySlot | Base::StructureFlags;

const GlobalObjectMethodTable GlobalObject::globalObjectMethodTable = { &supportsRichSourceInfo, &shouldInterruptScript, &javaScriptRuntimeFlags, &queueTaskToEventLoop, &shouldInterruptScriptBeforeTimeout, &moduleLoaderImportModule, &moduleLoaderResolve, &moduleLoaderFetch, &moduleLoaderInstantiate, &moduleLoaderEvaluate, nullptr /*promiseRejectionTracker*/, &defaultLanguage };

GlobalObject::GlobalObject(VM& vm, Structure* structure)
    : JSGlobalObject(vm, structure, &GlobalObject::globalObjectMethodTable) {
}

GlobalObject::~GlobalObject() {
    this->_inspectorController->globalObjectDestroyed();
}

extern "C" void JSSynchronousGarbageCollectForDebugging(ExecState*);
static EncodedJSValue JSC_HOST_CALL collectGarbage(ExecState* execState) {
    JSSynchronousGarbageCollectForDebugging(execState->lexicalGlobalObject()->globalExec());
    return JSValue::encode(jsUndefined());
}

static EncodedJSValue JSC_HOST_CALL time(ExecState* execState) {
    auto nano = std::chrono::time_point_cast<std::chrono::nanoseconds>(std::chrono::steady_clock::now());
    double duration = nano.time_since_epoch().count() / 1000000.0;
    return JSValue::encode(jsNumber(duration));
}

static void microtaskRunLoopSourcePerformWork(void* context) {
    GlobalObject* self = static_cast<GlobalObject*>(context);
    JSLockHolder lockHolder(self->vm());
    self->drainMicrotasks();
}

static void runLoopBeforeWaitingPerformWork(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void* info) {
    GlobalObject* self = static_cast<GlobalObject*>(info);
    JSC::JSLockHolder lock(self->vm());
    VMEntryScope* currentEntryScope = self->vm().entryScope;
    if (self->vm().topCallFrame && currentEntryScope && !currentEntryScope->didPopListeners().isEmpty()) {
        FFIFunctionCall* function_call = jsDynamicCast<FFIFunctionCall*>(self->vm(), self->vm().topCallFrame->callee().asCell());
        const Meta* meta = Metadata::MetaFile::instance()->globalTable()->findMeta("UIApplicationMain");

        if (function_call && meta && function_call->functionPointer() == SymbolLoader::instance().loadFunctionSymbol(meta->topLevelModule(), meta->name())) {

            self->vm().entryScope = nullptr;

            for (auto& listener : currentEntryScope->didPopListeners())
                listener();

            currentEntryScope->didPopListeners().clear();

            self->vm().entryScope = currentEntryScope;
        }
    }
}

void GlobalObject::finishCreation(VM& vm, WTF::String applicationPath) {
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

    this->_workerConstructorStructure.set(vm, this, JSWorkerConstructor::createStructure(vm, this, Base::functionPrototype()));
    this->_workerPrototypeStructure.set(vm, this, JSWorkerPrototype::createStructure(vm, this, Base::objectPrototype()));
    JSWorkerPrototype* workerPrototype = JSWorkerPrototype::create(vm, this, this->workerPrototypeStructure());
    this->_workerInstanceStructure.set(vm, this, JSWorkerInstance::createStructure(vm, this, workerPrototype));
    this->putDirect(vm, Identifier::fromString(&vm, WTF::ASCIILiteral("Worker")), JSWorkerConstructor::create(vm, this->workerConstructorStructure(), workerPrototype));

    auto fastEnumerationIteratorPrototype = ObjCFastEnumerationIteratorPrototype::create(vm, this, ObjCFastEnumerationIteratorPrototype::createStructure(vm, this, this->objectPrototype()));
    this->_fastEnumerationIteratorStructure.set(vm, this, ObjCFastEnumerationIterator::createStructure(vm, this, fastEnumerationIteratorPrototype));

    JSC::Structure* unmanagedPrototypeStructure = UnmanagedPrototype::createStructure(vm, this, this->objectPrototype());
    UnmanagedPrototype* unmanagedPrototype = UnmanagedPrototype::create(vm, this, unmanagedPrototypeStructure);
    this->_unmanagedInstanceStructure.set(vm, this, UnmanagedInstance::createStructure(this, unmanagedPrototype));

    this->_interopIdentifier = Identifier::fromString(&vm, Interop::info()->className);
    this->_interop.set(vm, this, Interop::create(vm, this, Interop::createStructure(vm, this, this->objectPrototype())));

    this->putDirectNativeFunction(vm, this, Identifier::fromString(globalExec, "__collect"), 0, &collectGarbage, NoIntrinsic, DontEnum);

    this->putDirectNativeFunction(vm, this, Identifier::fromString(globalExec, "__time"), 0, &time, NoIntrinsic, DontEnum);

    this->_smartStringifyFunction.set(vm, this, jsCast<JSFunction*>(evaluate(this->globalExec(), makeSource(WTF::String(smartStringify_js, smartStringify_js_len), SourceOrigin()), JSValue())));

#ifdef DEBUG
    SourceCode sourceCode = makeSource(WTF::String(__extends_js, __extends_js_len), SourceOrigin(), WTF::ASCIILiteral("__extends.ts"));
#else
    SourceCode sourceCode = makeSource(WTF::String(__extends_js, __extends_js_len), SourceOrigin());
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

    NSObjectConstructor->setPrototypeDirect(vm, NSObjectPrototype);

    CFRunLoopSourceContext context = { 0, this, 0, 0, 0, 0, 0, 0, 0, microtaskRunLoopSourcePerformWork };
    CFRunLoopObserverContext observerContext = { 0, this, NULL, NULL, NULL };

    _microtaskRunLoopSource = WTF::adoptCF(CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context));
    _runLoopBeforeWaitingObserver = WTF::adoptCF(CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, YES, 0, &runLoopBeforeWaitingPerformWork, &observerContext));

    _commonJSModuleFunctionIdentifier = Identifier::fromString(&vm, "CommonJSModuleFunction");
    this->putDirectNativeFunction(vm, this, Identifier::fromString(&vm, "require"), 1, commonJSRequire, NoIntrinsic, DontEnum | DontDelete | ReadOnly);

    this->putDirect(vm, Identifier::fromString(&vm, "__runtimeVersion"), jsString(&vm, STRINGIZE_VALUE_OF(NATIVESCRIPT_VERSION)), DontEnum | ReadOnly | DontDelete);

    NakedPtr<Exception> exception;
    evaluate(this->globalExec(), makeSource(WTF::String(inlineFunctions_js, inlineFunctions_js_len), SourceOrigin()), JSValue(), exception);
    ASSERT_WITH_MESSAGE(!exception, "Error while evaluating inlineFunctions.js: %s", exception->value().toWTFString(this->globalExec()).utf8().data());

    _jsUncaughtErrorCallbackIdentifier = Identifier::fromString(&vm, "onerror"); // Keep in sync with TNSExceptionHandler.h
    _jsUncaughtErrorCallbackIdentifierFallback = Identifier::fromString(&vm, "__onUncaughtError"); // Keep in sync with TNSExceptionHandler.h
}

void GlobalObject::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(cell);
    Base::visitChildren(globalObject, visitor);

    visitor.append(globalObject->_interop);
    visitor.append(globalObject->_typeFactory);
    visitor.append(globalObject->_typeScriptOriginalExtendsFunction);
    visitor.append(globalObject->_smartStringifyFunction);
    visitor.append(globalObject->_ffiCallPrototype);
    visitor.append(globalObject->_objCMethodCallStructure);
    visitor.append(globalObject->_objCConstructorCallStructure);
    visitor.append(globalObject->_objCBlockCallStructure);
    visitor.append(globalObject->_ffiFunctionCallStructure);
    visitor.append(globalObject->_objCBlockCallbackStructure);
    visitor.append(globalObject->_objCMethodCallbackStructure);
    visitor.append(globalObject->_ffiFunctionCallbackStructure);
    visitor.append(globalObject->_recordFieldGetterStructure);
    visitor.append(globalObject->_recordFieldSetterStructure);
    visitor.append(globalObject->_unmanagedInstanceStructure);
    visitor.append(globalObject->_weakRefConstructorStructure);
    visitor.append(globalObject->_weakRefPrototypeStructure);
    visitor.append(globalObject->_weakRefInstanceStructure);
    visitor.append(globalObject->_workerConstructorStructure);
    visitor.append(globalObject->_workerInstanceStructure);
    visitor.append(globalObject->_workerPrototypeStructure);
    visitor.append(globalObject->_fastEnumerationIteratorStructure);
}
/// This method is called whenever a property on the global JavaScript object is accessed for the first time.
/// It is called once for each property and cached by JSC, i.e. it is never called again for the same property.
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

        symbolWrapper = createProtocolWrapper(globalObject, static_cast<const ProtocolMeta*>(symbolMeta), aProtocol);
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
            symbolWrapper = getFFITypeMethodTable(vm, symbolType).read(execState, varSymbol, symbolType);
        }
        break;
    }
    case JsCode: {
        WTF::String source = WTF::String(static_cast<const JsCodeMeta*>(symbolMeta)->jsCode());
        symbolWrapper = evaluate(execState, makeSource(source, SourceOrigin()));
        break;
    }
    default: {
        break;
    }
    }

    if (!symbolWrapper) {
        WTF::String errorMessage = WTF::String::format("Metadata for \"%s.%s\" found but symbol not available at runtime.",
                                                       symbolMeta->topLevelModule()->getName(), symbolMeta->name(), symbolMeta->name());
        JSC::VM& vm = execState->vm();
        auto scope = DECLARE_THROW_SCOPE(vm);

        throwVMError(execState, scope, createReferenceError(execState, errorMessage));
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

    ObjCProtocolWrapper* protocolWrapper = createProtocolWrapper(this, static_cast<const ProtocolMeta*>(meta), aProtocol);

    this->_objCProtocolWrappers.insert({ aProtocol, Strong<ObjCProtocolWrapper>(this->vm(), protocolWrapper) });
    this->putDirectWithoutTransition(this->vm(), Identifier::fromString(this->globalExec(), meta->jsName()), protocolWrapper, DontDelete | ReadOnly);

    return protocolWrapper;
}

bool GlobalObject::callJsUncaughtErrorCallback(ExecState* execState, Exception* exception, NakedPtr<Exception>& outException) {
    outException = nullptr;
    JSValue callback = this->get(execState, _jsUncaughtErrorCallbackIdentifier);

    CallData callData;
    CallType callType = JSC::getCallData(callback, callData);
    if (callType == JSC::CallType::None) {
        callback = execState->lexicalGlobalObject()->get(execState, _jsUncaughtErrorCallbackIdentifierFallback);
        callType = JSC::getCallData(callback, callData);
        if (callType == JSC::CallType::None) {
            return false;
        }
    }

    MarkedArgumentBuffer uncaughtErrorArguments;
    uncaughtErrorArguments.append(exception->value());

    JSValue result = call(execState, callback, callType, callData, jsUndefined(), uncaughtErrorArguments, outException);

    if (outException) {
        warn(execState, outException->value().toWTFString(execState));
        return false;
    }

    return result.toBoolean(execState);
}

void GlobalObject::queueTaskToEventLoop(JSGlobalObject& globalObject, WTF::Ref<Microtask>&& task) {
    auto self = static_cast<GlobalObject*>(&globalObject);
    self->_microtasksQueue.append(WTFMove(task));
    CFRunLoopSourceSignal(self->_microtaskRunLoopSource.get());
    for (auto runLoop : self->microtaskRunLoops()) {
        CFRunLoopWakeUp(runLoop.get());
    }
}

void GlobalObject::drainMicrotasks() {
    while (!this->_microtasksQueue.isEmpty()) {
        this->_microtasksQueue.takeFirst()->run(this->globalExec());
    }
}

WTF::String GlobalObject::defaultLanguage() {
    return "en";
}
}
