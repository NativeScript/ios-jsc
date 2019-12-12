//
//  GlobalObject.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 14.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "GlobalObject.h"
#include "AllocatedPlaceholder.h"
#include "CFunctionWrapper.h"
#include "FFICallPrototype.h"
#include "FFIFunctionCallback.h"
#include "Interop.h"
#include "JSErrors.h"
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
#include "ObjCWrapperObject.h"
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
#include <JavaScriptCore/Microtask.h>
#include <JavaScriptCore/inspector/JSGlobalObjectConsoleClient.h>
#include <JavaScriptCore/runtime/JSGlobalObjectFunctions.h>
#include <JavaScriptCore/runtime/VMEntryScope.h>
#include <chrono>
#include <string>

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

JSC::EncodedJSValue JSC_HOST_CALL NSObjectAlloc(JSC::ExecState* execState) {
    ObjCConstructorBase* constructor = jsCast<ObjCConstructorBase*>(execState->thisValue().asCell());
    Class klass = constructor->klasses().realClass();
    id instance = [klass alloc];
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    JSValue ret = jsUndefined();

    if (ObjCConstructorDerived* constructorDerived = jsDynamicCast<ObjCConstructorDerived*>(execState->vm(), constructor)) {
        ret = toValue(execState, instance, ^{
          return constructorDerived->instancesStructure();
        });
        // Now owned by the wrapper created in toValue
        [instance release];
    } else if (ObjCConstructorNative* nativeConstructor = jsDynamicCast<ObjCConstructorNative*>(execState->vm(), constructor)) {
        ret = AllocatedPlaceholder::create(execState->vm(),
                                           globalObject,
                                           nativeConstructor->allocatedPlaceholderStructure(),
                                           instance,
                                           nativeConstructor->instancesStructure())
                  .get();
        // No release -> give ownership to AllocatedPlaceholder, it will be relinquished after the init call in ObjCMethodWrapper::postInvocation
    } else {
        ASSERT_NOT_REACHED();
    }

    return JSValue::encode(ret);
}

static Strong<ObjCProtocolWrapper> createProtocolWrapper(GlobalObject* globalObject, const ProtocolMeta* protocolMeta, Protocol* aProtocol) {
    Structure* prototypeStructure = ObjCPrototype::createStructure(globalObject->vm(), globalObject, globalObject->objectPrototype());
    auto prototype = ObjCPrototype::create(globalObject->vm(), globalObject, prototypeStructure, protocolMeta, ConstructorKey());
    Structure* protocolWrapperStructure = ObjCProtocolWrapper::createStructure(globalObject->vm(), globalObject, globalObject->objectPrototype());
    auto protocolWrapper = ObjCProtocolWrapper::create(globalObject->vm(), protocolWrapperStructure, prototype.get(), protocolMeta, aProtocol);
    prototype->materializeProperties(globalObject->vm(), globalObject);
    return protocolWrapper;
}

const ClassInfo GlobalObject::s_info = { "NativeScriptGlobal", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(GlobalObject) };

const unsigned GlobalObject::StructureFlags = OverridesGetOwnPropertySlot | Base::StructureFlags;

const GlobalObjectMethodTable GlobalObject::globalObjectMethodTable = { &supportsRichSourceInfo, &shouldInterruptScript,
                                                                        &javaScriptRuntimeFlags, &queueTaskToEventLoop, &shouldInterruptScriptBeforeTimeout, &moduleLoaderImportModule,
                                                                        &moduleLoaderResolve, &moduleLoaderFetch, &moduleLoaderCreateImportMetaProperties, &moduleLoaderEvaluate,
                                                                        nullptr /*promiseRejectionTracker*/, &defaultLanguage, nullptr /*compileStreaming*/, nullptr /*instantiateStreaming*/ };

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

