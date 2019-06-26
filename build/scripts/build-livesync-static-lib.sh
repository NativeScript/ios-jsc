#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

checkpoint "Building TKLiveSync.framework"

pushd "$WORKSPACE/plugins/TKLiveSync"

rm -rf "build"

pod install

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

echo "Building TKLiveSync for UIKit for Mac"
xcodebuild \
    -workspace "./TKLiveSync.xcworkspace" \
    -scheme "TKLiveSync" \
    -configuration "Release" \
    -destination "variant=UIKit for Mac,arch=x86_64" -UseModernBuildSystem=YES \
    build \
    BUILD_DIR="$(pwd)/build" \
    -quiet

checkpoint "Packaging TKLiveSync.xcframework"

rm -rf "$WORKSPACE/dist/TKLiveSync.xcframework"
xcodebuild -create-xcframework -output "$WORKSPACE/dist/TKLiveSync.xcframework" \
    -framework "build/Release-iphonesimulator/TKLiveSync.framework" \
    -framework "build/Release-iphoneos/TKLiveSync.framework" \
    -framework "build/Release-uikitformac/TKLiveSync.framework" 

popd
checkpoint "Finished building TKLiveSync - $WORKSPACE/dist/TKLiveSync"
