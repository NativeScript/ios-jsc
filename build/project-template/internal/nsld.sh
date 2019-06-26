#!/usr/bin/env bash
source ./.build_env_vars.sh

MODULES_DIR=$SRCROOT/internal/Swift-Modules

function DELETE_SWIFT_MODULES_DIR() {
    rm -rf $MODULES_DIR
}

function GEN_MODULEMAP() {
    SWIFT_HEADER_DIR=$PER_VARIANT_OBJECT_FILE_DIR

    DELETE_SWIFT_MODULES_DIR
    if [ -d "$SWIFT_HEADER_DIR" ]; then
        HEADERS_PATHS=$(find $SWIFT_HEADER_DIR -name *-Swift.h 2>/dev/null)
        if [ -n "$HEADERS_PATHS" ]; then
            # Workaround for ARCH being set to `undefined_arch` here. Get the newest -Swift.h
            # if more than one is found. It should be the one for the current architecture.
            HEADER_PATH=$(ls -t $HEADERS_PATHS | head -n 1)
            mkdir -p $MODULES_DIR
            CONTENT="module nsswiftsupport { \n header \"$HEADER_PATH\" \n export * \n}"
            printf "$CONTENT" > "$MODULES_DIR/module.modulemap"
        else
            echo "NSLD: Swift bridging header '*-Swift.h' not found under $SWIFT_HEADER_DIR"
        fi
    else
        echo "NSLD: Directory for Swift headers ($SWIFT_HEADER_DIR) not found."
    fi
}

function GEN_METADATA() {
    set -e

    pushd "$SRCROOT/internal/metadata-generator/bin"
    ./build-step-metadata-generator.py
    popd
}

GEN_MODULEMAP
printf "Generating metadata..."
GEN_METADATA
DELETE_SWIFT_MODULES_DIR
NS_LD="${NS_LD:-"$TOOLCHAIN_DIR/usr/bin/clang"}"
$NS_LD "$@"
