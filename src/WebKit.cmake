set(WEBKIT_SOURCE_DIR "${PROJECT_SOURCE_DIR}/src/WebKit")
set(WTF_SOURCE_DIR "${WEBKIT_SOURCE_DIR}/Source/WTF")
set(JavaScriptCore_SOURCE_DIR "${WEBKIT_SOURCE_DIR}/Source/JavaScriptCore")
set(JavaScriptCore_INCLUDE_DIRECTORIES
    "${JavaScriptCore_SOURCE_DIR}"
    "${JavaScriptCore_SOURCE_DIR}/API"
    "${JavaScriptCore_SOURCE_DIR}/ForwardingHeaders"
    "${JavaScriptCore_SOURCE_DIR}/assembler"
    "${JavaScriptCore_SOURCE_DIR}/bindings"
    "${JavaScriptCore_SOURCE_DIR}/builtins"
    "${JavaScriptCore_SOURCE_DIR}/bytecode"
    "${JavaScriptCore_SOURCE_DIR}/bytecompiler"
    "${JavaScriptCore_SOURCE_DIR}/dfg"
    "${JavaScriptCore_SOURCE_DIR}/disassembler"
    "${JavaScriptCore_SOURCE_DIR}/ftl"
    "${JavaScriptCore_SOURCE_DIR}/heap"
    "${JavaScriptCore_SOURCE_DIR}/debugger"
    "${JavaScriptCore_SOURCE_DIR}/inspector"
    "${JavaScriptCore_SOURCE_DIR}/inspector/agents"
    "${JavaScriptCore_SOURCE_DIR}/inspector/augmentable"
    "${JavaScriptCore_SOURCE_DIR}/inspector/remote"
    "${JavaScriptCore_SOURCE_DIR}/interpreter"
    "${JavaScriptCore_SOURCE_DIR}/jit"
    "${JavaScriptCore_SOURCE_DIR}/llint"
    "${JavaScriptCore_SOURCE_DIR}/llvm"
    "${JavaScriptCore_SOURCE_DIR}/parser"
    "${JavaScriptCore_SOURCE_DIR}/profiler"
    "${JavaScriptCore_SOURCE_DIR}/replay"
    "${JavaScriptCore_SOURCE_DIR}/runtime"
    "${JavaScriptCore_SOURCE_DIR}/tools"
    "${JavaScriptCore_SOURCE_DIR}/yarr"
)

set(WEBKIT_CMAKE_ARGS
    -DCMAKE_SYSTEM_PROCESSOR=arm
    -DCMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS=${CMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS}
    -DCMAKE_XCODE_EFFECTIVE_PLATFORMS=${CMAKE_XCODE_EFFECTIVE_PLATFORMS}
    -DPORT=Mac
    -DENABLE_INSPECTOR=ON
    -DENABLE_REMOTE_INSPECTOR=OFF
    -DJSC_OBJC_API_ENABLED=OFF
    -DUCONFIG_NO_COLLATION=ON
    -Wno-dev
    -DCMAKE_C_COMPILER_WORKS=YES
    -DCMAKE_CXX_COMPILER_WORKS=YES
    -DHAVE_QOS_CLASSES=OFF
    -DENABLE_WEBCORE=OFF
    -DENABLE_WEBKIT=OFF
    -DENABLE_WEBKIT2=OFF
)

include(ExternalProject)
ExternalProject_Add(
    WebKit
    SOURCE_DIR ${WEBKIT_SOURCE_DIR}
    CMAKE_GENERATOR ${CMAKE_GENERATOR}
    CMAKE_ARGS ${WEBKIT_CMAKE_ARGS}
    BUILD_COMMAND ${CMAKE_SOURCE_DIR}/build/scripts/buildWebKitFromWithinXcode.sh
    INSTALL_COMMAND ""
)

include(SetActiveArchitectures)
SetActiveArchitectures(WebKit)

get_property(WEBKIT_BINARY_DIR TARGET WebKit PROPERTY _EP_BINARY_DIR)

set(WEBKIT_INCLUDE_DIRECTORIES
    "${WEBKIT_SOURCE_DIR}/Source"
    "${WTF_SOURCE_DIR}"
    ${JavaScriptCore_INCLUDE_DIRECTORIES}
    "${WEBKIT_BINARY_DIR}"
    "${WEBKIT_BINARY_DIR}/DerivedSources"
    "${WEBKIT_BINARY_DIR}/DerivedSources/ForwardingHeaders"
    "${WEBKIT_BINARY_DIR}/DerivedSources/JavaScriptCore"
    "${WEBKIT_BINARY_DIR}/DerivedSources/JavaScriptCore/inspector"
)

set(WEBKIT_LINK_DIRECTORIES "${WEBKIT_BINARY_DIR}/Source/bmalloc" "${WEBKIT_BINARY_DIR}/Source/WTF/wtf" "${WEBKIT_BINARY_DIR}/Source/JavaScriptCore")
set(WEBKIT_LIBRARIES bmalloc WTF JavaScriptCore)

add_definitions(-DBUILDING_WITH_CMAKE=1 -DHAVE_CONFIG_H=1 -DSTATICALLY_LINKED_WITH_WTF)
