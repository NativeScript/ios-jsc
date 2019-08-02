#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

checkpoint "Building TKLiveSync.framework"

pushd "$WORKSPACE/plugins/TKLiveSync"

rm -rf "build"

pod install

export OTHER_CFLAGS='$(inherited) -Wno-implicit-retain-self -Wno-strict-prototypes'

echo "Building TKLiveSync for iphonesimulator"
xcodebuild \
    -workspace "./TKLiveSync.xcworkspace" \
    -scheme "TKLiveSync" \
    -configuration "Release" \
    -sdk "iphonesimulator" \
    build \
    BUILD_DIR="$(pwd)/build" \
    ARCHS="i386 x86_64" VALID_ARCHS="i386 x86_64" \
    -quiet

echo "Building TKLiveSync for iphoneos"
xcodebuild \
    -workspace "./TKLiveSync.xcworkspace" \
    -scheme "TKLiveSync" \
    -configuration "Release" \
    -sdk "iphoneos" \
    build \
    BUILD_DIR="$(pwd)/build" \
    ARCHS="armv7 arm64" VALID_ARCHS="armv7 arm64" \
    -quiet

echo "Building TKLiveSync for Catalyst"
xcodebuild \
    -workspace "./TKLiveSync.xcworkspace" \
    -scheme "TKLiveSync" \
    -configuration "Release" \
    -destination "variant=Mac Catalyst,arch=x86_64" -UseModernBuildSystem=YES \
    build \
    BUILD_DIR="$(pwd)/build" \
    -quiet

checkpoint "Packaging TKLiveSync.xcframework"

rm -rf "$WORKSPACE/dist/TKLiveSync.xcframework"
# suppress GCDWebServer
xcodebuild -create-xcframework -output "$WORKSPACE/dist/TKLiveSync.xcframework" \
    -framework "build/Release-iphonesimulator/TKLiveSync.framework" \
    -framework "build/Release-iphoneos/TKLiveSync.framework" \
    -framework "build/Release-maccatalyst/TKLiveSync.framework"

popd
checkpoint "Finished building TKLiveSync - $WORKSPACE/dist/TKLiveSync"
