//
//  TNSRuntime.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include <JavaScriptCore/APICast.h>
#include <JavaScriptCore/BuiltinNames.h>
#include <JavaScriptCore/Exception.h>
#include <JavaScriptCore/FunctionConstructor.h>
#include <JavaScriptCore/InitializeThreading.h>
#include <JavaScriptCore/JSInternalPromise.h>
#include <JavaScriptCore/JSModuleLoader.h>
#include <JavaScriptCore/JSNativeStdFunction.h>
#include <JavaScriptCore/StrongInlines.h>
#include <JavaScriptCore/inspector/JSGlobalObjectInspectorController.h>
#include <iostream>

#if PLATFORM(IOS)
#import <UIKit/UIApplication.h>
#endif

#include "JSClientData.h"
#include "JSErrors.h"
#include "ManualInstrumentation.h"
#include "Metadata/Metadata.h"
#include "ObjCTypes.h"
#import "TNSRuntime+Private.h"
#import "TNSRuntime.h"
#include "Workers/JSWorkerGlobalObject.h"

using namespace JSC;
using namespace NativeScript;

JSInternalPromise* loadAndEvaluateModule(ExecState* exec, const String& moduleName, const String& referrer, JSValue initiator = jsUndefined()) {
    JSLockHolder lock(exec);
    RELEASE_ASSERT(exec->vm().atomicStringTable() == Thread::current().atomicStringTable());
    RELEASE_ASSERT(!exec->vm().isCollectorBusyOnCurrentThread());

    JSGlobalObject* globalObject = exec->vmEntryGlobalObject();
    JSValue moduleNameJsValue = jsString(&exec->vm(), Identifier::fromString(exec, moduleName).impl());
    JSValue referrerJsValue = referrer.isEmpty() ? jsUndefined() : jsString(&exec->vm(), Identifier::fromString(exec, referrer).impl());
    return globalObject->moduleLoader()->loadAndEvaluateModule(exec, moduleNameJsValue, referrerJsValue, initiator);
}

@interface TNSRuntime ()

@property(nonatomic, retain) id appPackageJsonData;

@end

@implementation TNSRuntime

@synthesize appPackageJsonData;

static WTF::Lock _runtimesLock;
static NSPointerArray* _runtimes;

+ (TNSRuntime*)current {
    WTF::LockHolder lock(_runtimesLock);
    Thread* currentThread = &WTF::Thread::current();
    for (TNSRuntime* runtime in _runtimes) {
        if (runtime->thread == currentThread)
            return runtime;
    }
    return nil;
}

+ (TNSRuntime*)runtimeForVM:(JSC::VM*)vm {
    WTF::LockHolder lock(_runtimesLock);
    for (TNSRuntime* runtime in _runtimes) {
        if (runtime->_vm.get() == vm)
            return runtime;
    }
    return nil;
}

+ (void)initialize {
    TNSPERF();
    if (self == [TNSRuntime self]) {
        WTF::initializeMainThread();
        initializeThreading();
        JSC::Options::useJIT() = false;
        _runtimes = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsOpaquePersonality | NSPointerFunctionsOpaqueMemory];
    }
}

+ (void)initializeMetadata:(void*)metadataPtr {
    Metadata::MetaFile::setInstance(metadataPtr);
}

- (instancetype)initWithApplicationPath:(NSString*)applicationPath {
    if (tns::instrumentation::Frame::mode == tns::instrumentation::Mode::Uninitialized) {
        tns::instrumentation::Frame::disable();
    }

    TNSPERF();
    if (self = [super init]) {
        self->_vm = VM::create(SmallHeap);
        self->thread = &WTF::Thread::current();
        self->_applicationPath = [[applicationPath stringByStandardizingPath] retain];
        self->_objectMap = std::make_unique<JSC::WeakGCMap<id, JSC::JSObject>>(*self->_vm);

        JSVMClientData::initNormalWorld(self->_vm.get());

        self->thread->m_apiData = static_cast<void*>(self);

#if PLATFORM(IOS)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_onMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
#endif

        JSLockHolder lock(*self->_vm);
        self->_globalObject = Strong<GlobalObject>(*self->_vm, [self createGlobalObjectInstance]);

        {
            WTF::LockHolder lock(_runtimesLock);
            [_runtimes addPointer:self];
        }
    }

    return self;
}

- (GlobalObject*)createGlobalObjectInstance {
    TNSPERF();
    return GlobalObject::create(*self->_vm, GlobalObject::createStructure(*self->_vm, jsNull()), self->_applicationPath);
}

