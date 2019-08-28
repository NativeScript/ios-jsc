//  TNSDebugging.h
//  NativeScript
//
//  Created by Yavor Georgiev on 30.04.15.
//  Copyright (c) 2015 г. Telerik. All rights reserved.
//

#import <JavaScriptCore/JSStringRefCF.h>
#import <JavaScriptCore/JavaScript.h>
#import <NativeScript.h>
#import <UIKit/UIApplication.h>
#import <libkern/OSAtomic.h>

#include <errno.h>
#include <netinet/in.h>
#include <notify.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>

// {N} CLI is relying on these messages. Please do not change them!
#define LOG_DEBUGGER_PORT NSLog(@"NativeScript debugger has opened inspector socket on port %d for %@.", currentInspectorPort, [[NSBundle mainBundle] bundleIdentifier])
#define LOG_FAILED_REFRESH(reason) NSLog(@"Failed to refresh the application with RefreshRequest. Reason: %@", reason); notify_post(NOTIFICATION("AppRefreshFailed"))

// Synchronization object for serializing access to inspector variable and data socket

id inspectorLock() {
    static dispatch_once_t once;
    static id lock;
    dispatch_once(&once, ^{
      lock = [[NSObject alloc] init];
    });
    return lock;
}
static TNSRuntimeInspector* inspector = nil;
static dispatch_io_t inspector_io = nil;
static BOOL isWaitingForDebugger = NO;
static int currentInspectorPort = 0;

typedef void (^TNSInspectorProtocolHandler)(NSString* message, NSError* error);

typedef void (^TNSInspectorSendMessageBlock)(NSString* message);

typedef TNSInspectorProtocolHandler (^TNSInspectorFrontendConnectedHandler)(
    TNSInspectorSendMessageBlock sendMessageToFrontend, NSError* error, dispatch_io_t io);

typedef void (^TNSInspectorIoErrorHandler)(
    NSObject* dummy /*make compatible with CheckError macro*/, NSError* error);

#define CheckError(retval, handler)                                  \
    ({                                                               \
        int errorCode = (int)retval;                                 \
        BOOL success = NO;                                           \
        if (errorCode == 0)                                          \
            success = YES;                                           \
        else if (errorCode == -1)                                    \
            errorCode = errno;                                       \
        if (!success)                                                \
            handler(nil, [NSError errorWithDomain:NSPOSIXErrorDomain \
                                             code:errorCode          \
                                         userInfo:nil]);             \
        success;                                                     \
    })

#define NOTIFICATION(name)                                                      \
    [[NSString stringWithFormat:@"%@:NativeScript.Debug.%s",                    \
                                [[NSBundle mainBundle] bundleIdentifier], name] \
        UTF8String]

