cmake_minimum_required(VERSION 3.1)
project(NativeScript)

set(CMAKE_XCODE_ATTRIBUTE_SDKROOT "iphoneos")
set(CMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS "iphoneos iphonesimulator")
set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos;-iphonesimulator")
set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")

set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "8.0")

# TODO: Versions, license, etc

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

set(RUNTIME_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/NativeScript")
set(NATIVESCRIPT_DEBUGGING_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/debugging/")

set(MAIN_TEMPLATE "${CMAKE_SOURCE_DIR}/cmake/main.m")
set(INFO_PLIST_TEMPLATE "${CMAKE_SOURCE_DIR}/cmake/Info.plist")

#WTF uses char16_t for UCHAR_TYPE and we need to match it
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++14 -stdlib=libc++ -DUCHAR_TYPE=char16_t")

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DDEBUG=1")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG=1")

execute_process(
    COMMAND "python" "${CMAKE_SOURCE_DIR}/build/scripts/get_version.py" "${CMAKE_SOURCE_DIR}/build/npm/runtime_package.json"
    OUTPUT_VARIABLE VERSIONS
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

list(GET VERSIONS 0 BASE_NATIVESCRIPT_VERSION)
list(GET VERSIONS 1 NATIVESCRIPT_VERSION)
list(GET VERSIONS 2 NATIVESCRIPT_FRAMEWORK_VERSION)

# TODO: Clang Analyzer, Tidy ...

option(BUILD_SHARED_LIBS "Build NativeScript as a Cocoa Framework" OFF)
option(EMBED_STATIC_DEPENDENCIES "Embed JavaScriptCore and libffi in the NativeScript static library" OFF)

include(src/WebKit.cmake)
include(src/MetadataGenerator.cmake)
include(src/libffi.cmake)

add_subdirectory(src/NativeScript)
add_subdirectory(examples/Gameraww)
add_subdirectory(examples/BlankApp)
add_subdirectory(examples/HelloWorldApp)
add_subdirectory(tests/TestFixtures)
add_subdirectory(tests/TestRunner)
