cmake_minimum_required(VERSION 3.3)

option(BUILD_SHARED_LIBS "Build NativeScript as a Cocoa Framework" OFF)
option(USE_CCACHE "Build NativeScript using ccache" ON)
option(EMBED_STATIC_DEPENDENCIES "Embed JavaScriptCore and libffi in the NativeScript static library" OFF)

find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND AND USE_CCACHE)
  MESSAGE( STATUS "## Using CCache when building!")
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CCACHE_FOUND})
  set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ${CCACHE_FOUND})
endif(CCACHE_FOUND AND USE_CCACHE)

project(NativeScript)

get_property(RULE_LAUNCH_COMPILE GLOBAL PROPERTY RULE_LAUNCH_COMPILE)
if(RULE_LAUNCH_COMPILE AND CMAKE_GENERATOR STREQUAL "Xcode")
    # Set up wrapper scripts
    configure_file(launch-c.in   launch-c)
    configure_file(launch-cxx.in launch-cxx)
    execute_process(COMMAND chmod a+rx
                            "${CMAKE_BINARY_DIR}/launch-c"
                            "${CMAKE_BINARY_DIR}/launch-cxx")

    # Set Xcode project attributes to route compilation through our scripts
    set(CMAKE_XCODE_ATTRIBUTE_CC         "${CMAKE_BINARY_DIR}/launch-c")
    set(CMAKE_XCODE_ATTRIBUTE_CXX        "${CMAKE_BINARY_DIR}/launch-cxx")
    set(CMAKE_XCODE_ATTRIBUTE_LD         "${CMAKE_BINARY_DIR}/launch-c")
    set(CMAKE_XCODE_ATTRIBUTE_LDPLUSPLUS "${CMAKE_BINARY_DIR}/launch-cxx")
endif()

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

include(src/WebKit.cmake)
include(src/MetadataGenerator.cmake)
include(src/libffi.cmake)

add_subdirectory(src/NativeScript)
add_subdirectory(examples/Gameraww)
add_subdirectory(examples/BlankApp)
add_subdirectory(examples/HelloWorldApp)
add_subdirectory(tests/TestFixtures)
add_subdirectory(tests/TestRunner)