static EncodedJSValue JSC_HOST_CALL releaseNativeCounterpart(ExecState* execState) {
    if (execState->argumentCount() != 1) {
        auto scope = DECLARE_THROW_SCOPE(execState->vm());
        WTF::String message = makeString("Actual arguments count: \"", execState->argumentCount(), "\". Expected: \"", 1, "\".");
        return JSValue::encode(throwException(execState, scope, JSC::createError(execState, message, defaultSourceAppender)));
    }

    auto arg0 = execState->argument(0);
    auto wrapper = jsDynamicCast<ObjCWrapperObject*>(execState->vm(), arg0);
    if (!wrapper) {
        auto scope = DECLARE_THROW_SCOPE(execState->vm());
        JSValue error = JSC::createError(execState, arg0, "is an object which is not a native wrapper."_s, defaultSourceAppender);
        return JSValue::encode(throwException(execState, scope, error));
    }

    wrapper->setWrappedObject(nil);

    return JSValue::encode(jsUndefined());
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
    if (self->vm().topCallFrame && currentEntryScope) {
        NSMutableDictionary* threadData = [[NSThread currentThread] threadDictionary];

        if (threadData[NS_EXCEPTION_SCOPE_ZERO_RECURSION_KEY] == nil || currentEntryScope->didPopListeners().size()) {
            if (self->isUIApplicationMainAtTopOfCallstack()) {
                // set zero recursion count to the current value, in order to correctly
                // detect unhandled exceptions below UIApplicationMain
                auto scope = DECLARE_THROW_SCOPE(self->vm());
                threadData[NS_EXCEPTION_SCOPE_ZERO_RECURSION_KEY] = @(scope.recursionDepth());

                self->vm().entryScope = nullptr;

                for (auto& listener : currentEntryScope->didPopListeners())
                    listener();

                currentEntryScope->didPopListeners().clear();

                self->vm().entryScope = currentEntryScope;
            }
        }
    }
}

