#!/usr/bin/env bash

# This script is added as a run script phase in the CMake generated Xcode project.
# Environment variables are provided by Xcode during build.
# See the WebKit.cmake configuration file for more info.
xcodebuild -target JavaScriptCore \
    -sdk "$SDKROOT" \
    -configuration "$CONFIGURATION" \
    ARCHS="$ARCHS" \
    ONLY_ACTIVE_ARCH="$ONLY_ACTIVE_ARCH" \
    $DEPLOYMENT_TARGET_SETTING_NAME="${!DEPLOYMENT_TARGET_CLANG_ENV_NAME}" \
    GCC_WARN_INHIBIT_ALL_WARNINGS="YES"
