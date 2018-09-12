#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

checkpoint "tns-ios-inspector started"

PACKAGE_DIR="$DIST_DIR/inspector-package"

mkdir -p "$PACKAGE_DIR"
cp -R -a "$BINARIES_DIR/NativeScript Inspector HighSierra.zip" "$PACKAGE_DIR"
unzip -q "$BINARIES_DIR/WebInspectorUI.zip" -d "$PACKAGE_DIR"
cp -r "$WORKSPACE/build/npm/inspector_package.json" "$PACKAGE_DIR/package.json"

python "$WORKSPACE/build/scripts/update-version.py" "$PACKAGE_DIR/package.json"

pushd "$PACKAGE_DIR"
npm pack .
popd

VERSION=$(python "$WORKSPACE/build/scripts/get_version.py" "$PACKAGE_DIR/package.json" 2>&1)
IFS=';' read -ra VERSION_ARRAY <<< "$VERSION"
checkpoint "tns-ios-inspector finished - $PACKAGE_DIR/tns-ios-inspector-${VERSION_ARRAY[0]}.tgz"
