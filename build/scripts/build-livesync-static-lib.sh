#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

checkpoint "Building TKLiveSync.framework"

pushd "$WORKSPACE/plugins/TKLiveSync"

rm -rf "build"

pod install

xcodebuild \
    -workspace "./TKLiveSync.xcworkspace" \
    -scheme "TKLiveSync" \
    -configuration "Release" \
    -sdk "iphonesimulator" \
    build \
    CONFIGURATION_BUILD_DIR="$(pwd)/build/Release-iphonesimulator" \
    ARCHS="i386 x86_64" VALID_ARCHS="i386 x86_64" \
    -quiet

xcodebuild \
    -workspace "./TKLiveSync.xcworkspace" \
    -scheme "TKLiveSync" \
    -configuration "Release" \
    -sdk "iphoneos" \
    build \
    CONFIGURATION_BUILD_DIR="$(pwd)/build/Release-iphoneos" \
    ARCHS="armv7 arm64" VALID_ARCHS="armv7 arm64" \
    -quiet

checkpoint "Packaging TKLiveSync.framework"
mkdir -p "$WORKSPACE/dist/TKLiveSync/"
cp -r "build/Release-iphoneos/TKLiveSync.framework/Headers" "$WORKSPACE/dist/TKLiveSync"
mv "$WORKSPACE/dist/TKLiveSync/Headers" "$WORKSPACE/dist/TKLiveSync/include"
lipo -create -output "$WORKSPACE/dist/TKLiveSync/TKLiveSync" \
    "build/Release-iphonesimulator/TKLiveSync.framework/TKLiveSync" \
    "build/Release-iphoneos/TKLiveSync.framework/TKLiveSync"
chmod +x "$WORKSPACE/dist/TKLiveSync/TKLiveSync"

popd
checkpoint "Finished building TKLiveSync - $WORKSPACE/dist/TKLiveSync"
