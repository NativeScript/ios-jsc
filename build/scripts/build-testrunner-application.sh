#!/usr/bin/env bash

set -e
set -o pipefail

source "$(dirname "$0")/common.sh"

CONFIGURATION=$NATIVESCRIPT_XCODE_CONFIGURATION

checkpoint "Building TestRunner application"

./cmake-gen.sh

pushd "$WORKSPACE/cmake-build"

# Define public TestRunner scheme. Xcode schemes is requried for archiving. This can be also done from Xcode GUI. However, CMake 3.1.3 has no support for generating Xcode schemes, so we have to do it manually.
mkdir -p "$NATIVESCRIPT_XCODEPROJ/xcshareddata/xcschemes"
cp "$WORKSPACE/build/TestRunner.xcscheme" "$NATIVESCRIPT_XCODEPROJ/xcshareddata/xcschemes/TestRunner.xcscheme"

xcodebuild \
-configuration "$CONFIGURATION" \
-sdk "iphoneos" \
-scheme "TestRunner" \
ARCHS="armv7 arm64" \
ONLY_ACTIVE_ARCH="NO" \
-project $NATIVESCRIPT_XCODEPROJ \
-quiet \

popd

# Simulate an IPA by zipping TestRunner.app inside a `Payload` directory.
# This way we're avoiding the costy steps of `xcodebuild archive` and `export`.
(
    set -e;
    cd "$WORKSPACE/cmake-build/tests/TestRunner/$CONFIGURATION-iphoneos/";
    mkdir Payload;
    mv TestRunner.app Payload;
    zip -r "$DIST_DIR/TestRunner.ipa" Payload;
    mv Payload/TestRunner.app .
)

checkpoint "Finished building TestRunner application - $DIST_DIR/TestRunner.app"
