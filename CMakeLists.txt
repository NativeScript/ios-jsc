cmake_minimum_required(VERSION 3.1)
project(NativeScript)

set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-iphoneos;-iphonesimulator")

# TODO: Versions, license, etc

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")

set(LIBFFI_DIR "${CMAKE_SOURCE_DIR}/src/libffi")
set(WEBKIT_DIR "${CMAKE_SOURCE_DIR}/dist/jsc")
set(RUNTIME_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/NativeScript")
set(NATIVESCRIPT_DEBUGGING_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/debugging/")
set(TESTFIXTURES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/tests/TestFixtures")

file(READ "${TESTFIXTURES_DIR}/exported-symbols.txt" TESTFIXTURES_EXPORTED_SYMBOLS)
string(REPLACE "\n" ";" TESTFIXTURES_EXPORTED_SYMBOLS "${TESTFIXTURES_EXPORTED_SYMBOLS}")

set(MAIN_TEMPLATE "${CMAKE_SOURCE_DIR}/cmake/main.m")
set(INFO_PLIST_TEMPLATE "${CMAKE_SOURCE_DIR}/cmake/Info.plist")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++11 -stdlib=libc++")

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DDEBUG=1")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG=1")

# TODO: Clang Analyzer, Tidy ...

add_subdirectory(src/NativeScript)
add_subdirectory(examples/Gameraww)
add_subdirectory(examples/BlankApp)
add_subdirectory(examples/HelloWorldApp)
add_subdirectory(tests/TestFixtures)
add_subdirectory(tests/TestRunner)

include(ExternalProject)
ExternalProject_Add(MetadataGenerator
    SOURCE_DIR "${CMAKE_SOURCE_DIR}/src/metadata-generator"
    CONFIGURE_COMMAND env -i "${CMAKE_COMMAND}"
        -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/metadataGenerator
        -DCMAKE_BUILD_TYPE=$<CONFIG>
        "${CMAKE_SOURCE_DIR}/src/metadata-generator"
    BUILD_COMMAND env -i "${CMAKE_COMMAND}"
        --build .
        --target install
        --use-stderr
    INSTALL_COMMAND "${CMAKE_COMMAND}"
        -E copy "${CMAKE_SOURCE_DIR}/build/scripts/metadata-generation-build-step.sh" "${CMAKE_INSTALL_PREFIX}/metadataGenerator/bin"
)
