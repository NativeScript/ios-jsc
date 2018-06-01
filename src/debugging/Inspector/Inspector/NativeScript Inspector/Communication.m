#import "Communication.h"
#import <errno.h>
#import <netinet/in.h>
#import <notify.h>
#import <stdlib.h>
#import <string.h>
#import <sys/socket.h>
#import <sys/types.h>
#import <sys/un.h>

@implementation TNSCommunicationChannel {
    InspectorErrorHandler errorHandler;
}

- (instancetype)initWithSocketPath:(NSString*)socketPath readHandler:(InspectorReadHandler)readHandler errorHandler:(InspectorErrorHandler)errorHandler {
    self = [super init];
    if (self) {
        self->errorHandler = errorHandler;

        __block dispatch_fd_t communicationSocket;
        __block dispatch_io_t communicationIOChannel;

        dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t main_queue = dispatch_get_main_queue();

        void (^read)(void) = ^{
          __block dispatch_io_handler_t ioHandler = ^(bool done, dispatch_data_t data, int error) {
            if (!CheckError(error, self->errorHandler)) {
                return;
            }

            const void* bytes = [(NSData*)data bytes];
            if (!bytes) {
                close(communicationSocket);
                return;
            }

            uint32_t length = ntohl(*(uint32_t*)bytes);

            dispatch_io_set_low_water(communicationIOChannel, length);
            dispatch_io_read(communicationIOChannel, 0, length, global_queue,
                             ^(bool done, dispatch_data_t data, int error) {
                               if (!CheckError(error, self->errorHandler)) {
                                   return;
                               }

                               dispatch_async(main_queue, ^(void) {
                                 readHandler(data);
                               });

                               dispatch_io_read(communicationIOChannel, 0, 4, global_queue, ioHandler);
                             });
          };

          dispatch_io_read(communicationIOChannel, 0, 4, global_queue, ioHandler);
        };

        BOOL (^setupConnection)
        (const struct sockaddr*, socklen_t) = ^(const struct sockaddr* addr, socklen_t socketLength) {
          communicationIOChannel = dispatch_io_create(DISPATCH_IO_STREAM, communicationSocket, global_queue,
                                                      ^(int error) {
                                                        CheckError(error, self->errorHandler);
                                                      });

          int result = connect(communicationSocket, addr, socketLength);
          int error = errno;
          if (error == EINPROGRESS) {
              fd_set write_fds;
              FD_ZERO(&write_fds);
              FD_SET(communicationSocket, &write_fds);

              struct timeval tv;
              tv.tv_sec = 5;
              tv.tv_usec = 0;

              int sel = 0;
              sel = select(communicationSocket + 1, NULL, &write_fds, NULL, &tv);
              if (sel > 0) {
                  socklen_t lon = sizeof(int);
                  int so_error;

                  if (getsockopt(communicationSocket, SOL_SOCKET, SO_ERROR, (void*)(&so_error), &lon) >= 0) {
                      if (so_error == 0) {
                          result = 0; // socket is now writable and no error has occurred
                      } else {
                          error = so_error;
                      }
                  }
              }
          }
          if (result) {
              self->errorHandler([NSError errorWithDomain:@"Unable to connect" code:error userInfo:nil]);

              return NO;
          }

          read();

          self.ioChannel = communicationIOChannel;
          self.socket = communicationSocket;

          return YES;
        };

        BOOL connected;

        if (!socketPath || !socketPath.length) {
            communicationSocket = socket(PF_INET, SOCK_STREAM, 0);

            struct sockaddr_in addr = {
                sizeof(addr), AF_INET, htons(18183), { INADDR_ANY }, { 0 }
            };

            connected = setupConnection((const struct sockaddr*)&addr, sizeof(addr));

        } else {
            communicationSocket = socket(AF_UNIX, SOCK_STREAM, 0);

            struct sockaddr_un addr;
            memset(&addr, 0, sizeof(addr));
            addr.sun_family = AF_UNIX;

            strncpy(addr.sun_path, [socketPath UTF8String], sizeof(addr.sun_path) - 1);

            connected = setupConnection((const struct sockaddr*)&addr, sizeof(addr));
        }

        if (!connected) {
            return nil;
        }
    }

    return self;
}

- (void)sendMessage:(uint32_t)length message:(void*)message {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    void* buffer = malloc(length + sizeof(uint32_t));
    *(uint32_t*)buffer = htonl(length);

    memcpy(&buffer[sizeof(uint32_t)], message, length);

    dispatch_data_t data = dispatch_data_create(buffer, length + sizeof(uint32_t), queue, ^{
      free(buffer);
    });

    dispatch_io_write(self.ioChannel, 0, data, queue,
                      ^(bool done, dispatch_data_t data, int error) {
                        CheckError(error, self->errorHandler);
                      });
}

- (void)dealloc {
    if (self.ioChannel) {
        dispatch_io_close(self.ioChannel, DISPATCH_IO_STOP);
    }
}

@end
