#!/usr/bin/env bash

set -e
set -o pipefail

source "$(dirname "$0")/common.sh"

checkpoint "Building TestRunner application"

mkdir -p "$WORKSPACE/cmake-build" && pushd "$_"
# Delete the CMake cache because a previous build could have generated the runtime with a shared framework.
# When using CMake 3.1 (which we have to) there is a bug that prevents building applications that link with a shared framework.
rm -f "CMakeCache.txt"
cmake .. -G"Xcode"
# We are building in Debug configuration to trigger any failing asserts in our CI.
# This also builds the metadata generator in debug mode.
xcodebuild -configuration "Debug" -sdk "iphoneos" -target "TestRunner" ARCHS="armv7 arm64" ONLY_ACTIVE_ARCH="NO" -quiet
popd

checkpoint "Packaging TestRunner"
xcrun -sdk "iphoneos" PackageApplication \
    "$WORKSPACE/cmake-build/tests/TestRunner/Debug-iphoneos/TestRunner.app" \
    -o "$WORKSPACE/cmake-build/tests/TestRunner/Debug-iphoneos/TestRunner.ipa"
cp "$WORKSPACE/cmake-build/tests/TestRunner/Debug-iphoneos/TestRunner.ipa" "$DIST_DIR"

checkpoint "Finished building TestRunner application - $DIST_DIR/TestRunner.ipa"
