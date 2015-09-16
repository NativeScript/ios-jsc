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

struct communication_channel {
    BOOL connected;
    dispatch_fd_t socket;
    __unsafe_unretained dispatch_io_t io_channel;
};

typedef struct communication_channel communication_channel;
typedef void (^InspectorReadHandler)(dispatch_data_t data);
typedef void (^InspectorErrorHandler)(NSError* error);

#define CheckError(retval, handler)                             \
    ({                                                          \
        typeof(retval) errorCode = retval;                      \
        BOOL success = NO;                                      \
        if (errorCode == 0)                                     \
            success = YES;                                      \
        else if (errorCode == -1)                               \
            errorCode = errno;                                  \
        if (!success)                                           \
            handler([NSError errorWithDomain:NSPOSIXErrorDomain \
                                        code:errorCode          \
                                    userInfo:nil]);             \
        success;                                                \
    })

communication_channel setup_communication_channel(char* socket_path, InspectorReadHandler read_handler, InspectorErrorHandler error_handler);

void disconnect(communication_channel);
void send_message(communication_channel communication_channel, uint32_t length, void* message, InspectorErrorHandler error_handler);

#endif /* Communication_h */
