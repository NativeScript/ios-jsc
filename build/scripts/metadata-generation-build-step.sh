#!/bin/bash

function generateMetadata {
    local errorLog="$CONFIGURATION_BUILD_DIR/metadata-generation-stderr-$1.txt"

    ./objc-metadata-generator \
        -isysroot "$SDKROOT" \
        -arch $1 \
        -iphoneos-version-min $IPHONEOS_DEPLOYMENT_TARGET \
        -target arm-apple-darwin \
        -std $GCC_C_LANGUAGE_STANDARD \
        -header-search-paths "$HEADER_SEARCH_PATHS" \
        -framework-search-paths "$FRAMEWORK_SEARCH_PATHS" \
        -enable-header-preprocessing-if-needed=true \
        -output-bin "$CONFIGURATION_BUILD_DIR/metadata-$1.bin" \
        -output-umbrella "$CONFIGURATION_BUILD_DIR/umbrella-$1.h" \
        2> "$errorLog"

    if [ $? -ne 0 ]; then
        cat "$errorLog"
        exit 1
    fi
}

for CURR_ARCH in $ARCHS; do
    echo "Generating metadata for $CURR_ARCH:"
    generateMetadata $CURR_ARCH
done
