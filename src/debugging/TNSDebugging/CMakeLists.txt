set(HEADER_FILES
    TNSDebugging-Prefix.h

    TCPMessaging/TNSInputMessageStream.h
    TCPMessaging/TNSMessageStreamDelegate.h
    TCPMessaging/TNSOutputMessageStream.h
    TCPMessaging/TNSTCPMessagingServer.h
    TCPMessaging/TNSTCPSocketMessageNetworkThread.h
    TNSDebugging.h
    TNSDebugMessaging.h
    TNSDebugServer.h
    TNSMultiChannel.h
    WebSocketMessaging/TNSWebSocketMessagingServer.h
)

set(SOURCE_FILES
    TCPMessaging/TNSInputMessageStream.m
    TCPMessaging/TNSOutputMessageStream.m
    TCPMessaging/TNSTCPMessagingServer.m
    TCPMessaging/TNSTCPSocketMessageNetworkThread.m
    TNSDebugging.m
    TNSDebugServer.m
    TNSMultiChannel.m
    WebSocketMessaging/TNSWebSocketMessagingServer.m
)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}/**" "${RUNTIME_DIR}" "${POCKET_SOCKET_DIR}/include")

add_library(TNSDebugging ${SOURCE_FILES} ${HEADER_FILES})

set_target_properties(TNSDebugging PROPERTIES
    COMPILE_FLAGS "
        -fobjc-arc
        -Werror -Wall -Wextra
        -Wno-unused-parameter
    "
    STATIC_LIBRARY_FLAGS "
        -lPocketSocket -L${POCKET_SOCKET_DIR}/lib
    "
)

include(SetActiveArchitectures)
SetActiveArchitectures(TNSDebugging)

include(GroupSources)
GroupSources(TNSDebugging)

include(PrecompiledHeaders)
SetPrecompiledHeader(TNSDebugging TNSDebugging-Prefix.h)