- (void)scheduleInRunLoop:(NSRunLoop*)runLoop forMode:(NSString*)mode {
    CFRunLoopRef cfRunLoop = runLoop.getCFRunLoop;
    CFRunLoopAddSource(cfRunLoop, self->_globalObject->microtaskRunLoopSource(), (CFStringRef)mode);
    CFRunLoopAddObserver(cfRunLoop, self->_globalObject->runLoopBeforeWaitingObserver(), (CFStringRef)mode);
    self->_globalObject->microtaskRunLoops().push_back(WTF::retainPtr(cfRunLoop));
}

- (void)removeFromRunLoop:(NSRunLoop*)runLoop forMode:(NSString*)mode {
    CFRunLoopRef cfRunLoop = runLoop.getCFRunLoop;
    CFRunLoopRemoveSource(cfRunLoop, self->_globalObject->microtaskRunLoopSource(), (CFStringRef)mode);
    CFRunLoopRemoveObserver(cfRunLoop, self->_globalObject->runLoopBeforeWaitingObserver(), (CFStringRef)mode);
    self->_globalObject->microtaskRunLoops().remove(WTF::retainPtr(cfRunLoop));
}

- (JSGlobalContextRef)globalContext {
    return toGlobalRef(self->_globalObject->globalExec());
}

#if PLATFORM(IOS)
- (void)_onMemoryWarning {
    TNSPERF();
    JSLockHolder lock(self->_vm.get());
    self->_vm->heap.collectAsync(CollectionScope::Full);
    self->_vm->heap.releaseDelayedReleasedObjects();
}
#endif

- (void)executeModule:(NSString*)entryPointModuleIdentifier {
    return [self executeModule:entryPointModuleIdentifier referredBy:@""];
}

- (void)executeModule:(NSString*)entryPointModuleIdentifier referredBy:(NSString*)referrer {
    JSLockHolder lock(*self->_vm);
    JSInternalPromise* promise = loadAndEvaluateModule(self->_globalObject->globalExec(), entryPointModuleIdentifier, referrer);

    JSValue error;
    JSFunction* errorHandler = JSNativeStdFunction::create(*self->_vm.get(), self->_globalObject.get(), 1, String(), [&](ExecState* execState) {
        error = execState->argument(0);
        return JSValue::encode(jsUndefined());
    });
    promise->then(self->_globalObject->globalExec(), nullptr, errorHandler);

    self->_globalObject->drainMicrotasks();
    if (error) {
        Exception* exception = jsDynamicCast<Exception*>(*self->_vm.get(), error);
        if (!exception) {
            exception = jsDynamicCast<Exception*>(*self->_vm.get(), error.getObject()->getDirect(*self->_vm.get(), self->_vm.get()->propertyNames->builtinNames().nsExceptionIdentifierPrivateName()));
            if (!exception) {
                exception = Exception::create(*self->_vm.get(), error, Exception::DoNotCaptureStack);
            }
        }
        reportFatalErrorBeforeShutdown(self->_globalObject->globalExec(), exception);
    }
}

- (JSValueRef)convertObject:(id)object {
    JSLockHolder lock(*self->_vm);
    return toRef(self->_globalObject->globalExec(), toValue(self->_globalObject->globalExec(), object));
}

- (id)appPackageJson {

    if (self->appPackageJsonData != nil) {
        return self->appPackageJsonData;
    }

    NSString* packageJsonPath = [self->_applicationPath stringByAppendingPathComponent:@"app/package.json"];
    NSData* data = [NSData dataWithContentsOfFile:packageJsonPath];
    if (data) {
        NSError* error = nil;
        self->appPackageJsonData = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] retain];
    }

    return self->appPackageJsonData;
}

- (void)dealloc {
    [self->_applicationPath release];
#if PLATFORM(IOS)
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
#endif

    {
        JSLockHolder lock(*self->_vm);
        self->_globalObject.clear();
        self->_vm = nullptr;
    }
    self->_objectMap.release();

    {
        WTF::LockHolder lock(_runtimesLock);
        for (NSInteger i = _runtimes.count - 1; i >= 0; i--) {
            if ([_runtimes pointerAtIndex:i] == self)
                [_runtimes removePointerAtIndex:i];
        }
    }

    [super dealloc];
}

@end

@implementation TNSWorkerRuntime

- (GlobalObject*)createGlobalObjectInstance {
    TNSPERF();
    return JSWorkerGlobalObject::create(*self->_vm, JSWorkerGlobalObject::createStructure(*self->_vm, jsNull()), self->_applicationPath);
}

@end
