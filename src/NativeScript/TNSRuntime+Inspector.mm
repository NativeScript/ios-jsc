//
//  TNSRuntime+Inspector.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include <JavaScriptCore/InspectorAgentBase.h>
#include <JavaScriptCore/InspectorFrontendChannel.h>
#include <JavaScriptCore/JSGlobalObjectInspectorController.h>
#include <JavaScriptCore/JSGlobalObjectConsoleClient.h>
#include <JavaScriptCore/APICast.h>
#include <JavaScriptCore/JSONObject.h>
#include <JavaScriptCore/Debugger.h>

#import "TNSRuntime+Inspector.h"
#import "TNSRuntime+Private.h"
#include "JSErrors.h"

using namespace JSC;
using namespace NativeScript;

NSString* const TNSInspectorRunLoopMode = @"com.apple.JavaScriptCore.remote-inspector-runloop-mode";

class TNSRuntimeInspectorFrontendChannel : public Inspector::FrontendChannel {
public:
    TNSRuntimeInspectorFrontendChannel(TNSRuntimeInspectorMessageHandler handler, ExecState* execState)
        : _messageHandler(Block_copy(handler)) {
    }

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

@end

@implementation TNSRuntime (Inspector)

- (TNSRuntimeInspector*)attachInspectorWithHandler:(TNSRuntimeInspectorMessageHandler)messageHandler {
    return [[[TNSRuntimeInspector alloc] initWithRuntime:self
                                          messageHandler:messageHandler] autorelease];
}

- (void)flushSourceProviders {
    if (JSC::Debugger* debugger = self->_globalObject->debugger()) {
        for (SourceProvider* e : self->_sourceProviders) {
            debugger->sourceParsed(self->_globalObject->globalExec(), e, -1, WTF::emptyString());
        }
    }
}

@end

@implementation TNSRuntimeInspector {
    TNSRuntime* _runtime;
    std::unique_ptr<TNSRuntimeInspectorFrontendChannel> _frontendChannel;
    Inspector::JSGlobalObjectInspectorController* _inspectorController;
}

+ (BOOL)logsToSystemConsole {
    return Inspector::JSGlobalObjectConsoleClient::logToSystemConsole();
}

+ (void)setLogsToSystemConsole:(BOOL)shouldLog {
    Inspector::JSGlobalObjectConsoleClient::setLogToSystemConsole(shouldLog);
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

- (void)dispatchMessage:(NSString*)message {
    self->_inspectorController->dispatchMessageFromFrontend(message);

    id json = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    if ([json isKindOfClass:[NSDictionary class]]) {
        if ([@"Debugger.enable" isEqual:[json valueForKey:@"method"]]) {
            [self->_runtime flushSourceProviders];
        }
    }
}

- (void)reportFatalError:(JSValueRef)error {
    JSC::JSLockHolder lock(_runtime->_vm.get());

    ExecState* globalExec = self->_runtime->_globalObject->globalExec();
    reportFatalErrorBeforeShutdown(globalExec, toJS(globalExec, error));
}

- (void)dealloc {
    self->_inspectorController->disconnectFrontend(Inspector::DisconnectReason::InspectorDestroyed);
    [self->_runtime release];
    [super dealloc];
}

@end
