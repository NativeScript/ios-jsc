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
#import "TNSRuntime.h"
#import "TNSRuntimeImpl.h"

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
        self->_applicationPath = [applicationPath copy];
        WTF::wtfThreadData().m_apiData = static_cast<void*>(self);

        self->_impl = new TNSRuntimeImpl();

        // HACK: Temporary workaround to add inline functions to global object. Remove when they are added the proper way.
        evaluate(static_cast<TNSRuntimeImpl*>(self->_impl)->globalObject->globalExec(), makeSource(WTF::String(inlineFunctions_js, inlineFunctions_js_len)));
    }

    return self;
}

- (JSGlobalContextRef)globalContext {
    return toGlobalRef(static_cast<TNSRuntimeImpl*>(self->_impl)->globalObject->globalExec());
}

static JSC_HOST_CALL EncodedJSValue createModuleFunction(ExecState* execState) {
    JSString* moduleBody = jsString(execState, WTF::ASCIILiteral("\n") + execState->argument(0).toWTFString(execState));
    WTF::String moduleUrl = execState->argument(1).toString(execState)->value(execState);
    JSString* moduleName = execState->argument(2).toString(execState);

    MarkedArgumentBuffer requireArgs;
    requireArgs.append(jsString(execState, WTF::ASCIILiteral("require")));
    requireArgs.append(jsString(execState, WTF::ASCIILiteral("module")));
    requireArgs.append(jsString(execState, WTF::ASCIILiteral("exports")));
    requireArgs.append(jsString(execState, WTF::ASCIILiteral("__dirname")));
    requireArgs.append(jsString(execState, WTF::ASCIILiteral("__filename")));
    requireArgs.append(moduleBody);

    JSFunction* moduleFunction = jsCast<JSFunction*>(constructFunction(execState, execState->lexicalGlobalObject(), requireArgs, moduleName->toIdentifier(execState), moduleUrl, WTF::TextPosition()));
    if (execState->hadException()) {
        return JSValue::encode(jsUndefined());
    }
    SourceProvider* sourceProvider = moduleFunction->sourceCode()->provider();

    TNSRuntime* runtime = static_cast<TNSRuntime*>(WTF::wtfThreadData().m_apiData);
    static_cast<TNSRuntimeImpl*>(runtime->_impl)->sourceProviders.append(sourceProvider);

    return JSValue::encode(moduleFunction);
}

- (void)executeModule:(NSString*)entryPointModuleIdentifier error:(JSValueRef*)error {
    VM* vm = static_cast<TNSRuntimeImpl*>(self->_impl)->vm.get();
    GlobalObject* globalObject = static_cast<TNSRuntimeImpl*>(self->_impl)->globalObject.get();

    JSLockHolder lock(vm);

#if DEBUG
    SourceCode sourceCode = makeSource(WTF::String(require_js, require_js_len), WTF::ASCIILiteral("require.js"));
#else
    SourceCode sourceCode = makeSource(WTF::String(require_js, require_js_len));
#endif

    JSValue exception;
    JSValue requireFactory = evaluate(globalObject->globalExec(), sourceCode, JSValue(), &exception);
    if (exception) {
        globalObject->inspectorController().reportAPIException(globalObject->globalExec(), exception);
        if (error) {
            *error = toRef(globalObject->globalExec(), exception);
        }
        return;
    }

    MarkedArgumentBuffer requireFactoryArgs;
    requireFactoryArgs.append(jsString(vm, WTF::String(self->_applicationPath)));
    requireFactoryArgs.append(JSFunction::create(*vm, globalObject, 2, WTF::emptyString(), createModuleFunction));
    CallData requireFactoryCallData;
    CallType requireFactoryCallType = requireFactory.asCell()->methodTable()->getCallData(requireFactory.asCell(), requireFactoryCallData);
    JSValue require = call(globalObject->globalExec(), requireFactory.asCell(), requireFactoryCallType, requireFactoryCallData, jsNull(), requireFactoryArgs, &exception);
    if (exception) {
        globalObject->inspectorController().reportAPIException(globalObject->globalExec(), exception);
        if (error) {
            *error = toRef(globalObject->globalExec(), exception);
        }
        return;
    }

    MarkedArgumentBuffer requireArgs;
    requireArgs.append(jsString(vm, entryPointModuleIdentifier));

    CallData requireCallData;
    CallType requireCallType = require.asCell()->methodTable()->getCallData(require.asCell(), requireCallData);
    call(globalObject->globalExec(), require.asCell(), requireCallType, requireCallData, jsNull(), requireArgs, &exception);
    if (exception) {
        globalObject->inspectorController().reportAPIException(globalObject->globalExec(), exception);
        if (error) {
            *error = toRef(globalObject->globalExec(), exception);
        }
    }
}

- (void)dealloc {
    [self->_applicationPath release];
    delete static_cast<TNSRuntimeImpl*>(self->_impl);

    [super dealloc];
}

@end
