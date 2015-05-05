#!/bin/bash

function generateMetadata {
    ./objc-metadata-generator -isysroot "$SDKROOT" -arch $1 -iphoneos-version-min $IPHONEOS_DEPLOYMENT_TARGET -target arm-apple-darwin -std $GCC_C_LANGUAGE_STANDARD -header-search-paths "$HEADER_SEARCH_PATHS" -framework-search-paths "$FRAMEWORK_SEARCH_PATHS" -output-bin "$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/metadata-$1.bin" -output-umbrella "$BUILT_PRODUCTS_DIR/umbrella-$1.h" 2> "$BUILT_PRODUCTS_DIR/metadata-generation-stderr-$1.txt"
    if [ $? -ne 0 ]; then
    	cat "$BUILT_PRODUCTS_DIR/metadata-generation-$1.txt"
    fi
}

for CURR_ARCH in $ARCHS;
do
echo "Generating metadata for $CURR_ARCH:"
generateMetadata $CURR_ARCH
done