void GlobalObject::finishCreation(VM& vm, WTF::String applicationPath) {
    Base::finishCreation(vm);

    ExecState* globalExec = this->globalExec();

    this->_inspectorController = std::make_unique<GlobalObjectInspectorController>(*this);
    this->_inspectorController->setIncludesNativeCallStackWhenReportingExceptions(false);
    this->setConsoleClient(this->_inspectorController->consoleClient());
    this->putDirect(vm, vm.propertyNames->global, globalExec->globalThisValue(), static_cast<unsigned>(PropertyAttribute::DontEnum | PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly));

    this->_applicationPath = applicationPath;

    this->_ffiCallPrototype.set(vm, this, FFICallPrototype::create(vm, this, FFICallPrototype::createStructure(vm, this, this->functionPrototype())).get());
    this->_objCMethodWrapperStructure.set(vm, this, ObjCMethodWrapper::createStructure(vm, this, this->ffiCallPrototype()));
    this->_objCConstructorWrapperStructure.set(vm, this, ObjCConstructorWrapper::createStructure(vm, this, this->functionPrototype()));
    this->_objCBlockWrapperStructure.set(vm, this, ObjCBlockWrapper::createStructure(vm, this, this->ffiCallPrototype()));
    this->_ffiFunctionWrapperStructure.set(vm, this, CFunctionWrapper::createStructure(vm, this, this->ffiCallPrototype()));
    this->_objCBlockCallbackStructure.set(vm, this, ObjCBlockCallback::createStructure(vm, this, jsNull()));
    this->_objCMethodCallbackStructure.set(vm, this, ObjCMethodCallback::createStructure(vm, this, jsNull()));
    this->_ffiFunctionCallbackStructure.set(vm, this, FFIFunctionCallback::createStructure(vm, this, jsNull()));
    this->_recordFieldGetterStructure.set(vm, this, RecordProtoFieldGetter::createStructure(vm, this, this->functionPrototype()));
    this->_recordFieldSetterStructure.set(vm, this, RecordProtoFieldSetter::createStructure(vm, this, this->functionPrototype()));

    this->_typeFactory.set(vm, this, TypeFactory::create(vm, this, TypeFactory::createStructure(vm, this, jsNull())).get());

    this->_weakRefConstructorStructure.set(vm, this, JSWeakRefConstructor::createStructure(vm, this, Base::functionPrototype()));
    this->_weakRefPrototypeStructure.set(vm, this, JSWeakRefPrototype::createStructure(vm, this, Base::objectPrototype()));
    auto weakRefPrototype = JSWeakRefPrototype::create(vm, this, this->weakRefPrototypeStructure());
    this->_weakRefInstanceStructure.set(vm, this, JSWeakRefInstance::createStructure(vm, this, weakRefPrototype.get()));
    this->putDirect(vm, Identifier::fromString(&vm, "WeakRef"_s), JSWeakRefConstructor::create(vm, this->weakRefConstructorStructure(), weakRefPrototype.get()).get());

    this->_workerConstructorStructure.set(vm, this, JSWorkerConstructor::createStructure(vm, this, Base::functionPrototype()));
    this->_workerPrototypeStructure.set(vm, this, JSWorkerPrototype::createStructure(vm, this, Base::objectPrototype()));
    auto workerPrototype = JSWorkerPrototype::create(vm, this, this->workerPrototypeStructure());
    this->_workerInstanceStructure.set(vm, this, JSWorkerInstance::createStructure(vm, this, workerPrototype.get()));
    this->putDirect(vm, Identifier::fromString(&vm, "Worker"_s), JSWorkerConstructor::create(vm, this->workerConstructorStructure(), workerPrototype.get()).get());

    auto fastEnumerationIteratorPrototype = ObjCFastEnumerationIteratorPrototype::create(vm, this, ObjCFastEnumerationIteratorPrototype::createStructure(vm, this, this->objectPrototype()));
    this->_fastEnumerationIteratorStructure.set(vm, this, ObjCFastEnumerationIterator::createStructure(vm, this, fastEnumerationIteratorPrototype.get()));

    JSC::Structure* unmanagedPrototypeStructure = UnmanagedPrototype::createStructure(vm, this, this->objectPrototype());
    auto unmanagedPrototype = UnmanagedPrototype::create(vm, this, unmanagedPrototypeStructure);
    this->_unmanagedInstanceStructure.set(vm, this, UnmanagedInstance::createStructure(this, unmanagedPrototype.get()));

    this->_interopIdentifier = Identifier::fromString(&vm, Interop::info()->className);
    this->_interop.set(vm, this, Interop::create(vm, this, Interop::createStructure(vm, this, this->objectPrototype())).get());

    this->putDirectNativeFunction(vm, this, Identifier::fromString(globalExec, "__collect"), 0, &collectGarbage, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum));

    this->putDirectNativeFunction(vm, this, Identifier::fromString(globalExec, "__time"), 0, &time, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum));

    this->putDirectNativeFunction(vm, this, Identifier::fromString(globalExec, "__releaseNativeCounterpart"), 1, &releaseNativeCounterpart, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum));

    this->_smartStringifyFunction.set(vm, this, jsCast<JSFunction*>(evaluate(this->globalExec(), makeSource(WTF::String(smartStringify_js, smartStringify_js_len), SourceOrigin()), JSValue())));
#if TARGET_OS_UIKITFORMAC
    bool uikitformac = true;
#else
    bool uikitformac = false;
#endif
    this->putDirect(vm, Identifier::fromString(globalExec, "__uikitformac"), JSValue(uikitformac));

#ifdef DEBUG
    SourceCode sourceCode = makeSource(WTF::String(__extends_js, __extends_js_len), SourceOrigin(), URL(URL(), "__extends.ts"_s));
#else
    SourceCode sourceCode = makeSource(WTF::String(__extends_js, __extends_js_len), SourceOrigin());
