#!/usr/bin/env bash

set -e

WORKSPACE=`pwd`

function xcodebuild_pretty {
    set -o pipefail && xcodebuild "$@" 2>&1 | tee -a "$WORKSPACE/build.log" | xcpretty
}

CMAKE_FLAGS="-G Xcode -DCMAKE_INSTALL_PREFIX=$WORKSPACE/dist"

mkdir -p "$WORKSPACE/cmake-build"
cd "$WORKSPACE/cmake-build"

echo "Building NativeScript.framework..."
rm -f CMakeCache.txt
rm -f "$WORKSPACE/build.log"
echo -e "\tConfiguring..."
cmake .. $CMAKE_FLAGS -DBUILD_SHARED_LIBS=ON 2>&1 | tee -a "$WORKSPACE/build.log"
echo -e "\tiPhoneOS..."
xcodebuild_pretty -configuration Release -sdk iphoneos -target NativeScript
echo -e "\tiPhoneSimulator..."
xcodebuild_pretty -configuration Release -sdk iphonesimulator -target NativeScript

echo "Packaging NativeScript.framework..."
mkdir -p "$WORKSPACE/dist"
cp -r "$WORKSPACE/cmake-build/src/NativeScript/Release-iphoneos/NativeScript.framework" "$WORKSPACE/dist"
rm "$WORKSPACE/dist/NativeScript.framework/NativeScript"
lipo -create -output "$WORKSPACE/dist/NativeScript.framework/NativeScript" \
    "$WORKSPACE/cmake-build/src/NativeScript/Release-iphonesimulator/NativeScript.framework/NativeScript" \
    "$WORKSPACE/cmake-build/src/NativeScript/Release-iphoneos/NativeScript.framework/NativeScript" \
         >> "$WORKSPACE/build.log" 2>&1

echo "Building libNativeScript..."
rm -f CMakeCache.txt
echo -e "\tConfiguring..."
cmake .. $CMAKE_FLAGS -DEMBED_STATIC_DEPENDENCIES=ON 2>&1 | tee -a "$WORKSPACE/build.log"
echo -e "\tiPhoneOS..."
xcodebuild_pretty -configuration Release -sdk iphoneos -target NativeScript
echo -e "\tiPhoneSimulator..."
xcodebuild_pretty -configuration Release -sdk iphonesimulator -target NativeScript

echo "Packaging libNativeScript..."
mkdir -p "$WORKSPACE/dist/NativeScript/lib"
lipo -create -output "$WORKSPACE/dist/NativeScript/lib/libNativeScript.a" \
    "$WORKSPACE/cmake-build/src/NativeScript/Release-iphonesimulator/libNativeScript.a" \
    "$WORKSPACE/cmake-build/src/NativeScript/Release-iphoneos/libNativeScript.a" \
         >> "$WORKSPACE/build.log" 2>&1

mkdir -p "$WORKSPACE/dist/NativeScript/include"
NATIVESCRIPT_DIR="$WORKSPACE/src/NativeScript/"
cp \
    "$NATIVESCRIPT_DIR/NativeScript.h" \
    "$NATIVESCRIPT_DIR/TNSRuntime.h" \
    "$NATIVESCRIPT_DIR/TNSRuntime+Inspector.h" \
    "$WORKSPACE/dist/NativeScript/include"

echo "Building objc-metadata-generator..."
xcodebuild_pretty -configuration Release -target MetadataGenerator
echo "Packaging objc-metadata-generator..."
cp -R "$WORKSPACE/cmake-build/metadataGenerator" "$WORKSPACE/dist/"
cp "$WORKSPACE/build/scripts/metadata-generation-build-step" "$WORKSPACE/dist/metadataGenerator/bin/"

echo "Building Gameraww..."
xcodebuild_pretty -configuration Release -sdk iphoneos -target Gameraww
echo "Packaging Gameraww..."
xcrun -sdk iphoneos PackageApplication -v "$WORKSPACE/cmake-build/examples/Gameraww/Release-iphoneos/Gameraww.app" \
    -o "$WORKSPACE/cmake-build/examples/Gameraww/Release-iphoneos/Gameraww.ipa" \
         >> "$WORKSPACE/build.log" 2>&1
GAMERAWW_IPA_SIZE=$(du -k "$WORKSPACE/cmake-build/examples/Gameraww/Release-iphoneos/Gameraww.ipa" | awk '{print $1}')
echo "TNS_IPA_SIZE: "$GAMERAWW_IPA_SIZE"KB"
echo "TNS_IPA_SIZE_KB\\n"$GAMERAWW_IPA_SIZE > "$WORKSPACE/build-stats.csv"

echo "Building TestRunner..."
xcodebuild_pretty -configuration Debug -sdk iphoneos -target TestRunner ARCHS="armv7" ONLY_ACTIVE_ARCH=NO
echo "Packaging TestRunner..."
xcrun -sdk iphoneos PackageApplication -v "$WORKSPACE/cmake-build/tests/TestRunner/Debug-iphoneos/TestRunner.app" \
    -o "$WORKSPACE/cmake-build/tests/TestRunner/Debug-iphoneos/TestRunner.ipa" \
         >> "$WORKSPACE/build.log" 2>&1