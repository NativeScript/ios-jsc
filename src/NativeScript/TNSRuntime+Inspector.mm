//
//  TNSRuntime+Inspector.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include <JavaScriptCore/APICast.h>
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/Debugger.h>
#include <JavaScriptCore/InspectorAgentBase.h>
#include <JavaScriptCore/InspectorFrontendChannel.h>
#include <JavaScriptCore/JSInternalPromise.h>
#include <JavaScriptCore/JSNativeStdFunction.h>
#include <JavaScriptCore/inspector/ScriptArguments.h>

#include "GlobalObjectConsoleClient.h"
#include "GlobalObjectInspectorController.h"
#include "JSErrors.h"
#import "TNSRuntime+Inspector.h"
#import "TNSRuntime+Private.h"

using namespace JSC;
using namespace NativeScript;

NSString* const TNSInspectorRunLoopMode = @"com.apple.JavaScriptCore.remote-inspector-runloop-mode";

class TNSRuntimeInspectorFrontendChannel : public Inspector::FrontendChannel {
public:
    TNSRuntimeInspectorFrontendChannel(TNSRuntimeInspectorMessageHandler handler, ExecState* execState)
        : _messageHandler(Block_copy(handler)) {
    }

    virtual ConnectionType connectionType() const override {
        return ConnectionType::Local;
    };

    virtual void sendMessageToFrontend(const WTF::String& message) override {
        WTF::RetainPtr<CFStringRef> cfMessage = message.createCFString();
        this->_messageHandler([NSString stringWithString:(NSString*)cfMessage.get()]);
    }

    virtual ~TNSRuntimeInspectorFrontendChannel() {
        Block_release(this->_messageHandler);
    }

private:
    const TNSRuntimeInspectorMessageHandler _messageHandler;
};

@interface TNSRuntimeInspector ()

- (instancetype)initWithRuntime:(TNSRuntime*)runtime
                 messageHandler:(TNSRuntimeInspectorMessageHandler)messageHandler;
- (void)setup;

@end

@implementation TNSRuntime (Inspector)

- (TNSRuntimeInspector*)attachInspectorWithHandler:(TNSRuntimeInspectorMessageHandler)messageHandler {
    JSC::JSLockHolder lock(self->_vm.get());

    TNSRuntimeInspector* runtimeInspector = [[TNSRuntimeInspector alloc] initWithRuntime:self
                                                                          messageHandler:messageHandler];

    [runtimeInspector setup];

    return [runtimeInspector autorelease];
}

@end

@implementation TNSRuntimeInspector {
    TNSRuntime* _runtime;
    std::unique_ptr<TNSRuntimeInspectorFrontendChannel> _frontendChannel;
    GlobalObjectInspectorController* _inspectorController;
}

+ (BOOL)logsToSystemConsole {
    return GlobalObjectConsoleClient::logToSystemConsole();
}

+ (void)setLogsToSystemConsole:(BOOL)shouldLog {
    GlobalObjectConsoleClient::setLogToSystemConsole(shouldLog);
}

- (instancetype)initWithRuntime:(TNSRuntime*)runtime
                 messageHandler:(TNSRuntimeInspectorMessageHandler)messageHandler {
    if (self = [super init]) {
        JSC::JSLockHolder lock(runtime->_vm.get());

        self->_runtime = [runtime retain];
        self->_frontendChannel = std::make_unique<TNSRuntimeInspectorFrontendChannel>(messageHandler, self->_runtime->_globalObject->globalExec());
        self->_inspectorController = &self->_runtime->_globalObject->inspectorController();
        self->_inspectorController->connectFrontend(self->_frontendChannel.get(), false);
    }

    return self;
}

- (TNSRuntime*)runtime {
    return self->_runtime;
}

- (void)setup {
    JSC::JSLockHolder lock(_runtime->_vm.get());

    WTF::Deque<WTF::RefPtr<JSC::Microtask>> other;
    NativeScript::GlobalObject* globalObject = self->_runtime->_globalObject.get();

    globalObject->microtasks().swap(other);
    auto execState = globalObject->globalExec();

    loadAndEvaluateModule(execState, "inspector_modules.js"_s, jsUndefined(), jsUndefined())
        ->then(execState, nullptr, JSNativeStdFunction::create(execState->vm(), globalObject, 1, String("reject"), [globalObject](ExecState* execState) {
                   JSValue error = execState->argument(0);
                   Vector<JSC::Strong<JSC::Unknown>> argsVector({ JSC::Strong<JSC::Unknown>(execState->vm(), jsString(execState, String("Loading inspector modules failed: "))),
                                                                  JSC::Strong<JSC::Unknown>(execState->vm(), error)

                   });

                   Ref<Inspector::ScriptArguments> logArgs = Inspector::ScriptArguments::create(*execState, WTFMove(argsVector));

                   globalObject->inspectorController().consoleClient()->messageWithTypeAndLevel(
                       MessageType::Log,
                       MessageLevel::Warning,
                       execState,
                       WTFMove(logArgs));
                   return encodedJSUndefined();
               }));

    globalObject->drainMicrotasks();
    globalObject->microtasks().swap(other);
}

- (void)dispatchMessage:(NSString*)message {
    JSC::JSLockHolder lock(_runtime->_vm.get());

    self->_inspectorController->dispatchMessageFromFrontend(message);
}

- (void)reportFatalError:(JSValueRef)error {
    JSC::JSLockHolder lock(_runtime->_vm.get());

    ExecState* globalExec = self->_runtime->_globalObject->globalExec();
    reportFatalErrorBeforeShutdown(globalExec, Exception::create(*self->_runtime->_vm, toJS(globalExec, error)));
}

- (void)pause {
    JSC::JSLockHolder lock(_runtime->_vm.get());

    self->_inspectorController->pause();
}

- (void)dealloc {
    JSC::JSLockHolder lock(_runtime->_vm.get());

    self->_inspectorController->disconnectFrontend(_frontendChannel.get());
    [self->_runtime release];
    [super dealloc];
}

@end
