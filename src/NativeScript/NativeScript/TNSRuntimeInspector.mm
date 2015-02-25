//
//  TNSRuntimeInspector.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include <JavaScriptCore/InspectorAgentBase.h>
#include <JavaScriptCore/InspectorFrontendChannel.h>
#include <JavaScriptCore/JSGlobalObjectInspectorController.h>
#include <JavaScriptCore/JSConsoleClient.h>
#include <JavaScriptCore/APICast.h>
#include <JavaScriptCore/JSONObject.h>
#include <JavaScriptCore/Debugger.h>

#import "TNSRuntimeInspector.h"
#import "TNSRuntimeImpl.h"

using namespace JSC;
using namespace NativeScript;

class TNSRuntimeInspectorFrontendChannel : public Inspector::InspectorFrontendChannel {
public:
    TNSRuntimeInspectorFrontendChannel(TNSRuntimeInspectorMessageHandler handler, ExecState* execState)
        : _messageHandler(Block_copy(handler))
        , _execState(execState) {
    }

    virtual bool sendMessageToFrontend(const WTF::String& message) override {
        WTF::RetainPtr<CFStringRef> cfMessage = message.createCFString();
        return this->_messageHandler([(NSString*)cfMessage.get() copy]);
    }

    virtual ~TNSRuntimeInspectorFrontendChannel() {
        Block_release(this->_messageHandler);
    }

private:
    const TNSRuntimeInspectorMessageHandler _messageHandler;
    ExecState* _execState;
};

@implementation TNSRuntimeInspector {
    TNSRuntime* _runtime;
    std::unique_ptr<TNSRuntimeInspectorFrontendChannel> _frontendChannel;
    Inspector::JSGlobalObjectInspectorController* _inspectorController;
}

+ (BOOL)logsToSystemConsole {
    return Inspector::JSConsoleClient::logToSystemConsole();
}

+ (void)setLogsToSystemConsole:(BOOL)shouldLog {
    Inspector::JSConsoleClient::setLogToSystemConsole(shouldLog);
}

- (instancetype)initWithRuntime:(TNSRuntime*)runtime
                 messageHandler:(TNSRuntimeInspectorMessageHandler)messageHandler {
    if (self = [super init]) {
        self->_runtime = [runtime retain];
        self->_frontendChannel = std::make_unique<TNSRuntimeInspectorFrontendChannel>(messageHandler, toJS(self->_runtime.globalContext));
        self->_inspectorController = &jsCast<GlobalObject*>(toJS([runtime globalContext])->lexicalGlobalObject())->inspectorController();

        self->_inspectorController->connectFrontend(self->_frontendChannel.get());
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

- (void)dealloc {
    self->_inspectorController->disconnectFrontend(Inspector::InspectorDisconnectReason::InspectorDestroyed);
    [self->_runtime release];
    [super dealloc];
}

@end

@implementation TNSRuntime (Inspector)

- (TNSRuntimeInspector*)attachInspectorWithHandler:(TNSRuntimeInspectorMessageHandler)handler {
    return [[[TNSRuntimeInspector alloc] initWithRuntime:self
                                          messageHandler:handler] autorelease];
}

- (void)flushSourceProviders {
    JSC::Debugger* debugger = static_cast<TNSRuntimeImpl*>(self->_impl)->globalObject->debugger();
    if (debugger) {
        for (SourceProvider* e : static_cast<TNSRuntimeImpl*>(self->_impl)->sourceProviders) {
            debugger->sourceParsed(static_cast<TNSRuntimeImpl*>(self->_impl)->globalObject->globalExec(), e, -1, WTF::emptyString());
        }
    }
}

@end
