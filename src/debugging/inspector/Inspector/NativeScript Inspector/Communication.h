#ifndef Communication_h
#define Communication_h

#import <Foundation/Foundation.h>
#import <netinet/in.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <errno.h>
#import <stdlib.h>
#import <string.h>
#import <notify.h>

typedef void (^InspectorReadHandler)(dispatch_data_t data);
typedef void (^InspectorWriteHandler)(void *buffer);
typedef void (^InspectorErrorHandler)(NSError *error);

#define CheckError(retval, handler)                                            \
  ({                                                                           \
    typeof(retval) errorCode = retval;                                         \
    BOOL success = NO;                                                         \
    if (errorCode == 0)                                                        \
      success = YES;                                                           \
    else if (errorCode == -1)                                                  \
      errorCode = errno;                                                       \
    if (!success)                                                              \
      handler([NSError errorWithDomain:NSPOSIXErrorDomain                      \
                                  code:errorCode                               \
                              userInfo:nil]);                                  \
    success;                                                                   \
  })

dispatch_io_t setup_communication_channel(char *socket_path,
                                          InspectorReadHandler read_handler,
                                          InspectorErrorHandler error_handler);

void send_message(dispatch_io_t channel, uint32_t length,
                  InspectorWriteHandler writeHandler,
                  InspectorErrorHandler error_handler);

#endif /* Communication_h */
