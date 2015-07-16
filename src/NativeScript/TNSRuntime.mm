//
//  TNSRuntime.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include <JavaScriptCore/InitializeThreading.h>
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/APICast.h>
#include <JavaScriptCore/FunctionConstructor.h>
#include <JavaScriptCore/JSGlobalObjectInspectorController.h>
#include <JavaScriptCore/StrongInlines.h>

#if PLATFORM(IOS)
#import <UIKit/UIApplication.h>
#endif

#include "require.h"
#include "inlineFunctions.h"
#import "TNSRuntime.h"
#import "TNSRuntime+Private.h"
#include "JSErrors.h"

using namespace JSC;
using namespace NativeScript;

@implementation TNSRuntime {
#if PLATFORM(IOS)
    id _memoryPressureNotificationSubscription;
#endif
}

+ (void)initialize {
    if (self == [TNSRuntime self]) {
        initializeThreading();
    }
}

- (instancetype)initWithApplicationPath:(NSString*)applicationPath {
    if (self = [super init]) {
        self->_vm = VM::create(SmallHeap);
        self->_applicationPath = [applicationPath copy];
        WTF::wtfThreadData().m_apiData = static_cast<void*>(self);

#if PLATFORM(IOS)
        VM* vm = self->_vm.get();
        self->_memoryPressureNotificationSubscription = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            JSLockHolder lock(vm);
            vm->heap.collect(FullCollection);
            vm->heap.releaseDelayedReleasedObjects();
        }];
#endif

        JSLockHolder lock(*self->_vm);
        self->_globalObject = Strong<GlobalObject>(*self->_vm, GlobalObject::create(*self->_vm, GlobalObject::createStructure(*self->_vm, jsNull())));

        // HACK: Temporary workaround to add inline functions to global object. Remove when they are added the proper way.
        evaluate(self->_globalObject->globalExec(), makeSource(WTF::String(inlineFunctions_js, inlineFunctions_js_len)));
    }

    return self;
}

- (JSGlobalContextRef)globalContext {
    return toGlobalRef(self->_globalObject->globalExec());
}

static JSC_HOST_CALL EncodedJSValue createModuleFunction(ExecState* execState) {
    JSString* moduleBody = jsString(execState, execState->argument(0).toWTFString(execState));
    WTF::String moduleUrl = execState->argument(1).toString(execState)->value(execState);

    MarkedArgumentBuffer requireArgs;
    requireArgs.append(jsString(execState, WTF::ASCIILiteral("require")));
    requireArgs.append(jsString(execState, WTF::ASCIILiteral("module")));
    requireArgs.append(jsString(execState, WTF::ASCIILiteral("exports")));
    requireArgs.append(jsString(execState, WTF::ASCIILiteral("__dirname")));
    requireArgs.append(jsString(execState, WTF::ASCIILiteral("__filename")));
    requireArgs.append(moduleBody);

    JSObject* constructedFunction = constructFunction(execState, execState->lexicalGlobalObject(), requireArgs, Identifier::fromString(execState, "anonymous"), moduleUrl, WTF::TextPosition());
    if (execState->hadException()) {
        return JSValue::encode(jsUndefined());
    }

    JSFunction* moduleFunction = jsCast<JSFunction*>(constructedFunction);
    SourceProvider* sourceProvider = moduleFunction->sourceCode()->provider();

    TNSRuntime* runtime = static_cast<TNSRuntime*>(WTF::wtfThreadData().m_apiData);
    runtime->_sourceProviders.append(sourceProvider);

    return JSValue::encode(moduleFunction);
}

- (void)executeModule:(NSString*)entryPointModuleIdentifier {
    JSLockHolder lock(*self->_vm);

    WTF::NakedPtr<Exception> exception;
#ifdef DEBUG
    SourceCode sourceCode = makeSource(WTF::String(require_js, require_js_len), WTF::ASCIILiteral("require.js"));
#else
    SourceCode sourceCode = makeSource(WTF::String(require_js, require_js_len));
#endif
    JSValue requireFactory = evaluate(self->_globalObject->globalExec(), sourceCode, JSValue(), exception);
    if (exception) {
        reportFatalErrorBeforeShutdown(self->_globalObject->globalExec(), exception);
        return;
    }

    MarkedArgumentBuffer requireFactoryArgs;
    requireFactoryArgs.append(jsString(self->_vm.get(), WTF::String(self->_applicationPath)));
    requireFactoryArgs.append(JSFunction::create(*self->_vm, self->_globalObject.get(), 2, WTF::emptyString(), createModuleFunction));
    CallData requireFactoryCallData;
    CallType requireFactoryCallType = requireFactory.asCell()->methodTable()->getCallData(requireFactory.asCell(), requireFactoryCallData);
    JSValue require = call(self->_globalObject->globalExec(), requireFactory.asCell(), requireFactoryCallType, requireFactoryCallData, jsNull(), requireFactoryArgs, exception);
    if (exception) {
        reportFatalErrorBeforeShutdown(self->_globalObject->globalExec(), exception);
        return;
    }

    MarkedArgumentBuffer requireArgs;
    requireArgs.append(jsString(self->_vm.get(), entryPointModuleIdentifier));

    CallData requireCallData;
    CallType requireCallType = require.asCell()->methodTable()->getCallData(require.asCell(), requireCallData);
    call(self->_globalObject->globalExec(), require.asCell(), requireCallType, requireCallData, jsNull(), requireArgs, exception);
    if (exception) {
        reportFatalErrorBeforeShutdown(self->_globalObject->globalExec(), exception);
    }
}

- (void)dealloc {
    [self->_applicationPath release];
#if PLATFORM(IOS)
    [[NSNotificationCenter defaultCenter] removeObserver:self->_memoryPressureNotificationSubscription];
    [self->_memoryPressureNotificationSubscription release];
#endif

    {
        JSLockHolder lock(*self->_vm);
        self->_globalObject.clear();
        self->_vm = nullptr;
    }

    [super dealloc];
}

@end
