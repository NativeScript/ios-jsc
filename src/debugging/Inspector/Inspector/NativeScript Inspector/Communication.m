#import "Communication.h"
#import <netinet/in.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/un.h>
#import <errno.h>
#import <stdlib.h>
#import <string.h>
#import <notify.h>

communication_channel setup_communication_channel(char* socket_path, InspectorReadHandler read_handler, InspectorErrorHandler error_handler) {
    communication_channel communication_channel;
    communication_channel.connected = NO;

    __block dispatch_fd_t _socket;
    __block dispatch_io_t _channel;

    dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t main_queue = dispatch_get_main_queue();

    void (^read)(void) = ^{
      __block dispatch_io_handler_t ioHandler = ^(bool done, dispatch_data_t data, int error) {
        if (!CheckError(error, error_handler)) {
            return;
        }

        const void* bytes = [(NSData*)data bytes];
        if (!bytes) {
            close(_socket);
            return;
        }

        uint32_t length = ntohl(*(uint32_t*)bytes);

        dispatch_io_set_low_water(_channel, length);
        dispatch_io_read(_channel, 0, length, global_queue,
                         ^(bool done, dispatch_data_t data, int error) {
                           if (!CheckError(error, error_handler)) {
                               return;
                           }

                           dispatch_async(main_queue, ^(void) {
                             read_handler(data);
                           });

                           dispatch_io_read(_channel, 0, 4, global_queue, ioHandler);
                         });
      };

      dispatch_io_read(_channel, 0, 4, global_queue, ioHandler);
    };

    if (socket_path && !socket_path[0]) {
        _socket = socket(PF_INET, SOCK_STREAM, 0);
        _channel = dispatch_io_create(DISPATCH_IO_STREAM, _socket, global_queue,
                                      ^(int error) {
                                        CheckError(error, error_handler);
                                      });

        struct sockaddr_in addr = {
            sizeof(addr), AF_INET, htons(18181), { INADDR_ANY }, { 0 }
        };
        int result = connect(_socket, (const struct sockaddr*)&addr, sizeof(addr));
        if (result) {
            error_handler([NSError errorWithDomain:@"Unable to connect" code:errno userInfo:nil]);

            return communication_channel;
        } else {
            read();
        }

    } else {
        _socket = socket(AF_UNIX, SOCK_STREAM, 0);
        _channel = dispatch_io_create(DISPATCH_IO_STREAM, _socket, global_queue,
                                      ^(int error) {
                                        CheckError(errno, error_handler);
                                      });

        struct sockaddr_un addr;
        memset(&addr, 0, sizeof(addr));
        addr.sun_family = AF_UNIX;

        strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path) - 1);

        int result = connect(_socket, (const struct sockaddr*)&addr, sizeof(addr));
        if (result) {
            error_handler([NSError errorWithDomain:@"Unable to connect" code:errno userInfo:nil]);

            return communication_channel;
        } else {
            read();
        }
    }

    communication_channel.connected = YES;
    communication_channel.io_channel = _channel;
    communication_channel.socket = _socket;

    return communication_channel;
}

void disconnect(communication_channel communication_channel) {
    dispatch_io_close(communication_channel.io_channel, DISPATCH_IO_STOP);
}

void send_message(communication_channel communication_channel, uint32_t length, void* message, InspectorErrorHandler error_handler) {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    void* buffer = malloc(length + sizeof(uint32_t));
    *(uint32_t*)buffer = htonl(length);

    memcpy(&buffer[sizeof(uint32_t)], message, length);

    dispatch_data_t data = dispatch_data_create(buffer, length + sizeof(uint32_t), queue, ^{
      free(buffer);
    });

    dispatch_io_write(communication_channel.io_channel, 0, data, queue,
                      ^(bool done, dispatch_data_t data, int error) {
                        CheckError(error, error_handler);
                      });
}