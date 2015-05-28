//  TNSDebugging.h
//  NativeScript
//
//  Created by Yavor Georgiev on 30.04.15.
//  Copyright (c) 2015 г. Telerik. All rights reserved.
//

#import <NativeScript.h>

#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <notify.h>

TNSRuntime* runtime;
static TNSRuntimeInspector* inspector = nil;
static BOOL isWaitingForDebugger = NO;

typedef void (^TNSInspectorProtocolHandler)(NSString* message, NSError* error);

typedef void (^TNSInspectorSendMessageBlock)(NSString* message);

typedef TNSInspectorProtocolHandler (^TNSInspectorFrontendConnectedHandler)(
    TNSInspectorSendMessageBlock sendMessageToFrontend, NSError* error);

#define CheckError(retval, handler)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       \
    ({                                                                           \
    typeof(retval) errorCode = retval;                                         \
    BOOL success = NO;                                                         \
    if (errorCode == 0)                                                        \
      success = YES;                                                           \
    else if (errorCode == -1)                                                  \
      errorCode = errno;                                                       \
    if (!success)                                                              \
      handler(nil, [NSError errorWithDomain:NSPOSIXErrorDomain                 \
                                       code:errorCode                          \
                                   userInfo:nil]);                             \
    success; \
    })

#define NOTIFICATION(name)                                                \
    [[NSString stringWithFormat:@"%@:NativeScript.Debug.%s",              \
                                [[NSBundle mainBundle] bundleIdentifier], \
                                name] UTF8String]

static dispatch_source_t
startListening(TNSInspectorFrontendConnectedHandler connectedHandler) {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);

    dispatch_fd_t listenSocket = socket(PF_INET, SOCK_STREAM, 0);
    struct sockaddr_in addr = {
        sizeof(addr), AF_INET, htons(18181), { INADDR_ANY }, { 0 }
    };
    if (!CheckError(
            bind(listenSocket, (const struct sockaddr*)&addr, sizeof(addr)),
            connectedHandler)) {
        return nil;
    }

    if (!CheckError(listen(listenSocket, 0), connectedHandler)) {
        return nil;
    }

    dispatch_source_t listenSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, listenSocket, 0, queue);

    dispatch_source_set_event_handler(listenSource, ^{
      dispatch_fd_t newSocket = accept(listenSocket, NULL, NULL);

      TNSInspectorSendMessageBlock sender = ^(NSString *message) {
          NSData *messageData =
              [message dataUsingEncoding:NSUTF16LittleEndianStringEncoding];
          uint32_t length = htonl(messageData.length);

          NSMutableData *payload =
              [NSMutableData dataWithBytes:&length length:sizeof(length)];
          [payload appendData:messageData];

          if (write(newSocket, payload.bytes, payload.length) == -1) {
            CheckError(errno, connectedHandler);
          }
      };

      __block TNSInspectorProtocolHandler handler =
          connectedHandler(sender, nil);
      if (!handler) {
        close(newSocket);
        return;
      }

      dispatch_io_t io = dispatch_io_create(
          DISPATCH_IO_STREAM, newSocket, queue,
          ^(int error) { CheckError(error, connectedHandler); });

      __block dispatch_io_handler_t ioHandler =
          ^(bool done, dispatch_data_t data, int error) {
          if (!CheckError(error, handler)) {
            return;
          }

          const void *bytes = [(NSData *)data bytes];
          if (!bytes) {
            close(newSocket);
            handler(nil, nil);
            return;
          }

          uint32_t length = ntohl(*(uint32_t *)bytes);
          dispatch_io_read(io, 0, length, queue,
                           ^(bool done, dispatch_data_t data, int error) {
              if (!CheckError(error, handler)) {
                return;
              }

              NSString *payload =
                  [[NSString alloc] initWithData:(NSData *)data
                                        encoding:NSUTF16LittleEndianStringEncoding];
              handler(payload, nil);

              dispatch_io_read(io, 0, 4, queue, ioHandler);
          });
      };

      dispatch_io_read(io, 0, 4, queue, ioHandler);
    });
    dispatch_source_set_cancel_handler(listenSource, ^{ close(listenSocket); });
    dispatch_resume(listenSource);

    return listenSource;
}

