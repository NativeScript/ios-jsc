//
//  TNSRuntime.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include <JavaScriptCore/APICast.h>
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/Exception.h>
#include <JavaScriptCore/FunctionConstructor.h>
#include <JavaScriptCore/InitializeThreading.h>
#include <JavaScriptCore/JSGlobalObjectInspectorController.h>
#include <JavaScriptCore/JSInternalPromise.h>
#include <JavaScriptCore/JSNativeStdFunction.h>
#include <JavaScriptCore/StrongInlines.h>
#include <iostream>

#if PLATFORM(IOS)
#import <UIKit/UIApplication.h>
#endif

#include "JSErrors.h"
#include "Metadata/Metadata.h"
#include "ObjCTypes.h"
#import "TNSRuntime+Private.h"
#import "TNSRuntime.h"
#include "inlineFunctions.h"

using namespace JSC;
using namespace NativeScript;

@implementation TNSRuntime

+ (void)initialize {
    if (self == [TNSRuntime self]) {
        initializeThreading();
        JSC::Options::useJIT() = false;
    }
}

+ (void)initializeMetadata:(void*)metadataPtr {
    Metadata::MetaFile::setInstance(metadataPtr);
}

- (instancetype)initWithApplicationPath:(NSString*)applicationPath {
    if (self = [super init]) {
        self->_vm = VM::create(SmallHeap);
        self->_applicationPath = [[applicationPath stringByStandardizingPath] retain];
        WTF::wtfThreadData().m_apiData = static_cast<void*>(self);

#if PLATFORM(IOS)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_onMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
#endif

        JSLockHolder lock(*self->_vm);
        self->_globalObject = Strong<GlobalObject>(*self->_vm, GlobalObject::create(self->_applicationPath, *self->_vm, GlobalObject::createStructure(*self->_vm, jsNull())));

#if PLATFORM(IOS)
        NakedPtr<Exception> exception;
        evaluate(self->_globalObject->globalExec(), makeSource(WTF::String(inlineFunctions_js, inlineFunctions_js_len)), JSValue(), exception);
#ifdef DEBUG
        if (exception) {
            std::cerr << "Error while evaluating inlineFunctions.js: " << exception->value().toWTFString(self->_globalObject->globalExec()).utf8().data() << "\n";
            ASSERT_NOT_REACHED();
        }
#endif
#endif
    }

    return self;
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
    JSLockHolder lock(self->_vm.get());
    self->_vm->heap.collect(FullCollection);
    self->_vm->heap.releaseDelayedReleasedObjects();
}
#endif

- (void)executeModule:(NSString*)entryPointModuleIdentifier {
    JSLockHolder lock(*self->_vm);
    JSInternalPromise* promise = loadAndEvaluateModule(self->_globalObject->globalExec(), entryPointModuleIdentifier);

    JSValue error;
    JSFunction* errorHandler = JSNativeStdFunction::create(*self->_vm.get(), self->_globalObject.get(), 1, String(), [&](ExecState* execState) {
        error = execState->argument(0);
        return JSValue::encode(jsUndefined());
    });
    promise->then(self->_globalObject->globalExec(), nullptr, errorHandler);

    self->_globalObject->drainMicrotasks();
    if (error) {
        Exception* exception = jsDynamicCast<Exception*>(error);
        if (!exception) {
            exception = Exception::create(*self->_vm.get(), error, Exception::DoNotCaptureStack);
        }

        reportFatalErrorBeforeShutdown(self->_globalObject->globalExec(), exception);
    }
}

- (JSValueRef)convertObject:(id)object {
    JSLockHolder lock(*self->_vm);
    return toRef(self->_globalObject->globalExec(), toValue(self->_globalObject->globalExec(), object));
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

    [super dealloc];
}

@end
