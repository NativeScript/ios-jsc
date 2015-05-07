#!/usr/bin/env bash

set -e

WORKSPACE=`pwd`

CMAKE_FLAGS="-G Xcode -DCMAKE_C_COMPILER_WORKS=YES -DCMAKE_CXX_COMPILER_WORKS=YES -DCMAKE_INSTALL_PREFIX=$WORKSPACE/dist"

mkdir -p $WORKSPACE/cmake-build
cd $WORKSPACE/cmake-build

cmake .. -DCMAKE_OSX_SYSROOT=iphonesimulator $CMAKE_FLAGS
cmake --build . --config Release --target NativeScript

cmake .. -DCMAKE_OSX_SYSROOT=iphoneos $CMAKE_FLAGS
cmake --build . --config Release --target NativeScript

cmake --build . --config Release --target MetadataGenerator

echo "Packaging NativeScript..."
mkdir -p $WORKSPACE/dist/NativeScript/lib
lipo -create -output $WORKSPACE/dist/NativeScript/lib/libNativeScript.a \
    $WORKSPACE/cmake-build/src/NativeScript/Release-iphonesimulator/libNativeScript.a \
    $WORKSPACE/cmake-build/src/NativeScript/Release-iphoneos/libNativeScript.a

mkdir -p $WORKSPACE/dist/NativeScript/include
NATIVESCRIPT_DIR=$WORKSPACE/src/NativeScript/
cp \
    $NATIVESCRIPT_DIR/NativeScript.h \
    $NATIVESCRIPT_DIR/TNSRuntime.h \
    $NATIVESCRIPT_DIR/TNSRuntime+Inspector.h \
    $WORKSPACE/dist/NativeScript/include

cmake .. -DCMAKE_OSX_SYSROOT=iphonesimulator $CMAKE_FLAGS -DBUILD_SHARED_LIBS=YES
cmake --build . --config Release --target NativeScript

cmake .. -DCMAKE_OSX_SYSROOT=iphoneos $CMAKE_FLAGS -DBUILD_SHARED_LIBS=YES
cmake --build . --config Release --target NativeScript

echo "Packaging NativeScript-Shared..."
mkdir -p $WORKSPACE/dist/NativeScriptEmbedded/Release
cp -r $WORKSPACE/cmake-build/src/NativeScript/Release-iphoneos/NativeScript.framework $WORKSPACE/dist/NativeScriptEmbedded/Release

mkdir -p $WORKSPACE/dist/NativeScriptEmbedded/Debug
cp -r $WORKSPACE/dist/NativeScriptEmbedded/Release/NativeScript.framework $WORKSPACE/dist/NativeScriptEmbedded/Debug
rm $WORKSPACE/dist/NativeScriptEmbedded/Debug/NativeScript.framework/NativeScript
lipo -create -output $WORKSPACE/dist/NativeScriptEmbedded/Debug/NativeScript.framework/NativeScript \
    $WORKSPACE/cmake-build/src/NativeScript/Release-iphonesimulator/NativeScript.framework/NativeScript \
    $WORKSPACE/cmake-build/src/NativeScript/Release-iphoneos/NativeScript.framework/NativeScript
