#!/usr/bin/env bash

set -e

WORKSPACE=$(pwd)
CONFIGURATION="Release"
MACOSX_DEPLOYMENT_TARGET="10.10"

WEBKIT_SOURCE_PATH="$WORKSPACE/src/webkit"
WEBKIT_BUILD_OUTPUT_PATH="$WORKSPACE/cmake-build/WebKit-Xcode"

INSPECTOR_SOURCE_PATH="$WORKSPACE/src/debugging/Inspector/Inspector"
INSPECTOR_BUILD_OUTPUT_PATH="$WORKSPACE/cmake-build/Inspector"

BUILD_LOG="$WORKSPACE/build.log"

function checkpoint {
    echo "$(date +'%T')" "$1"
}

checkpoint "Inspector build started."
mkdir -p "$WORKSPACE/cmake-build"
rm -f "$BUILD_LOG"

checkpoint "Building WebKit..."
xcodebuild \
    -workspace "$WEBKIT_SOURCE_PATH/WebKit.xcworkspace" \
    -configuration "$CONFIGURATION" \
    -scheme "All Source" \
    -derivedDataPath "$WEBKIT_BUILD_OUTPUT_PATH" \
    VALID_ARCHS="x86_64" ARCHS="x86_64" ONLY_ACTIVE_ARCH="NO" \
    MACOSX_DEPLOYMENT_TARGET="$MACOSX_DEPLOYMENT_TARGET" \
    build \
    >> "$BUILD_LOG" 2>&1

checkpoint "Copying frameworks..."
rm -rf "$INSPECTOR_SOURCE_PATH/Frameworks"
find "$WEBKIT_BUILD_OUTPUT_PATH/Build/Products/$CONFIGURATION" -name "*.framework" -type d -maxdepth 1 -print \
    -exec rsync -a {} "$INSPECTOR_SOURCE_PATH/Frameworks/" \; \
    >> "$BUILD_LOG"

checkpoint "Building Inspector app..."
rm -rf "$INSPECTOR_BUILD_OUTPUT_PATH"
xcodebuild \
    -project "$INSPECTOR_SOURCE_PATH/Inspector.xcodeproj" \
    -scheme "Inspector" \
    -archivePath "$INSPECTOR_BUILD_OUTPUT_PATH/Inspector.xcarchive" \
    MACOSX_DEPLOYMENT_TARGET="$MACOSX_DEPLOYMENT_TARGET" \
    archive \
    >> "$BUILD_LOG" 2>&1
xcodebuild \
    -exportArchive \
    -archivePath "$INSPECTOR_BUILD_OUTPUT_PATH/Inspector.xcarchive" \
    -exportOptionsPlist "$INSPECTOR_SOURCE_PATH/export-options.plist" \
    -exportPath "$INSPECTOR_BUILD_OUTPUT_PATH" \
    >> "$BUILD_LOG" 2>&1

checkpoint "Packaging Inspector app..."
pushd "$INSPECTOR_BUILD_OUTPUT_PATH" \
    >> "$BUILD_LOG"
mv "Inspector.app" "NativeScript Inspector.app"
zip -r \
    --symlinks \
    "NativeScript Inspector.zip" \
    "NativeScript Inspector.app" \
    >> "$BUILD_LOG"
popd \
    >> "$BUILD_LOG"

checkpoint "Inspector build finished."
