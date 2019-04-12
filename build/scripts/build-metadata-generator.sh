#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

checkpoint "Building metadata-generator"

mkdir -p "$WORKSPACE/cmake-build"
./cmake-gen.sh
xcodebuild -configuration "Release" -target "MetadataGenerator" -project $NATIVESCRIPT_XCODEPROJ -quiet

checkpoint "Packaging metadata-generator"
mkdir -p "$DIST_DIR" && pushd "$_"
rm -rf metadataGenerator
cp -R "$WORKSPACE/cmake-build/metadataGenerator" "."
cp "$WORKSPACE/build/scripts/build-step-metadata-generator.py" "metadataGenerator/bin/"
popd

checkpoint "Finished building metadata-generator - $DIST_DIR/metadataGenerator"
