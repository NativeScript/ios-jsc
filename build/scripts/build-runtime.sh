#!/usr/bin/env bash

set -e

WORKSPACE=$(pwd)
BUILD_DIR="$WORKSPACE/build"
BUILD_LOG="$WORKSPACE/build.log"
DIST_DIR="$WORKSPACE/dist"
PACKAGE_DIR="$DIST_DIR/package"
FRAMEWORK_DIR="$PACKAGE_DIR/framework"
INTERNAL_DIR="$FRAMEWORK_DIR/internal"

. "$WORKSPACE/build/scripts/build.sh"

mkdir -p "$INTERNAL_DIR/NativeScript/Frameworks"

cp -R "$DIST_DIR/NativeScript/" "$INTERNAL_DIR/NativeScript"
cp -R "$DIST_DIR/NativeScript.framework" "$INTERNAL_DIR/NativeScript/Frameworks"
cp -R "$WORKSPACE/src/debugging/TNSDebugging.h" "$INTERNAL_DIR"
cp -R "$WORKSPACE/src/NativeScript/ObjC/TNSExceptionHandler.h" "$INTERNAL_DIR"
cp -R "$DIST_DIR/metadataGenerator" "$INTERNAL_DIR/metadata-generator"
cp -R "$BUILD_DIR/project-template/" "$FRAMEWORK_DIR"
cp -R "$BUILD_DIR/npm/runtime_package.json" "$PACKAGE_DIR/package.json"

python "$BUILD_DIR/scripts/update-version.py" "$PACKAGE_DIR/package.json"

pushd "$DIST_DIR" >> "$BUILD_LOG"

echo "Packaging..."
npm pack "package" >> "$BUILD_LOG"

popd >> "$BUILD_LOG"