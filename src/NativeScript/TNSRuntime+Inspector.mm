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
#include <JavaScriptCore/JSONObject.h>

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

    virtual ConnectionType connectionType() const override { return ConnectionType::Local; };

    virtual bool sendMessageToFrontend(const WTF::String& message) override {
        WTF::RetainPtr<CFStringRef> cfMessage = message.createCFString();
        this->_messageHandler([NSString stringWithString:(NSString*)cfMessage.get()]);
        return true;
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

- (void)setup {
    JSC::JSLockHolder lock(_runtime->_vm.get());

    WTF::Deque<WTF::RefPtr<JSC::Microtask>> other;
    GlobalObject* globalObject = self->_runtime->_globalObject.get();

    globalObject->microtasks().swap(other);

    loadAndEvaluateModule(_runtime->_globalObject->globalExec(), WTF::ASCIILiteral("inspector_modules.js"));

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
    self->_inspectorController->disconnectFrontend(_frontendChannel.get());
    [self->_runtime release];
    [super dealloc];
}

@end
