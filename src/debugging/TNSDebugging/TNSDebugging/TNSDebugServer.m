//
//  TNSWebSocketDebugConnectionProtocol.m
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/20/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import "TNSDebugServer.h"
#import "TNSDebugMessaging.h"

// 0.1 sec timeout to get the startup "NativeScript.Debug.WaitForDebugger"
// notification.
const double kTNSDebug_BlockForStartupDebugNotification_Timout = 0.1;

// 30 sec timeout for tcp connection when wait-for-debugger is received at
// startup.
const double kTNSDebug_BlockStartingForConnection_Timout = 30;

// 30 sec timeout for tcp connection when attach-request is received at runtime.
const double kTNSDebug_ConnectionWaiting_Timeout = 30;

// The back-end advertises a debuggable app has started. The front end can
// request "WaitForDebugger" in 100ms, or "AttachRequest" anytime later.
NSString* const kTNSDebug_AppLaunching = @":NativeScript.Debug.AppLaunching";

// The front-end prompts the back-end to hold on execution of the app and wait
// for debugger before any JavaScript is actually executed.
NSString* const kTNSDebug_WaitForDebugger =
    @":NativeScript.Debug.WaitForDebugger";

// Front-end prompts what is the state of debugging.
NSString* const kTNSDebug_AttachAvailabilityQuery =
    @":NativeScript.Debug.AttachAvailabilityQuery";

// Front-end requests the back-end to actually open the TCP port and wait for
// connect.
NSString* const kTNSDebug_AttachRequest = @":NativeScript.Debug.AttachRequest";

// The back-end replies that the TCP port is actually opened and waiting.
NSString* const kTNSDebug_ReadyForAttach =
    @":NativeScript.Debug.ReadyForAttach";

// The back-end replies that the TCP is closed but if requested with
// "AttachRequest" it will open.
NSString* const kTNSDebug_AttachAvailable =
    @":NativeScript.Debug.AttachAvailable";

// The back-end replies that the TCP is allready busy for another front-end.
NSString* const kTNSDebug_AllreadyConnected =
    @":NativeScript.Debug.AllreadyConnected";

typedef NS_ENUM(NSInteger, TNSDebugState) {
    TNSDebugStateStartup,
    TNSDebugStateRunningDisconnected,
    TNSDebugStateStartingBlockedForConnection,
    TNSDebugStateRunningWaitingForConnection,
    TNSDebugStateRunningConnected
};

@interface TNSDebugServer () <TNSDebugMessagingChannelDelegate>

@property(nonatomic, retain) NSString* name;
@property(nonatomic, retain) id<TNSDebugMessagingChannel> channel;

@end

@implementation TNSDebugServer {
    TNSDebugState _state;
    TNSRuntime* _runtime;
    TNSRuntimeInspector* _inspector;
}

#pragma mark - C Interop

void TNSWebSocketDebug_WaitForDebuggerCallback(CFNotificationCenterRef center,
                                               void* observer, CFStringRef name,
                                               const void* object,
                                               CFDictionaryRef userInfo) {
    [(__bridge TNSDebugServer*)observer onWaitForDebuggerNotification];
}

void TNSWebSocketDebug_AttachRequestCallback(CFNotificationCenterRef center,
                                             void* observer, CFStringRef name,
                                             const void* object,
                                             CFDictionaryRef userInfo) {
    [(__bridge TNSDebugServer*)observer onAttachRequestNotification];
}

void TNSWebSocketDebug_AttachAvailabilityQuerryCallback(
    CFNotificationCenterRef center, void* observer, CFStringRef name,
    const void* object, CFDictionaryRef userInfo) {
    [(__bridge TNSDebugServer*)observer onAttachAvailabilityQueryNotification];
}

#pragma mark - Init