static void enableDebugging(int argc, char** argv) {
    __block dispatch_source_t listenSource = nil;
    TNSInspectorFrontendConnectedHandler connectionHandler = ^TNSInspectorProtocolHandler(
                                                                 TNSInspectorSendMessageBlock sendMessageToFrontend, NSError* error) {
      if (error) {
        if (listenSource) {
          dispatch_source_cancel(listenSource);
          listenSource = nil;
          inspector = nil;
        }

        NSLog(@"NativeScript debugger encountered %@.", error);
        return nil;
      }

      if (inspector) {
        return nil;
      }

      NSLog(@"NativeScript debugger attached.");

      inspector = [runtime attachInspectorWithHandler:sendMessageToFrontend];

      if (isWaitingForDebugger) {
        isWaitingForDebugger = NO;
        CFRunLoopStop(CFRunLoopGetMain());
      }

      NSArray *inspectorRunloopModes =
          @[ NSRunLoopCommonModes, TNSInspectorRunLoopMode ];
      return ^(NSString *message, NSError *error) {
          if (message) {
            CFRunLoopRef runloop = CFRunLoopGetMain();
            CFRunLoopPerformBlock(runloop,
                                  (__bridge CFTypeRef)(inspectorRunloopModes),
                                  ^{ [inspector dispatchMessage:message]; });
            CFRunLoopWakeUp(runloop);
          } else {
            dispatch_source_cancel(listenSource);
            listenSource = nil;
            inspector = nil;

            if (error) {
              NSLog(@"NativeScript debugger received %@. Disconnecting.",
                    error);
            } else {
              NSLog(@"NativeScript debugger detached.");
            }
          }
      };
    };

    int waitForDebuggerSubscription;
    notify_register_dispatch(NOTIFICATION("WaitForDebugger"),
                             &waitForDebuggerSubscription,
                             dispatch_get_main_queue(), ^(int token) {
      isWaitingForDebugger = YES;
      NSLog(@"NativeScript waiting for debugger.");
      CFRunLoopPerformBlock(CFRunLoopGetCurrent(), kCFRunLoopDefaultMode, ^{
          CFRunLoopRunInMode(kCFRunLoopDefaultMode, 30, false);
      });
    });

    int attachRequestSubscription;
    notify_register_dispatch(NOTIFICATION("AttachRequest"),
                             &attachRequestSubscription,
                             dispatch_get_main_queue(), ^(int token) {
      if (listenSource) {
        return;
      }

      listenSource = startListening(connectionHandler);
      notify_post(NOTIFICATION("ReadyForAttach"));

      dispatch_time_t delay =
          dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 30);
      dispatch_after(delay, dispatch_get_main_queue(), ^{
          if (!inspector && listenSource) {
            dispatch_source_cancel(listenSource);
            listenSource = nil;
          }
      });
    });

    int attachAvailabilityQuerySubscription;
    notify_register_dispatch(NOTIFICATION("AttachAvailabilityQuery"),
                             &attachAvailabilityQuerySubscription,
                             dispatch_get_main_queue(), ^(int token) {
      if (inspector) {
        notify_post(NOTIFICATION("AlreadyConnected"));
      } else if (listenSource) {
        notify_post(NOTIFICATION("ReadyForAttach"));
      } else {
        notify_post(NOTIFICATION("AttachAvailable"));
      }
    });

    notify_post(NOTIFICATION("AppLaunching"));

    for (int i = 1; i < argc; i++) {
        BOOL startListening = NO;
        BOOL shouldWaitForDebugger = NO;

        if (strcmp(argv[i], "--nativescript-debug-brk") == 0) {
            shouldWaitForDebugger = YES;
        } else if (strcmp(argv[i], "--nativescript-debug-start") == 0) {
            startListening = YES;
        }

        if (startListening || shouldWaitForDebugger) {
            notify_post(NOTIFICATION("AttachRequest"));
            if (shouldWaitForDebugger) {
                notify_post(NOTIFICATION("WaitForDebugger"));
            }

            break;
        }
    }

    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.5, false);
    notify_cancel(waitForDebuggerSubscription);
}