#!/usr/bin/env bash

# This script is added as a run script phase in the CMake generated Xcode project.
# Environment variables are provided by Xcode during build.
# See the WebKit.cmake configuration file for more info.
DESTINATION_ARG=""
if [ $(echo $IS_UIKITFORMAC | tr '[:upper:]' '[:lower:]') = "yes" -o $(echo $IS_UIKITFORMAC | tr '[:upper:]' '[:lower:]') = "true" -o "$IS_UIKITFORMAC" = "1" ]; then
    # Add compiler flags for "UIKit for Mac". See https://github.com/CocoaPods/CocoaPods/issues/8877#issuecomment-499752865
    # Taken from the output of `xcodebuild -scheme JavaScriptCore -showdestinations`
    DESTINATION_ARGS=(-destination "variant=UIKit for Mac,arch=x86_64" -UseModernBuildSystem=YES)
else
    DESTINATION_ARGS=(-sdk "$SDKROOT")
fi

xcodebuild build -scheme JavaScriptCore \
    "${DESTINATION_ARGS[@]}" \
    -configuration "$CONFIGURATION" \
    ARCHS="$ARCHS" \
    ONLY_ACTIVE_ARCH="$ONLY_ACTIVE_ARCH" \
    $DEPLOYMENT_TARGET_SETTING_NAME="${!DEPLOYMENT_TARGET_CLANG_ENV_NAME}" \
    GCC_WARN_INHIBIT_ALL_WARNINGS="YES" \
