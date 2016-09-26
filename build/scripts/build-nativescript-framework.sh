#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

checkpoint "Building NativeScript.framework"

mkdir -p "$WORKSPACE/cmake-build" && pushd "$_"
# Delete the CMake cache because a previous build could have generated the runtime with a static library.
rm -f "CMakeCache.txt"
cmake .. -G"Xcode" -D"BUILD_SHARED_LIBS=ON"
checkpoint "Building NativeScript.framework - iphoneos SDK"
xcodebuild -configuration "Release" -sdk "iphoneos" -target "NativeScript" -quiet
checkpoint "Building NativeScript.framework - iphonesimulator SDK"
xcodebuild -configuration "Release" -sdk "iphonesimulator" -target "NativeScript" -quiet
popd

checkpoint "Packaging NativeScript.framework"
mkdir -p "$DIST_DIR" && pushd "$_"
cp -r "$WORKSPACE/cmake-build/src/NativeScript/Release-iphoneos/NativeScript.framework" "."
rm "NativeScript.framework/NativeScript"
lipo -create -output "NativeScript.framework/NativeScript" \
    "$WORKSPACE/cmake-build/src/NativeScript/Release-iphonesimulator/NativeScript.framework/NativeScript" \
    "$WORKSPACE/cmake-build/src/NativeScript/Release-iphoneos/NativeScript.framework/NativeScript"
popd

checkpoint "Finished building NativeScript.framework - $DIST_DIR/NativeScript.framework"
