#!/bin/sh

xcodebuild \
    -target JavaScriptCore \
    -sdk "$SDKROOT" \
    -configuration $CONFIGURATION \
    ARCHS="$ARCHS" ONLY_ACTIVE_ARCH=$ONLY_ACTIVE_ARCH \
    GCC_GENERATE_DEBUGGING_SYMBOLS=$GCC_GENERATE_DEBUGGING_SYMBOLS