- (instancetype)initWithRuntime:(TNSRuntime*)runtime
                           name:(NSString*)name
               messagingChannel:(id<TNSDebugMessagingChannel>)channel {
    self = [super init];
    if (self) {
        self->_runtime = runtime;
        self.name = name;
        self.channel = channel;
        self.channel.delegate = self;

        [self notifyAppLaunching];

        [self addWaitForDebuggerListener];
        [self addAttachRequestListener];
        [self addAttachAvailabilityListener];

        self->_state = TNSDebugStateStartup;

        NSArray *args = [NSProcessInfo processInfo].arguments;
        if ([args containsObject:@"--nativescript-debug-brk"]) {
            [self onWaitForDebuggerNotification];
        } else if ([args containsObject:@"--nativescript-debug-start"]) {
            [self onAttachRequestNotification];
        } else {
            [self blockForStartupWaitForDebugNotification];
            [self onStartupConnectionTimeout];
        }
    }
    return self;
}

#pragma mark - State Transition Triggers

- (void)onStartupConnectionTimeout {
    if (self->_state != TNSDebugStateStartup)
        return;

    // TRICKY: No need to stop the blocking runloop as it simply continued...
    self->_state = TNSDebugStateRunningDisconnected;
}

- (void)onWaitForDebuggerNotification {
    if (self->_state != TNSDebugStateStartup)
        return;

    self->_state = TNSDebugStateStartingBlockedForConnection;
    [self openWebSocketServer];
    [self notifyReadyForAttach];
    [self blockForStartupDebugConnection];

    [self onStartupBlockedForConnectionTimeout];
}

- (void)onStartupBlockedForConnectionTimeout {
    if (self->_state != TNSDebugStateStartingBlockedForConnection)
        return;

    self->_state = TNSDebugStateRunningDisconnected;
    [self closeWebSocketServer];
}

- (void)onAttachRequestNotification {
    if (self->_state == TNSDebugStateRunningDisconnected) {
        self->_state = TNSDebugStateRunningWaitingForConnection;
        [self openWebSocketServer];
        [self scheduleAttachRequestTimeout];
        [self notifyReadyForAttach];
    } else if (self->_state == TNSDebugStateStartup) {
        self->_state = TNSDebugStateRunningWaitingForConnection;
        [self unblockForStartupWaitForDebugNotification];
        [self openWebSocketServer];
        [self scheduleAttachRequestTimeout];
        [self notifyReadyForAttach];
    } else {
        [self notifyCurrentState];
    }
}

- (void)onAttachRequestTimeout {
    if (self->_state != TNSDebugStateRunningWaitingForConnection)
        return;

    self->_state = TNSDebugStateRunningDisconnected;
    [self closeWebSocketServer];
}

- (void)onConnected {
    if (self->_state == TNSDebugStateRunningWaitingForConnection) {
        self->_state = TNSDebugStateRunningConnected;
        [self clearAttachRequestTimeout];
        [self injectInspector];
    } else if (self->_state == TNSDebugStateStartingBlockedForConnection) {
        [self injectInspector];
        // We will wait the inpector to be issued Debugger.enable to switch the state.
    }
}

- (void)onDisconnected {
    if (self->_state != TNSDebugStateRunningConnected)
        return;

    self->_state = TNSDebugStateRunningDisconnected;
    [self closeWebSocketServer];
}

- (void)onAttachAvailabilityQueryNotification {
    [self notifyCurrentState];
}

#pragma mark - Execution Control
- (void)injectInspector {
    self->_inspector =
        [self->_runtime attachInspectorWithHandler:^BOOL(NSString* message) {
            [self.channel send:message];
            return YES;
        }
        onDebuggerEnabled:^void() {
            if (self->_state == TNSDebugStateStartingBlockedForConnection) {
                self->_state = TNSDebugStateRunningConnected;
                [self unblockStartingForConnection];
            }
        }];
}

- (void)scheduleAttachRequestTimeout {
    dispatch_time_t delay = dispatch_time(
        DISPATCH_TIME_NOW, NSEC_PER_SEC * kTNSDebug_ConnectionWaiting_Timeout);
    dispatch_after(delay, dispatch_get_main_queue(),
                   ^(void) { [self onAttachRequestTimeout]; });
}

- (void)clearAttachRequestTimeout {
}

- (void)blockForStartupWaitForDebugNotification {
    CFRunLoopRunInMode((CFStringRef)NSDefaultRunLoopMode,
                       kTNSDebug_BlockForStartupDebugNotification_Timout, false);
}

