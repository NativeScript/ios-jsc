#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

CONFIGURATION=$NATIVESCRIPT_XCODE_CONFIGURATION

checkpoint "Building NativeScript.framework"

mkdir -p "$WORKSPACE/cmake-build" && pushd "$_"
# Delete the CMake cache because a previous build could have generated the runtime with a static library.
rm -f "CMakeCache.txt"
cmake .. -G"Xcode" -D"BUILD_SHARED_LIBS=ON"
# TODO: fix build when iphoneos build is started first
checkpoint "Building NativeScript.framework - iphonesimulator SDK"
xcodebuild -configuration $CONFIGURATION -sdk "iphonesimulator" -target "NativeScript" -quiet
checkpoint "Building NativeScript.framework - iphoneos SDK"
xcodebuild -configuration $CONFIGURATION -sdk "iphoneos" -target "NativeScript" -quiet
popd

checkpoint "Packaging NativeScript.framework"
mkdir -p "$DIST_DIR" && pushd "$_"
cp -r "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphoneos/NativeScript.framework" "."
rm "NativeScript.framework/NativeScript"

# Strip debug information, dSYM package must be used for debugging and symbolicating
strip -S "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphonesimulator/NativeScript.framework/NativeScript" \
    "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphoneos/NativeScript.framework/NativeScript"
echo "CodeSign $WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphonesimulator/NativeScript.framework/NativeScript"

/usr/bin/codesign --force --sign - --timestamp=none "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphonesimulator/NativeScript.framework/NativeScript"

lipo -create -output "NativeScript.framework/NativeScript" \
    "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphonesimulator/NativeScript.framework/NativeScript" \
    "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphoneos/NativeScript.framework/NativeScript"

cp -r "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphoneos/NativeScript.framework.dSYM" "."
rm "NativeScript.framework.dSYM/Contents/Resources/DWARF/NativeScript"
lipo -create -output "NativeScript.framework.dSYM/Contents/Resources/DWARF/NativeScript" \
    "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphonesimulator/NativeScript.framework.dSYM/Contents/Resources/DWARF/NativeScript" \
    "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphoneos/NativeScript.framework.dSYM/Contents/Resources/DWARF/NativeScript"

zip -qr NativeScript.framework.dSYM.zip NativeScript.framework.dSYM
rm -rf NativeScript.framework.dSYM

popd

checkpoint "Finished building NativeScript.framework - $DIST_DIR/NativeScript.framework"
