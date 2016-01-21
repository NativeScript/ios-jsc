#!/usr/bin/env bash

set -e

WORKSPACE=$(pwd)
BUILD_LOG="$WORKSPACE/build.log"
BUILD_DIR="$WORKSPACE/build"
DIST_DIR="$WORKSPACE/dist"
PACKAGE_DIR="$DIST_DIR/inspector-package"
INSPECTOR_BUILD_OUTPUT_PATH="$WORKSPACE/cmake-build/Inspector"

. "$BUILD_DIR/scripts/build-inspector.sh"

mkdir -p "$PACKAGE_DIR"
cp -r "$WORKSPACE/src/debugging/WebInspectorUI" "$PACKAGE_DIR/WebInspectorUI"
cp -R -a "$INSPECTOR_BUILD_OUTPUT_PATH/NativeScript Inspector.zip" "$PACKAGE_DIR"
cp -r "$BUILD_DIR/npm/inspector_package.json" "$PACKAGE_DIR/package.json"

python "$BUILD_DIR/scripts/update-version.py" "$PACKAGE_DIR/package.json"

pushd "$PACKAGE_DIR" >> "$BUILD_LOG"

npm pack . >> "$BUILD_LOG"

popd >> "$BUILD_LOG"

checkpoint "Inspector packaging finished."