- (void)unblockForStartupWaitForDebugNotification {
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)blockForStartupDebugConnection {
    CFRunLoopRunInMode((CFStringRef)NSDefaultRunLoopMode,
                       kTNSDebug_BlockStartingForConnection_Timout, false);
}

- (void)unblockStartingForConnection {
    CFRunLoopStop(CFRunLoopGetCurrent());
}

#pragma mark - Darwin Center Notifications

- (void)addWaitForDebuggerListener {
    [self addListenerFor:kTNSDebug_WaitForDebugger
                listener:TNSWebSocketDebug_WaitForDebuggerCallback];
}

- (void)addAttachRequestListener {
    [self addListenerFor:kTNSDebug_AttachRequest
                listener:TNSWebSocketDebug_AttachRequestCallback];
}

- (void)addAttachAvailabilityListener {
    [self addListenerFor:kTNSDebug_AttachAvailabilityQuery
                listener:TNSWebSocketDebug_AttachAvailabilityQuerryCallback];
}

- (void)notifyCurrentState {
    switch (self->_state) {
    case TNSDebugStateStartup:
    case TNSDebugStateRunningDisconnected:
        [self notifyAttachAvailable];
        break;
    case TNSDebugStateStartingBlockedForConnection:
    case TNSDebugStateRunningWaitingForConnection:
        [self notifyReadyForAttach];
        break;
    case TNSDebugStateRunningConnected:
        [self notifyAllreadyConnected];
        break;
    default:
        break;
    }
}

- (void)notifyAppLaunching {
    [self notify:kTNSDebug_AppLaunching];
}

- (void)notifyReadyForAttach {
    [self notify:kTNSDebug_ReadyForAttach];
}

- (void)notifyAttachAvailable {
    [self notify:kTNSDebug_AttachAvailable];
}

- (void)notifyAllreadyConnected {
    [self notify:kTNSDebug_AllreadyConnected];
}

- (void)notify:(NSString*)message {
    CFNotificationCenterRef darwinNotify = CFNotificationCenterGetDarwinNotifyCenter();
    NSString* advertiseDebuggableLaunchingMessage =
        [self.name stringByAppendingString:message];
    CFNotificationCenterPostNotification(
        darwinNotify, (CFStringRef)advertiseDebuggableLaunchingMessage, NULL,
        NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)addListenerFor:(NSString*)message
              listener:(CFNotificationCallback)listener {
    CFNotificationCenterRef darwinNotify = CFNotificationCenterGetDarwinNotifyCenter();
    NSString* openDebuggerMessage = [self.name stringByAppendingString:message];
    CFNotificationCenterAddObserver(
        darwinNotify, (__bridge const void*)(self), listener,
        (CFStringRef)openDebuggerMessage, NULL,
        CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)removeListenerFor:(NSString*)message {
    CFNotificationCenterRef darwinNotify = CFNotificationCenterGetDarwinNotifyCenter();
    NSString* waitForDebuggerMessage =
        [self.name stringByAppendingString:message];
    CFNotificationCenterRemoveObserver(darwinNotify,
                                       (__bridge const void*)(self),
                                       (CFStringRef)waitForDebuggerMessage, NULL);
}

#pragma mark - Messaging Channel

- (void)openWebSocketServer {
    [self.channel open];
}

- (void)closeWebSocketServer {
    [self.channel close];
    self->_inspector = nil;
}

#pragma mark - TNSDebugMessagingChannelDelegate

- (void)connected:(id)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self onConnected];
      dispatch_after(
          dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
          dispatch_get_main_queue(), ^{ CFRunLoopStop(CFRunLoopGetMain()); });
    });
}

- (void)disconnected:(id)channel {
    [self onDisconnected];
}

- (void)received:(NSString*)message onChannel:(id)channel {
    const void* runLoopModes[] = {
        kCFRunLoopCommonModes,
        CFSTR("com.apple.JavaScriptCore.remote-inspector-runloop-mode")
    };
    CFArrayRef modes = CFArrayCreate(kCFAllocatorDefault, runLoopModes, 2,
                                     &kCFTypeArrayCallBacks);
    CFRunLoopPerformBlock(CFRunLoopGetMain(), modes,
                          ^{ [self->_inspector dispatchMessage:message]; });
    CFRunLoopWakeUp(CFRunLoopGetMain());
}

@end
