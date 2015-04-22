#!/usr/bin/env bash

set -e

WORKSPACE=`pwd`

CMAKE_FLAGS="-G Xcode -DCMAKE_C_COMPILER_WORKS=YES -DCMAKE_CXX_COMPILER_WORKS=YES -DCMAKE_INSTALL_PREFIX=$WORKSPACE/dist"

mkdir -p $WORKSPACE/cmake-build
cd $WORKSPACE/cmake-build

cmake .. -DCMAKE_OSX_SYSROOT=iphonesimulator $CMAKE_FLAGS
cmake --build . --config Release --target NativeScript
cmake --build . --config Release --target TNSDebugging

cmake .. -DCMAKE_OSX_SYSROOT=iphoneos $CMAKE_FLAGS
cmake --build . --config Release --target NativeScript
cmake --build . --config Release --target TNSDebugging

cmake --build . --config Release --target MetadataGenerator

echo "Packaging NativeScript..."
mkdir -p $WORKSPACE/dist/NativeScript.framework/
lipo -create -output $WORKSPACE/dist/NativeScript.framework/NativeScript \
    $WORKSPACE/cmake-build/src/NativeScript/Release-iphonesimulator/libNativeScript.a \
    $WORKSPACE/cmake-build/src/NativeScript/Release-iphoneos/libNativeScript.a

mkdir -p $WORKSPACE/dist/NativeScript.framework/Headers
NATIVESCRIPT_DIR=$WORKSPACE/src/NativeScript/
cp \
    $NATIVESCRIPT_DIR/NativeScript.h \
    $NATIVESCRIPT_DIR/TNSRuntime.h \
    $NATIVESCRIPT_DIR/TNSRuntime+Inspector.h \
    $WORKSPACE/dist/NativeScript.framework/Headers

echo "Packaging TNSDebugging..."
mkdir -p $WORKSPACE/dist/TNSDebugging.framework/
lipo -create -output $WORKSPACE/dist/TNSDebugging.framework/TNSDebugging \
    $WORKSPACE/cmake-build/src/debugging/TNSDebugging/Release-iphonesimulator/libTNSDebugging.a \
    $WORKSPACE/cmake-build/src/debugging/TNSDebugging/Release-iphoneos/libTNSDebugging.a

mkdir -p $WORKSPACE/dist/TNSDebugging.framework/Headers
TNSDEBUGGING_DIR=$WORKSPACE/src/debugging/TNSDebugging/
cp \
    $TNSDEBUGGING_DIR/TNSDebugging.h \
    $WORKSPACE/dist/TNSDebugging.framework/Headers