static dispatch_source_t
TNSCreateInspectorServer(TNSInspectorFrontendConnectedHandler connectedHandler,
                         TNSInspectorIoErrorHandler ioErrorHandler,
                         dispatch_block_t clearInspector) {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);

    dispatch_fd_t listenSocket = socket(PF_INET, SOCK_STREAM, 0);
    int so_reuseaddr = 1;
    setsockopt(listenSocket, SOL_SOCKET, SO_REUSEADDR, &so_reuseaddr,
               sizeof(so_reuseaddr));
    struct sockaddr_in addr = {
        sizeof(addr), AF_INET, htons(18183), { INADDR_ANY }, { 0 }
    };

    // Adapter block for CheckError macro
    TNSInspectorProtocolHandler (^connectedErrorHandler)(TNSInspectorSendMessageBlock, NSError*) = ^(TNSInspectorSendMessageBlock sendMessage, NSError* error) {
      return connectedHandler(sendMessage, error, nil);
    };
    if (bind(listenSocket, (const struct sockaddr*)&addr, sizeof(addr)) != 0) {

        // Try getting a random port if the default one is unavailable
        addr.sin_port = htons(0);

        if (!CheckError(
                bind(listenSocket, (const struct sockaddr*)&addr, sizeof(addr)),
                connectedErrorHandler)) {

            return nil;
        }
    }

    if (!CheckError(listen(listenSocket, 0), connectedErrorHandler)) {
        return nil;
    }

    // read actually allocated listening port
    socklen_t len = sizeof(addr);
    if (!CheckError(getsockname(listenSocket, (struct sockaddr*)&addr, &len), connectedErrorHandler)) {
        return nil;
    }

    currentInspectorPort = ntohs(addr.sin_port);

    __block dispatch_source_t listenSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, listenSocket, 0, queue);

    dispatch_source_set_event_handler(listenSource, ^{
      // Only one connection is supported at a time. Discard previous inspector.
      clearInspector();

      __block dispatch_fd_t newSocket = accept(listenSocket, NULL, NULL);

      __block dispatch_io_t io = 0;
      __block TNSInspectorProtocolHandler protocolHandler = nil;
      __block TNSInspectorIoErrorHandler dataSocketErrorHandler = ^(NSObject* dummy, NSError* error) {
        @synchronized(inspectorLock()) {
            if (io) {
                dispatch_io_close(io, DISPATCH_IO_STOP);
                io = 0;
            }
        }

        if (newSocket) {
            close(newSocket);
            newSocket = 0;
        }

        if (protocolHandler) {
            protocolHandler(nil, error);
        }

        if (ioErrorHandler) {
            ioErrorHandler(nil, error);
        }
      };

      @synchronized(inspectorLock()) {
          io = dispatch_io_create(DISPATCH_IO_STREAM, newSocket, queue,
                                  ^(int error) {
                                    CheckError(error, dataSocketErrorHandler);
                                  });
      }

      TNSInspectorSendMessageBlock sender = ^(NSString* message) {
        // NSLog(@"NativeScript debugger sending: %@", message);
        NSUInteger length = [message
            lengthOfBytesUsingEncoding:NSUTF16LittleEndianStringEncoding];

        uint8_t* buffer = (uint8_t*)malloc(length + sizeof(uint32_t));

        *(uint32_t*)buffer = htonl(length);

        [message getBytes:&buffer[sizeof(uint32_t)]
                 maxLength:length
                usedLength:NULL
                  encoding:NSUTF16LittleEndianStringEncoding
                   options:0
                     range:NSMakeRange(0, message.length)
            remainingRange:NULL];

        dispatch_data_t data = dispatch_data_create(buffer, length + sizeof(uint32_t), queue, ^{
          free(buffer);
        });

        @synchronized(inspectorLock()) {
            if (io) {
                dispatch_io_write(io, 0, data, queue,
                                  ^(bool done, dispatch_data_t data, int error) {
                                    CheckError(error, dataSocketErrorHandler);
                                  });
            }
        }
      };

      protocolHandler = connectedHandler(sender, nil, io);
      if (!protocolHandler) {
          dataSocketErrorHandler(nil, nil);
          return;
      }

      __block dispatch_io_handler_t receiver = ^(bool done, dispatch_data_t data, int error) {
        if (!CheckError(error, dataSocketErrorHandler)) {
            return;
        }

        const void* bytes = [(NSData*)data bytes];
        if (!bytes) {
            dataSocketErrorHandler(nil, nil);
            return;
        }

        uint32_t length = ntohl(*(uint32_t*)bytes);
        @synchronized(inspectorLock()) {
            if (io) {
                dispatch_io_set_low_water(io, length);
                dispatch_io_read(
                    io, 0, length, queue,
                    ^(bool done, dispatch_data_t data, int error) {
                      if (!CheckError(error, dataSocketErrorHandler)) {
                          return;
                      }

                      NSString* payload = [[NSString alloc]
                          initWithData:(NSData*)data
                              encoding:NSUTF16LittleEndianStringEncoding];
                      protocolHandler(payload, nil);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
                      @synchronized(inspectorLock()) {
                          if (io) {
                              dispatch_io_read(io, 0, 4, queue, receiver);
                          }
                      }
#pragma clang diagnostic pop
                    });
            }
        }
      };

      @synchronized(inspectorLock()) {
          if (io) {
              dispatch_io_read(io, 0, 4, queue, receiver);
          }
      }
    });
    dispatch_source_set_cancel_handler(listenSource, ^{
      listenSource = nil;
      close(listenSocket);
    });
    dispatch_resume(listenSource);

    return listenSource;
}

