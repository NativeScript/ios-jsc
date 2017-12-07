#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

checkpoint "tns-ios started"

PACKAGE_DIR="$DIST_DIR/package"
FRAMEWORK_DIR="$PACKAGE_DIR/framework"
INTERNAL_DIR="$FRAMEWORK_DIR/internal"

mkdir -p "$INTERNAL_DIR"

"$WORKSPACE/build/scripts/build-livesync-static-lib.sh"
cp -R "$DIST_DIR/TKLiveSync" "$INTERNAL_DIR"

"$WORKSPACE/build/scripts/build-nativescript-framework.sh"
cp -R "$DIST_DIR/NativeScript.framework" "$INTERNAL_DIR/NativeScript.framework"

"$WORKSPACE/build/scripts/build-metadata-generator.sh"
cp -R "$DIST_DIR/metadataGenerator" "$INTERNAL_DIR/metadata-generator"

sed 's/#import <NativeScript.h>/#import <NativeScript\/NativeScript.h>/g' "$WORKSPACE/src/debugging/TNSDebugging.h" > "$INTERNAL_DIR/TNSDebugging.h"
sed 's/#import <NativeScript.h>/#import <NativeScript\/NativeScript.h>/g' "$WORKSPACE/src/NativeScript/ObjC/TNSExceptionHandler.h" > "$INTERNAL_DIR/TNSExceptionHandler.h"

cp -R "$WORKSPACE/build/project-template/" "$FRAMEWORK_DIR"
cp -R "$WORKSPACE/README.md" "$PACKAGE_DIR"

cp -R "$WORKSPACE/build/npm/runtime_package.json" "$PACKAGE_DIR/package.json"
python "$WORKSPACE/build/scripts/update-version.py" "$PACKAGE_DIR/package.json"

pushd "$DIST_DIR"
npm pack ./package
popd

VERSION=$(python "$WORKSPACE/build/scripts/get_version.py" "$PACKAGE_DIR/package.json" 2>&1)
IFS=';' read -ra VERSION_ARRAY <<< "$VERSION"
checkpoint "tns-ios finished - $DIST_DIR/tns-ios-${VERSION_ARRAY[0]}.tgz"
