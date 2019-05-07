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

#include <mach/mach_host.h>

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

@property(nonatomic, retain) NSDictionary* appPackageJsonData;

@property double* gcThrottleTimeValue;

@property double* memoryCheckIntervalValue;

@property double* freeMemoryRatioValue;

- (double)gcThrottleTime;

- (double)memoryCheckInterval;

- (double)freeMemoryRatio;

+ (double)readDoubleFromPackageJsonIos:(NSDictionary*)packageJson withKey:(NSString*)key;

+ (NSString*)readStringFromPackageJsonIos:(NSDictionary*)packageJson withKey:(NSString*)key;

+ (NSDictionary*)readAppPackageJson:(NSString*)applicationPath;

@end

@implementation TNSRuntime

@synthesize appPackageJsonData;

@synthesize gcThrottleTimeValue;

@synthesize memoryCheckIntervalValue;

@synthesize freeMemoryRatioValue;

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

void (*oldHandlers[__DARWIN_NSIG])(int) = {};
void sig_handler(int sig) {
    NSLog(@"NativeScript caught signal %d.", sig);
    NSLog(@"Native Stack: ");
    WTFReportBacktrace();
    NSLog(@"JS Stack: ");
    dumpExecJsCallStack([TNSRuntime current] -> _globalObject -> globalExec());

    if (oldHandlers[sig]) {
        oldHandlers[sig](sig);
    }

    exit(-sig);
}

void install_handler(int sig) {
    oldHandlers[sig] = signal(sig, sig_handler);
}

+ (void)initialize {
    TNSPERF();
    if (self == [TNSRuntime self]) {
        WTF::initializeMainThread();
        initializeThreading();

        JSC::Options::useJIT() = false;
        NSDictionary* packageJson = [TNSRuntime readAppPackageJson:[NSBundle mainBundle].bundlePath];
        NSString* jscFlags = [TNSRuntime readStringFromPackageJsonIos:packageJson withKey:@"jscFlags"];
        if (jscFlags != nil) {
            JSC::Options::setOptions([jscFlags cStringUsingEncoding:NSUTF8StringEncoding]);
        }

        _runtimes = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsOpaquePersonality | NSPointerFunctionsOpaqueMemory];

        install_handler(SIGABRT);
        install_handler(SIGILL);
        install_handler(SIGSEGV);
        install_handler(SIGFPE);
        install_handler(SIGBUS);
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
        self->_globalObject = [self createGlobalObjectInstance];

        {
            WTF::LockHolder lock(_runtimesLock);
            [_runtimes addPointer:self];
        }
    }

    return self;
}

- (JSC::Strong<GlobalObject>)createGlobalObjectInstance {
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

+ (NSDictionary*)readAppPackageJson:(NSString*)applicationPath {
    NSString* packageJsonPath = [applicationPath stringByAppendingPathComponent:@"app/package.json"];
    NSData* data = [NSData dataWithContentsOfFile:packageJsonPath];
    NSDictionary* res = @{};
    if (data) {
        NSError* error = nil;
        res = [[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error] retain];
    }
    return res;
}

- (NSDictionary*)appPackageJson {

    if (self->appPackageJsonData != nil) {
        return self->appPackageJsonData;
    }

    self->appPackageJsonData = [TNSRuntime readAppPackageJson:self->_applicationPath];
    return self->appPackageJsonData;
}

- (double)gcThrottleTime {

    if (self->gcThrottleTimeValue != nullptr) {
        return *self->gcThrottleTimeValue;
    }

    self->gcThrottleTimeValue = new double([TNSRuntime readDoubleFromPackageJsonIos:[self appPackageJson] withKey:@"gcThrottleTime"]);

    return *self->gcThrottleTimeValue;
}

- (double)memoryCheckInterval {

    if (self->memoryCheckIntervalValue != nullptr) {
        return *self->memoryCheckIntervalValue;
    }

    self->memoryCheckIntervalValue = new double([TNSRuntime readDoubleFromPackageJsonIos:[self appPackageJson] withKey:@"memoryCheckInterval"]);

    return *self->memoryCheckIntervalValue;
}

- (double)freeMemoryRatio {

    if (self->freeMemoryRatioValue != nullptr) {
        return *self->freeMemoryRatioValue;
    }

    self->freeMemoryRatioValue = new double([TNSRuntime readDoubleFromPackageJsonIos:[self appPackageJson] withKey:@"freeMemoryRatio"]);

    return *self->freeMemoryRatioValue;
}

+ (double)readDoubleFromPackageJsonIos:(NSDictionary*)packageJson withKey:(NSString*)key {
    double res = 0;
    if (packageJson) {
        if (NSDictionary* ios = packageJson[@"ios"]) {
            if (id value = ios[key]) {
                if ([value respondsToSelector:@selector(doubleValue)]) {
                    res = [value doubleValue];
                } else {
                    NSLog(@"\"%@\" setting from package.json cannot be converted to double: %@", key, value);
                }
            }
        }
    }

    return res;
}

+ (NSString*)readStringFromPackageJsonIos:(NSDictionary*)packageJson withKey:(NSString*)key {
    NSString* res = nil;
    if (packageJson) {
        if (NSDictionary* ios = packageJson[@"ios"]) {
            if (id value = ios[key]) {
                res = value;
            }
        }
    }

    return res;
}

double getSystemFreeMemoryRatio() {
    mach_port_t host_port = mach_host_self();
    ;
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_statistics_data_t vm_stat;
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        NSLog(@"Failed to fetch vm statistics");
        return 0;
    }

    double free = static_cast<double>(vm_stat.free_count + vm_stat.inactive_count);
    double used = static_cast<double>(vm_stat.active_count + vm_stat.wire_count);
    double total = free + used;

    return free / total;
}

- (void)tryCollectGarbage {
    using namespace std;
    using namespace std::chrono;

    static auto previousGcTime = steady_clock::now();

    auto triggerGc = ^{
      JSLockHolder locker(self->_vm.get());
      self->_vm->heap.collectAsync(CollectionScope::Full);
      previousGcTime = steady_clock::now();
    };
    auto elapsedMs = duration_cast<duration<double, milli>>(steady_clock::now() - previousGcTime).count();

    if (auto gcThrottleTimeMs = [self gcThrottleTime]) {
        if (elapsedMs > gcThrottleTimeMs) {
            triggerGc();
            return;
        }
    }

    if (auto gcMemCheckIntervalMs = [self memoryCheckInterval]) {
        if (elapsedMs > gcMemCheckIntervalMs) {
            if (auto freeMemoryRatio = [self freeMemoryRatio]) {
                if (getSystemFreeMemoryRatio() < freeMemoryRatio) {
                    triggerGc();
                    return;
                }
            }
        }
    }
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

- (Strong<GlobalObject>)createGlobalObjectInstance {
    TNSPERF();
    return JSWorkerGlobalObject::create(*self->_vm, JSWorkerGlobalObject::createStructure(*self->_vm, jsNull()), self->_applicationPath);
}

@end