static void TNSInspectorUncaughtExceptionHandler(NSException* exception) {
    // Keep a working copy for calling into the VM after releasing inspectorLock
    TNSRuntimeInspector* tempInspector = nil;
    @synchronized(inspectorLock()) {
        tempInspector = inspector;
    }
    if (tempInspector) {
        JSStringRef exceptionMessage = JSStringCreateWithUTF8CString(exception.description.UTF8String);

        JSValueRef errorArguments[] = {
            JSValueMakeString(inspector.runtime.globalContext, exceptionMessage)
        };
        JSObjectRef error = JSObjectMakeError(inspector.runtime.globalContext, 1,
                                              errorArguments, NULL);

        [inspector reportFatalError:error];
    }
}

static void TNSEnableRemoteInspector(int argc, char** argv,
                                     TNSRuntime* runtime) {
    __block dispatch_source_t listenSource = nil;
    __block dispatch_io_t current_connection_inspector_io = nil;

    dispatch_block_t clearInspector = ^{
      // Keep a working copy for calling into the VM after releasing inspectorLock
      TNSRuntimeInspector* tempInspector = nil;
      @synchronized(inspectorLock()) {
          if (inspector && current_connection_inspector_io == inspector_io) {
              tempInspector = inspector;
              inspector = nil;
              NSSetUncaughtExceptionHandler(NULL);

              if (inspector_io) {
                  dispatch_io_close(inspector_io, DISPATCH_IO_STOP);
                  inspector_io = 0;
              }
          }
      }
      // Release and dealloc old inspector; must be outside of the inspectorLock
      // because it locks the VM
      tempInspector = nil;
    };

    dispatch_block_t clear = ^{
      if (listenSource) {
          NSLog(@"NativeScript debugger closing inspector port.");
          dispatch_source_cancel(listenSource);
          listenSource = nil;
      }

      clearInspector();
    };

    [[NSNotificationCenter defaultCenter]
        addObserverForName:UIApplicationWillResignActiveNotification
                    object:nil
                     queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification* note) {
                  notify_post(NOTIFICATION("ApplicationWillResignActive"));
                }];

    [[NSNotificationCenter defaultCenter]
        addObserverForName:UIApplicationDidBecomeActiveNotification
                    object:nil
                     queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification* note) {
                  notify_post(NOTIFICATION("ApplicationDidBecomeActive"));
                }];

    TNSInspectorFrontendConnectedHandler connectionHandler = ^TNSInspectorProtocolHandler(
        TNSInspectorSendMessageBlock sendMessageToFrontend, NSError* error, dispatch_io_t io) {
      if (error) {
          if (listenSource) {
              clear();
          }

          NSLog(@"NativeScript debugger encountered %@.", error);
          return nil;
      }

      // Keep a working copy for calling into the VM after releasing
      // inspectorLock
      TNSRuntimeInspector* tempInspector = nil;
      @synchronized(inspectorLock()) {
          if (inspector) {
              return nil;
          }
      }

      // potentially race with other connections to create the inspector
      // outside of a lock
      tempInspector =
          [runtime attachInspectorWithHandler:sendMessageToFrontend];

      @synchronized(inspectorLock()) {
          // another thread won, abort
          if (inspector) {
              return nil;
          }
          NSLog(@"NativeScript debugger attached.");

          inspector = tempInspector;
          inspector_io = io;
          current_connection_inspector_io = io;
          NSSetUncaughtExceptionHandler(&TNSInspectorUncaughtExceptionHandler);
      }

      if (isWaitingForDebugger) {
          isWaitingForDebugger = NO;
          CFRunLoopRef runloop = CFRunLoopGetMain();
          CFRunLoopPerformBlock(
              runloop, (__bridge CFTypeRef)(NSRunLoopCommonModes), ^{
                // If we pause right away the debugger messages that are sent
                // are not handled because the frontend is not yet initialized
                CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1, false);

                // Keep a working copy for calling into the VM after releasing
                // inspectorLock
                TNSRuntimeInspector* tempInspector = nil;
                @synchronized(inspectorLock()) {
                    tempInspector = inspector;
                }

                if (tempInspector) {
                    [tempInspector pause];
                }
              });
          CFRunLoopWakeUp(runloop);
      }
      return ^(NSString* message, NSError* error) {
        if (message) {
            // Keep a working copy for calling into the VM after releasing inspectorLock
            TNSRuntimeInspector* tempInspector = nil;
            @synchronized(inspectorLock()) {
                tempInspector = inspector;
            }

            if (tempInspector) {
                // NSLog(@"NativeScript Debugger receiving: %@", message);
                [tempInspector dispatchMessage:message];
            }
        } else {
            clearInspector();

            if (error) {
                NSLog(@"NativeScript debugger received %@. Disconnecting.",
                      error);
            } else {
                NSLog(@"NativeScript debugger detached.");
            }
        }
      };
    };

    TNSInspectorIoErrorHandler ioErrorHandler = ^(NSObject* dummy, NSError* error) {
      clearInspector();
      if (error) {
          NSLog(@"NativeScript debugger encountered %@.", error);
      }
    };

    int waitForDebuggerSubscription;
    notify_register_dispatch(
        NOTIFICATION("WaitForDebugger"), &waitForDebuggerSubscription,
        dispatch_get_main_queue(), ^(int token) {
          isWaitingForDebugger = YES;

          dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 30);
          dispatch_after(delay, dispatch_get_main_queue(), ^{
            if (isWaitingForDebugger) {
                isWaitingForDebugger = NO;
                NSLog(@"NativeScript waiting for debugger timeout elapsed. Continuing execution.");
            }
          });

          NSLog(@"NativeScript waiting for debugger.");

          CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopDefaultMode, ^{
            do {
                CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.1, false);
            } while (isWaitingForDebugger);
          });
          CFRunLoopWakeUp(CFRunLoopGetMain());
        });
   
    int refreshRequestSubscription;
    notify_register_dispatch(
        NOTIFICATION("RefreshRequest"), &refreshRequestSubscription,
        dispatch_get_main_queue(), ^(int token) {
            notify_post(NOTIFICATION("AppRefreshStarted"));

            JSGlobalContextRef context = runtime.globalContext;
            JSObjectRef globalObject = JSContextGetGlobalObject(context);
            JSStringRef liveSyncMethodName = JSStringCreateWithUTF8CString("__onLiveSync");
            JSValueRef liveSyncMethod = JSObjectGetProperty(context, globalObject, liveSyncMethodName, NULL);
            JSStringRelease(liveSyncMethodName);
            if (JSValueIsUndefined(context, liveSyncMethod))
            {
                LOG_FAILED_REFRESH(@"__onLiveSync method not found.");
                return;
            }

            JSValueRef exception = NULL;
            JSObjectCallAsFunction(context, (JSObjectRef)liveSyncMethod, NULL, 0, NULL, &exception);
            if (!JSValueIsNull(context, exception))
            {
                JSStringRef exMessage = JSValueToStringCopy(context, exception, NULL);
                long messageLength = JSStringGetLength(exMessage) + 1;
                char* buffer = (char *)calloc(messageLength, sizeof(char));
                JSStringGetUTF8CString(exMessage, buffer, messageLength);
                JSStringRelease(exMessage);
                
                NSString *reason = [NSString stringWithFormat:@"__onLiveSync failed with: %s", buffer];
                LOG_FAILED_REFRESH(reason);
                free(buffer);
                return;
            }
            
            notify_post(NOTIFICATION("AppRefreshSucceeded"));
    });

    int attachRequestSubscription;
    notify_register_dispatch(
        NOTIFICATION("AttachRequest"), &attachRequestSubscription,
        dispatch_get_main_queue(), ^(int token) {
          clear();
          listenSource = TNSCreateInspectorServer(
              connectionHandler, ioErrorHandler, clearInspector);

          LOG_DEBUGGER_PORT;
          notify_post(NOTIFICATION("ReadyForAttach"));
        });

    // TODO: remove the AttachAvailabilityQuery, AlreadyConnected, ReadyForAttach and
    // AttachAvailable notifications as starting from CLI 5.1.1 they are not used anymore.
    int attachAvailabilityQuerySubscription;
    notify_register_dispatch(NOTIFICATION("AttachAvailabilityQuery"),
                             &attachAvailabilityQuerySubscription,
                             dispatch_get_main_queue(), ^(int token) {
                               if (inspector) {
                                   LOG_DEBUGGER_PORT;
                                   notify_post(NOTIFICATION("AlreadyConnected"));
                               } else if (listenSource) {
                                   LOG_DEBUGGER_PORT;
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
