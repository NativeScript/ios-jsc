#!/usr/bin/env bash

set -e

WORKSPACE=`pwd`

echo "Building TKLiveSync.framework..."

pushd "$WORKSPACE/plugins/TKLiveSync"

rm -rf "build"

pod install

echo -e "\tiPhoneSimulator..."
xcodebuild -workspace "TKLiveSync.xcworkspace" \
    -scheme "TKLiveSync" \
    -configuration "Release" \
    -sdk "iphonesimulator" \
    build \
    CONFIGURATION_BUILD_DIR="$(pwd)/build/Release-iphonesimulator" \
    ARCHS="i386 x86_64" VALID_ARCHS="i386 x86_64"

echo -e "\tiPhoneOS..."
xcodebuild -workspace "TKLiveSync.xcworkspace" \
    -scheme "TKLiveSync" \
    -configuration "Release" \
    -sdk "iphoneos" \
    build \
    CONFIGURATION_BUILD_DIR="$(pwd)/build/Release-iphoneos" \
    ARCHS="armv7 arm64" VALID_ARCHS="armv7 arm64"

echo "Packaging TKLiveSync.framework..."
mkdir -p "$WORKSPACE/dist"
cp -r "build/Release-iphoneos/TKLiveSync.framework" "$WORKSPACE/dist"
rm "$WORKSPACE/dist/TKLiveSync.framework/TKLiveSync"
lipo -create -output "$WORKSPACE/dist/TKLiveSync.framework/TKLiveSync" \
    "build/Release-iphonesimulator/TKLiveSync.framework/TKLiveSync" \
    "build/Release-iphoneos/TKLiveSync.framework/TKLiveSync"

popd
echo "Finished building TKLiveSync."
