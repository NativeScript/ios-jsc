#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

checkpoint "Building metadata-generator"

mkdir -p "$WORKSPACE/cmake-build" && pushd "$_"
cmake .. -G"Xcode"
xcodebuild -configuration "Release" -target "MetadataGenerator" -quiet
popd

checkpoint "Packaging metadata-generator"
mkdir -p "$DIST_DIR" && pushd "$_"
cp -R "$WORKSPACE/cmake-build/metadataGenerator" "."
cp "$WORKSPACE/build/scripts/build-step-metadata-generator.py" "metadataGenerator/bin/"
popd

checkpoint "Finished building metadata-generator - $DIST_DIR/metadataGenerator"
