#!/bin/bash
set -e
cd libzip_iOS/cmake-build

echo "Building libzip_iOS for iphonesimulator"
xcodebuild -scheme "libzip_iOS" \
    -configuration "Release" \
    -sdk "iphonesimulator" \
    BUILD_DIR="$PWD/xcframework-build" \
    ARCHS="i386 x86_64" \
    VALID_ARCHS="i386 x86_64" \
    -quiet

echo "Building libzip_iOS for iphoneos"
xcodebuild -scheme "libzip_iOS" \
    -configuration "Release" \
    -sdk "iphoneos" \
    BUILD_DIR="$PWD/xcframework-build" \
    ARCHS="armv7 arm64" \
    VALID_ARCHS="armv7 arm64" \
    -quiet

echo "Building libzip_iOS for UIKit for Mac"
xcodebuild -scheme "libzip_iOS" \
    -configuration "Release" \
    -destination "variant=UIKit for Mac,arch=x86_64" \
    -UseModernBuildSystem=YES \
    BUILD_DIR="$PWD/xcframework-build" \
    -quiet

echo "Packaging libzip_iOS.xcframework"
rm -rf ../../libzip_iOS.xcframework
xcodebuild -create-xcframework \
    -framework "xcframework-build/Release-iphoneos/libzip_iOS.framework" \
    -framework "xcframework-build/Release-iphonesimulator/libzip_iOS.framework" \
    -framework "xcframework-build/Release-uikitformac/libzip_iOS.framework" \
    -output "../../libzip_iOS.xcframework" \
