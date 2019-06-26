#!/usr/bin/env bash

set -e

source "$(dirname "$0")/common.sh"

CONFIGURATION=$NATIVESCRIPT_XCODE_CONFIGURATION

checkpoint "Building NativeScript.framework"

mkdir -p "$WORKSPACE/cmake-build"
# Delete the CMake cache because a previous build could have generated the runtime with a static library.
rm -f "$WORKSPACE/cmake-build/CMakeCache.txt"
./cmake-gen.sh

# Due to the regeneration of JSC's low level interpreter when changing
# building target between device/simulator, this order is important for
# the performance of Jenkins builds. After building the {N} framework, we
# build TestRunner for device and thus, it is best to build NativeScript.framework
# for device last.
checkpoint "Building NativeScript.framework - UIKit for Mac"
xcodebuild -configuration $CONFIGURATION -destination "variant=UIKit for Mac,arch=x86_64" -scheme "NativeScript" -project $NATIVESCRIPT_XCODEPROJ -quiet
checkpoint "Building NativeScript.framework - iphonesimulator SDK"
xcodebuild -configuration $CONFIGURATION -sdk "iphonesimulator" -scheme "NativeScript" -project $NATIVESCRIPT_XCODEPROJ -quiet
checkpoint "Building NativeScript.framework - iphoneos SDK"
xcodebuild -configuration $CONFIGURATION -sdk "iphoneos"        -scheme "NativeScript" -project $NATIVESCRIPT_XCODEPROJ -quiet

checkpoint "Creating NativeScript.xcframework"

mkdir -p "$DIST_DIR" && pushd "$_"

SRC_SIMULATOR="$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphonesimulator/NativeScript.framework"
SRC_IPHONEOS="$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphoneos/NativeScript.framework"
SRC_MACOS="$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-uikitformac/NativeScript.framework"
XCFRAMEWORK_PATH="$DIST_DIR/NativeScript.xcframework"
IOS_DSYM="$DIST_DIR/NativeScript.ios.framework.dSYM"
MACOS_DSYM="$DIST_DIR/NativeScript.macos.framework.dSYM"

# Strip debug information, dSYM package must be used for debugging and symbolicating
strip -S "$SRC_SIMULATOR/NativeScript" "$SRC_IPHONEOS/NativeScript" # "$SRC_MACOS/NativeScript" # don't strip macos binary for now 

rm -rf $XCFRAMEWORK_PATH
xcodebuild -create-xcframework -framework "$SRC_IPHONEOS" -framework "$SRC_SIMULATOR" -framework "$SRC_MACOS" -output "$XCFRAMEWORK_PATH"

checkpoint "Creating dSYM packages"

cp -r $SRC_IPHONEOS.dSYM $IOS_DSYM
rm "$IOS_DSYM/Contents/Resources/DWARF/NativeScript"

lipo -create -output "$IOS_DSYM/Contents/Resources/DWARF/NativeScript" \
    "$SRC_SIMULATOR.dSYM/Contents/Resources/DWARF/NativeScript" \
    "$SRC_IPHONEOS.dSYM/Contents/Resources/DWARF/NativeScript"

echo "Archiving iOS dSYM at $IOS_DSYM.zip"
(cd $DIST_DIR && zip -qr NativeScript.ios.framework.dSYM.zip NativeScript.ios.framework.dSYM && rm -rf NativeScript.ios.framework.dSYM)

echo "TODO: Copying macOS dSYM at $MACOS_DSYM"
# cp -r $SRC_MACOS.dSYM $MACOS_DSYM

echo "TODO: Archiving macOS dSYM at $MACOS_DSYM.zip"
# (cd $DIST_DIR && zip -qr NativeScript.macos.framework.dSYM.zip NativeScript.macos.framework.dSYM)

popd

checkpoint "Finished building NativeScript.framework - $DIST_DIR/NativeScript.framework"
