#!/usr/bin/env bash

set -e
set -o pipefail

CONFIGURATION="Release"

source "$(dirname "$0")/common.sh"

checkpoint "Building TestRunner application"

mkdir -p "$WORKSPACE/cmake-build" && pushd "$_"
# Delete the CMake cache because a previous build could have generated the runtime with a shared framework.
# When using CMake 3.1 (which we have to) there is a bug that prevents building applications that link with a shared framework.
rm -f "CMakeCache.txt"
cmake .. -G"Xcode"
xcodebuild \
-configuration "$CONFIGURATION" \
-sdk "iphoneos" \
-scheme "TestRunner" \
-target "TestRunner" \
ARCHS="armv7 arm64" \
ONLY_ACTIVE_ARCH="NO" \
-archivePath "$WORKSPACE/cmake-build/tests/TestRunner/$CONFIGURATION-iphoneos/TestRunner.xcarchive" \
archive \
-quiet
popd

checkpoint "Exporting TestRunner"
xcodebuild \
-exportArchive \
-archivePath "$WORKSPACE/cmake-build/tests/TestRunner/$CONFIGURATION-iphoneos/TestRunner.xcarchive" \
-exportPath "$WORKSPACE/cmake-build/tests/TestRunner/$CONFIGURATION-iphoneos" \
-exportOptionsPlist "$WORKSPACE/cmake/ExportOptions.plist"

cp "$WORKSPACE/cmake-build/tests/TestRunner/$CONFIGURATION-iphoneos/TestRunner.ipa" "$DIST_DIR"

checkpoint "Finished building TestRunner application - $DIST_DIR/TestRunner.ipa"
