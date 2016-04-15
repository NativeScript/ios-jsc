cmake_minimum_required(VERSION 3.1)
project(NativeScript)

set(CMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS "macosx iphoneos iphonesimulator")
set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos;-iphonesimulator;-macosx")
set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")
set(CMAKE_OSX_SYSROOT $(PLATFORM_NAME))

set(CMAKE_XCODE_ATTRIBUTE_IPHONEOS_DEPLOYMENT_TARGET "8.0")

# TODO: Versions, license, etc

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

set(RUNTIME_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/NativeScript")
set(NATIVESCRIPT_DEBUGGING_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/debugging/")

set(MAIN_TEMPLATE "${CMAKE_SOURCE_DIR}/cmake/main.m")
set(INFO_PLIST_TEMPLATE "${CMAKE_SOURCE_DIR}/cmake/Info.plist")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11 -stdlib=libc++")

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DDEBUG=1")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG=1")

execute_process(
    COMMAND "python" "${CMAKE_SOURCE_DIR}/build/scripts/get_version.py" "${CMAKE_SOURCE_DIR}/build/npm/runtime_package.json"
    OUTPUT_VARIABLE NATIVESCRIPT_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# TODO: Clang Analyzer, Tidy ...

include(src/WebKit.cmake)
include(src/MetadataGenerator.cmake)
include(src/libffi.cmake)

add_subdirectory(src/NativeScript)
add_subdirectory(examples/Gameraww)
add_subdirectory(examples/BlankApp)
add_subdirectory(examples/HelloWorldApp)
add_subdirectory(tests/TestFixtures)
add_subdirectory(tests/TestRunner)
