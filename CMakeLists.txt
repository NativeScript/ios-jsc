cmake_minimum_required(VERSION 3.1)
project(NativeScript)

set(CMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS "macosx iphoneos iphonesimulator")
set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos;-iphonesimulator;-macosx")
set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")
set(CMAKE_OSX_SYSROOT $(PLATFORM_NAME))

set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "7.0")

# TODO: Versions, license, etc

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

set(LIBFFI_DIR "${CMAKE_SOURCE_DIR}/src/libffi")
set(WEBKIT_DIR "${CMAKE_SOURCE_DIR}/dist/jsc")
set(RUNTIME_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/NativeScript")
set(NATIVESCRIPT_DEBUGGING_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/debugging/")

set(MAIN_TEMPLATE "${CMAKE_SOURCE_DIR}/cmake/main.m")
set(INFO_PLIST_TEMPLATE "${CMAKE_SOURCE_DIR}/cmake/Info.plist")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11 -stdlib=libc++")

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DDEBUG=1")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG=1")

# TODO: Clang Analyzer, Tidy ...

option(BUILD_SHARED_LIBS "Build NativeScript as a Cocoa Framework" OFF)
option(EMBED_STATIC_DEPENDENCIES "Embed JavaScriptCore and libffi in the NativeScript static library" OFF)

include(src/WebKit.cmake)
include(src/MetadataGenerator.cmake)

add_subdirectory(src/NativeScript)
add_subdirectory(examples/Gameraww)
add_subdirectory(examples/BlankApp)
add_subdirectory(examples/HelloWorldApp)
add_subdirectory(tests/TestFixtures)
add_subdirectory(tests/TestRunner)