#endif
    this->_typeScriptOriginalExtendsFunction.set(vm, this, jsCast<JSFunction*>(evaluate(globalExec, sourceCode, globalExec->thisValue())));
    this->putDirectNativeFunction(vm, this, Identifier::fromString(globalExec, "__extends"), 2, ObjCTypeScriptExtendFunction, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum | PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly));

    ObjCConstructorNative* NSObjectConstructor = this->typeFactory()->NSObjectConstructor(this).get();
    NSObjectConstructor->putDirectNativeFunction(vm, this, Identifier::fromString(&vm, "extend"_s), 2, ObjCExtendFunction, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum));
    NSObjectConstructor->putDirectNativeFunction(vm, this, Identifier::fromString(&vm, "alloc"_s), 0, NSObjectAlloc, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontDelete));

    MarkedArgumentBuffer descriptionFunctionArgs;
    descriptionFunctionArgs.append(jsString(globalExec, "return this.description;"_s));
    ObjCPrototype* NSObjectPrototype = jsCast<ObjCPrototype*>(NSObjectConstructor->get(globalExec, vm.propertyNames->prototype));
    NSObjectPrototype->putDirect(vm, vm.propertyNames->toString, constructFunction(globalExec, this, descriptionFunctionArgs), static_cast<unsigned>(PropertyAttribute::DontEnum));

    MarkedArgumentBuffer staticDescriptionFunctionArgs;
    staticDescriptionFunctionArgs.append(jsString(globalExec, "return Function.prototype.toString.call(this);"_s));
    NSObjectConstructor->putDirect(vm, vm.propertyNames->toString, constructFunction(globalExec, this, staticDescriptionFunctionArgs), static_cast<unsigned>(PropertyAttribute::DontEnum));

    NSObjectConstructor->setPrototypeDirect(vm, NSObjectPrototype);

    CFRunLoopSourceContext context = { 0, this, 0, 0, 0, 0, 0, 0, 0, microtaskRunLoopSourcePerformWork };
    CFRunLoopObserverContext observerContext = { 0, this, NULL, NULL, NULL };

    _microtaskRunLoopSource = WTF::adoptCF(CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context));
    _runLoopBeforeWaitingObserver = WTF::adoptCF(CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, YES, 0, &runLoopBeforeWaitingPerformWork, &observerContext));

    _commonJSModuleFunctionIdentifier = Identifier::fromString(&vm, "CommonJSModuleFunction");
    this->putDirectNativeFunction(vm, this, Identifier::fromString(&vm, "require"), 1, commonJSRequire, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum | PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly));

    this->putDirect(vm, Identifier::fromString(&vm, "__runtimeVersion"), jsString(&vm, STRINGIZE_VALUE_OF(NATIVESCRIPT_VERSION)), static_cast<unsigned>(PropertyAttribute::DontEnum | PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly));

    NakedPtr<Exception> exception;
    evaluate(this->globalExec(), makeSource(WTF::String(inlineFunctions_js, inlineFunctions_js_len), SourceOrigin()), JSValue(), exception);
    ASSERT_WITH_MESSAGE(!exception, "Error while evaluating inlineFunctions.js: %s", exception->value().toWTFString(this->globalExec()).utf8().data());

    _jsUncaughtErrorCallbackIdentifier = Identifier::fromString(&vm, "onerror"); // Keep in sync with TNSExceptionHandler.h
    _jsUncaughtErrorCallbackIdentifierFallback = Identifier::fromString(&vm, "__onUncaughtError"); // Keep in sync with TNSExceptionHandler.h
    _jsDiscardedErrorCallbackIdentifier = Identifier::fromString(&vm, "__onDiscardedError");
}

