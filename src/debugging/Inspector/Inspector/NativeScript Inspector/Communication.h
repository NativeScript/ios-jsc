#ifndef Communication_h
#define Communication_h

#import <Foundation/Foundation.h>
#import <errno.h>
#import <netinet/in.h>
#import <notify.h>
#import <stdlib.h>
#import <string.h>
#import <sys/socket.h>
#import <sys/types.h>

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

typedef void (^InspectorReadHandler)(dispatch_data_t data);
typedef void (^InspectorErrorHandler)(NSError* error);

@interface TNSCommunicationChannel : NSObject
@property(nonatomic) dispatch_fd_t socket;
@property(nonatomic, strong) dispatch_io_t ioChannel;

- (instancetype)initWithSocketPath:(NSString*)socketPath readHandler:(InspectorReadHandler)readHandler errorHandler:(InspectorErrorHandler)errorHandler;
- (void)sendMessage:(uint32_t)length message:(void*)message;

@end

#endif /* Communication_h */
