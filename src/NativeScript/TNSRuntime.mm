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

#include "require.h"
#include "inlineFunctions.h"
#include "systemjs.h"
#import "TNSRuntime.h"
#import "TNSRuntime+Private.h"
#include "JSErrors.h"

using namespace JSC;
using namespace NativeScript;

@implementation TNSRuntime

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

        NSSetUncaughtExceptionHandler([](NSException* exception) {
            ExecState* execState = static_cast<TNSRuntime*>(WTF::wtfThreadData().m_apiData)->_globalObject->globalExec();
            JSValue error = createError(execState, exception.description);
            reportFatalErrorBeforeShutdown(execState, error);
        });

        JSLockHolder lock(*self->_vm);
        self->_globalObject = Strong<GlobalObject>(*self->_vm, GlobalObject::create(*self->_vm, GlobalObject::createStructure(*self->_vm, jsNull())));

        // HACK: Temporary workaround to add inline functions to global object. Remove when they are added the proper way.
        evaluate(self->_globalObject->globalExec(), makeSource(WTF::String(inlineFunctions_js, inlineFunctions_js_len)));

        // Evaluate SystemJS as script
        evaluate(self->_globalObject->globalExec(), makeSource(WTF::String(systemjs_js, systemjs_js_len), WTF::ASCIILiteral("systemjs.js")));
    }

    return self;
}

- (JSGlobalContextRef)globalContext {
    return toGlobalRef(self->_globalObject->globalExec());
}

- (void)executeModule:(NSString*)entryPointModuleIdentifier {
    JSLockHolder lock(*self->_vm);

    JSValue exception;
    evaluate(self->_globalObject->globalExec(), makeSource(WTF::String("System.import('./bootstrap.js').then(function(m) { UIApplicationMain(0, null, null, null); }, function(e) { console.log('Error:', e); });")), JSValue(), &exception);
    if (exception) {
        reportFatalErrorBeforeShutdown(self->_globalObject->globalExec(), exception);
    }
}

- (void)dealloc {
    [self->_applicationPath release];

    {
        JSLockHolder lock(*self->_vm);
        self->_globalObject.clear();
        self->_vm.clear();
    }

    [super dealloc];
}

@end