void GlobalObject::visitChildren(JSCell* cell, SlotVisitor& visitor) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(cell);
    Base::visitChildren(globalObject, visitor);

    visitor.append(globalObject->_interop);
    visitor.append(globalObject->_typeFactory);
    visitor.append(globalObject->_typeScriptOriginalExtendsFunction);
    visitor.append(globalObject->_smartStringifyFunction);
    visitor.append(globalObject->_ffiCallPrototype);
    visitor.append(globalObject->_objCMethodWrapperStructure);
    visitor.append(globalObject->_objCConstructorWrapperStructure);
    visitor.append(globalObject->_objCBlockWrapperStructure);
    visitor.append(globalObject->_ffiFunctionWrapperStructure);
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
        propertySlot.setValue(globalObject, static_cast<unsigned>(PropertyAttribute::DontEnum | PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly), globalObject->interop());
        return true;
    }

    StringImpl* symbolName = propertyName.publicName();
    if (symbolName == nullptr)
        return false;

    const Meta* symbolMeta = Metadata::MetaFile::instance()->globalTableJs()->findMeta(symbolName);
    if (symbolMeta == nullptr)
        return false;

    Strong<JSCell> strongSymbolWrapper;
    JSValue symbolWrapper;

    switch (symbolMeta->type()) {
    case Interface: {
        auto interfaceMeta = static_cast<const InterfaceMeta*>(symbolMeta);
        Class klass = objc_getClass(symbolMeta->name());
        if (!klass) {
            SymbolLoader::instance().ensureModule(symbolMeta->topLevelModule());
            klass = objc_getClass(symbolMeta->name());
        }

        if (klass) {
            auto constructor = globalObject->_typeFactory.get()->getObjCNativeConstructor(globalObject, ConstructorKey(klass), interfaceMeta);
            strongSymbolWrapper = constructor;
            globalObject->_objCConstructors.insert({ ConstructorKey(klass), constructor });
        }
        break;
    }
    case ProtocolType: {
        Protocol* aProtocol = objc_getProtocol(symbolMeta->name());
        if (!aProtocol) {
            SymbolLoader::instance().ensureModule(symbolMeta->topLevelModule());
            aProtocol = objc_getProtocol(symbolMeta->name());
        }

        auto protocol = createProtocolWrapper(globalObject, static_cast<const ProtocolMeta*>(symbolMeta), aProtocol);
        strongSymbolWrapper = protocol;
        // Protocols that are not implemented or referred with @protocol at compile time do not have corresponding
        // protocol objects at runtime. `objc_getProtocol` returns `nullptr for them!
        // See Protocol Objects section at https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocProtocols.html#//apple_ref/doc/uid/TP30001163-CH15
        if (aProtocol) {
            globalObject->_objCProtocolWrappers.insert({ aProtocol, protocol });
        }
        break;
    }
    case Union: {
        //        symbolWrapper = globalObject->typeFactory()->createOrGetUnionConstructor(globalObject, symbolName);
        break;
    }
    case Struct: {
        strongSymbolWrapper = globalObject->typeFactory()->getStructConstructor(globalObject, symbolName);
        break;
    }
    case MetaType::Function: {
        void* functionSymbol = SymbolLoader::instance().loadFunctionSymbol(symbolMeta->topLevelModule(), symbolMeta->name());
        if (functionSymbol) {
            const FunctionMeta* functionMeta = static_cast<const FunctionMeta*>(symbolMeta);
            const Metadata::TypeEncoding* encodingPtr = functionMeta->encodings()->first();
            auto returnType = globalObject->typeFactory()->parseType(globalObject, encodingPtr, false);
            auto parametersTypes = globalObject->typeFactory()->parseTypes(globalObject, encodingPtr, (int)functionMeta->encodings()->count - 1, false);

            if (functionMeta->returnsUnmanaged()) {
                JSC::Structure* unmanagedStructure = UnmanagedType::createStructure(vm, globalObject, jsNull());
                returnType = UnmanagedType::create(vm, returnType.get(), unmanagedStructure);
            }

            strongSymbolWrapper = CFunctionWrapper::create(vm, globalObject->ffiFunctionWrapperStructure(), functionSymbol, functionMeta->jsName(), returnType.get(), parametersTypes, functionMeta->ownsReturnedCocoaObject());
        }
        break;
    }
    case Var: {
        const VarMeta* varMeta = static_cast<const VarMeta*>(symbolMeta);
        void* varSymbol = SymbolLoader::instance().loadDataSymbol(varMeta->topLevelModule(), varMeta->name());
        if (varSymbol) {
            const Metadata::TypeEncoding* encoding = varMeta->encoding();
            JSCell* symbolType = globalObject->typeFactory()->parseType(globalObject, encoding, false).get();
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

    if (strongSymbolWrapper) {
        symbolWrapper = strongSymbolWrapper.get();
    }

    if (!symbolWrapper) {
        WTF::String errorMessage = makeString("Metadata for \"", symbolMeta->topLevelModule()->getName(), ".", symbolMeta->name(), "\" found but symbol not available at runtime.");
        JSC::VM& vm = execState->vm();
        auto scope = DECLARE_THROW_SCOPE(vm);

        throwVMError(execState, scope, createReferenceError(execState, errorMessage));
        propertySlot.setValue(globalObject, static_cast<unsigned>(PropertyAttribute::None), jsUndefined());
        return true;
    }

    globalObject->putDirect(vm, propertyName, symbolWrapper);

    propertySlot.setValue(object, static_cast<unsigned>(PropertyAttribute::None), symbolWrapper);
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
        auto globalTableJs = MetaFile::instance()->globalTableJs();
        for (const Meta* meta : *globalTableJs) {
            if (meta->isAvailable()) {
                propertyNames.add(Identifier::fromString(execState, meta->jsName()));
            }
        }
    }

    Base::getOwnPropertyNames(object, execState, propertyNames, enumerationMode);
}
#endif

Strong<ObjCConstructorBase> GlobalObject::constructorFor(Class klass, const ProtocolMetas& protocols, Class fallback, bool searchBaseClasses) {
    ASSERT(klass);

    ConstructorKey constructorKey(klass, protocols);
    auto kvp = this->_objCConstructors.find(constructorKey);
    if (kvp != this->_objCConstructors.end()) {
        return kvp->second;
    }

    const InterfaceMeta* meta = MetaFile::instance()->globalTableNativeInterfaces()->findInterfaceMeta(class_getName(klass));
    if (!searchBaseClasses && meta == nullptr) {
        return Strong<ObjCConstructorBase>();
    }

    if (meta) {
        auto constructor = this->_typeFactory.get()->getObjCNativeConstructor(this, constructorKey, meta);
        this->_objCConstructors.insert({ constructorKey, constructor });

        if (protocols.size() == 0) {
            this->putDirect(this->vm(), Identifier::fromString(this->globalExec(), class_getName(klass)), constructor.get());
        }

        return constructor;
    } else {
        // Search base classes
        Class firstBaseWithMeta = klass;
        while (!meta) {
            firstBaseWithMeta = class_getSuperclass(firstBaseWithMeta);
            meta = MetaFile::instance()->globalTableNativeInterfaces()->findInterfaceMeta(class_getName(firstBaseWithMeta));
        }

        ConstructorKey fallbackConstructorKey(firstBaseWithMeta, klass, protocols);
        // Use the hinted fallback if:
        //     1) It is more concrete than the first base class with meta; or is unrelated to it
        // and 2) It has metadata which is available on the current device
        if (fallback && fallback != klass && fallback != firstBaseWithMeta && ([fallback isSubclassOfClass:firstBaseWithMeta] || ![firstBaseWithMeta isSubclassOfClass:fallback])) {
            if (auto metadata = MetaFile::instance()->globalTableNativeInterfaces()->findInterfaceMeta(class_getName(fallback))) {
                // We have a hinted fallback class and it has metadata. Treat instances as if they are inheriting from the fallback class.
                // This way all members known from the metadata will be exposed to JS (if the actual class implements them).
                fallbackConstructorKey = ConstructorKey(fallback, klass, protocols); // fallback is known (coming from a public header), the actual returned type is unknown (without metadata)
                meta = metadata;
            }
        }

        return this->getOrCreateConstructor(fallbackConstructorKey, meta);
    }
}

Strong<ObjCConstructorBase> GlobalObject::getOrCreateConstructor(ConstructorKey constructorKey, const InterfaceMeta* metadata) {
    auto kvp = this->_objCConstructors.find(constructorKey);
    if (kvp != this->_objCConstructors.end()) {
        return kvp->second;
    }

    auto constructor = this->_typeFactory.get()->getObjCNativeConstructor(this, constructorKey, metadata);
    this->_objCConstructors.insert({ constructorKey, constructor });

    if (constructorKey.additionalProtocols.size() == 0 && constructorKey.klasses.unknown == nullptr) {
        this->putDirect(this->vm(), Identifier::fromString(this->globalExec(), class_getName(constructorKey.klasses.known)), constructor.get());
    }

    return constructor;
}

Strong<ObjCProtocolWrapper> GlobalObject::protocolWrapperFor(Protocol* aProtocol) {
    ASSERT(aProtocol);

    auto kvp = this->_objCProtocolWrappers.find(aProtocol);
    if (kvp != this->_objCProtocolWrappers.end()) {
        return kvp->second;
    }

    CString protocolName = protocol_getName(aProtocol);
    const Meta* meta = MetaFile::instance()->globalTableNativeProtocols()->findMeta(protocolName.data());
    ASSERT(meta && meta->type() == MetaType::ProtocolType);

    auto protocolWrapper = createProtocolWrapper(this, static_cast<const ProtocolMeta*>(meta), aProtocol);

    this->_objCProtocolWrappers.insert({ aProtocol, Strong<ObjCProtocolWrapper>(this->vm(), protocolWrapper) });
    this->putDirectWithoutTransition(this->vm(), Identifier::fromString(this->globalExec(), meta->jsName()), protocolWrapper.get(), PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);

    return protocolWrapper;
}

void GlobalObject::callJsDiscardedErrorCallback(ExecState* execState, Exception* exception, NakedPtr<Exception>& outException) {
    JSValue callback = execState->lexicalGlobalObject()->get(execState, _jsDiscardedErrorCallbackIdentifier);
    CallData callData;
    CallType callType = JSC::getCallData(execState->vm(), callback, callData);
    if (callType == JSC::CallType::None) {
        return;
    }

    MarkedArgumentBuffer uncaughtErrorArguments;
    uncaughtErrorArguments.append(exception->value());

    outException = nullptr;
    call(execState, callback, callType, callData, jsUndefined(), uncaughtErrorArguments, outException);
    if (outException) {
        warn(execState, outException->value().toWTFString(execState));
    }
}

bool GlobalObject::callJsUncaughtErrorCallback(ExecState* execState, Exception* exception, NakedPtr<Exception>& outException) {
    outException = nullptr;
    JSValue callback = this->get(execState, _jsUncaughtErrorCallbackIdentifier);

    CallData callData;
    CallType callType = JSC::getCallData(execState->vm(), callback, callData);
    if (callType == JSC::CallType::None) {
        callback = execState->lexicalGlobalObject()->get(execState, _jsUncaughtErrorCallbackIdentifierFallback);
        callType = JSC::getCallData(execState->vm(), callback, callData);
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

const Meta* getUIApplicationMainMeta() {
    static const Meta* meta = nullptr;
    if (!meta) {
        meta = Metadata::MetaFile::instance()->globalTableJs()->findMeta("UIApplicationMain");
    }

    return meta;
}

bool GlobalObject::isUIApplicationMainAtTopOfCallstack() {
    if (!this->vm().topCallFrame) {
        return false;
    }

    const Meta* meta = getUIApplicationMainMeta();
    CFunctionWrapper* function_call = jsDynamicCast<CFunctionWrapper*>(this->vm(), this->vm().topCallFrame->callee().asCell());

    return function_call && meta && function_call->functionPointer() == SymbolLoader::instance().loadFunctionSymbol(meta->topLevelModule(), meta->name());
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
    @autoreleasepool {
        while (!this->_microtasksQueue.isEmpty()) {
            this->_microtasksQueue.takeFirst()->run(this->globalExec());
        }
    }
}

WTF::String GlobalObject::defaultLanguage() {
    return "en";
}
}
