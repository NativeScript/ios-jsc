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

# Define public TestRunner scheme. Xcode schemes is requried for archiving. This can be also done from Xcode GUI. However, CMake 3.1.3 has no support for generating Xcode schemes, so we have to do it manually.
mkdir -p "$WORKSPACE/cmake-build/NativeScript.xcodeproj/xcshareddata/xcschemes"
cp "$WORKSPACE/build/TestRunner.xcscheme" "$WORKSPACE/cmake-build/NativeScript.xcodeproj/xcshareddata/xcschemes/TestRunner.xcscheme"

xcodebuild \
-configuration "$CONFIGURATION" \
-sdk "iphoneos" \
-scheme "TestRunner" \
ARCHS="armv7 arm64" \
ONLY_ACTIVE_ARCH="NO" \
 -quiet

xcodebuild archive \
-archivePath "$WORKSPACE/cmake-build/tests/TestRunner/$CONFIGURATION-iphoneos/TestRunner.xcarchive" \
-configuration "$CONFIGURATION" \
-sdk "iphoneos" \
-scheme "TestRunner" \
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
