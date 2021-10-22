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
# checkpoint "Building NativeScript.framework - iphonesimulator SDK"
# xcodebuild -configuration $CONFIGURATION \
#            -sdk "iphonesimulator" \
#            -target "NativeScript" \
#            -project $NATIVESCRIPT_XCODEPROJ \
#            BUILD_DIR=$(PWD)/out \
#            SKIP_INSTALL=NO \
#            -quiet

checkpoint "Building NativeScript.framework - iphoneos SDK"
xcodebuild -configuration $CONFIGURATION \
           -sdk "iphoneos" \
           -target "NativeScript" \
           -project $NATIVESCRIPT_XCODEPROJ \
           BUILD_DIR=$(PWD)/out \
           SKIP_INSTALL=NO \
           -quiet

checkpoint "Creating NativeScript.xcframework"
xcodebuild \
    -create-xcframework \
    -framework $(PWD)/out/Release-iphoneos/NativeScript.framework \
    -debug-symbols $(PWD)/out/Release-iphoneos/NativeScript.framework.dSYM \
    -framework $(PWD)/out/Release-iphonesimulator/NativeScript.framework \
    -debug-symbols $(PWD)/out/Release-iphonesimulator/NativeScript.framework.dSYM \
    -output $DIST_DIR/NativeScript.xcframework

# mkdir -p "$DIST_DIR" && pushd "$_"
# cp -r "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphoneos/NativeScript.framework" "."
# rm "NativeScript.framework/NativeScript"

# Strip debug information, dSYM package must be used for debugging and symbolicating
# strip -S "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphonesimulator/NativeScript.framework/NativeScript" \
    # "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphoneos/NativeScript.framework/NativeScript"
# echo "CodeSign $WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphonesimulator/NativeScript.framework/NativeScript"

# /usr/bin/codesign --force --sign - --timestamp=none "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphonesimulator/NativeScript.framework/NativeScript"

# lipo -create -output "NativeScript.framework/NativeScript" \
    # "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphonesimulator/NativeScript.framework/NativeScript" \
    # "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphoneos/NativeScript.framework/NativeScript"

# cp -r "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphoneos/NativeScript.framework.dSYM" "."
# rm "NativeScript.framework.dSYM/Cont/ents/Resources/DWARF/NativeScript"
# lipo -create -output "NativeScript.framework.dSYM/Contents/Resources/DWARF/NativeScript" \
    # "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphonesimulator/NativeScript.framework.dSYM/Contents/Resources/DWARF/NativeScript" \
    # "$WORKSPACE/cmake-build/src/NativeScript/$CONFIGURATION-iphoneos/NativeScript.framework.dSYM/Contents/Resources/DWARF/NativeScript"

# zip -qr NativeScript.framework.dSYM.zip NativeScript.framework.dSYM
# rm -rf NativeScript.framework.dSYM

# popd

checkpoint "Finished building NativeScript.xcframework - $DIST_DIR/NativeScript.xcbframework"
