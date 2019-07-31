#!/usr/bin/env bash
source ./.build_env_vars.sh

MODULES_DIR="$SRCROOT/internal/Swift-Modules"

function DELETE_SWIFT_MODULES_DIR() {
    rm -rf "$MODULES_DIR"
}

function getArch() {
    while [[ $# -gt 0 ]]
    do
        case $1 in
            -arch)
                printf $2
                return
                ;;
            -target)
                printf `echo $2 | cut -f1 -d'-'`
                return
                ;;
        esac
        shift
    done
}

function GEN_MODULEMAP() {
    ARCH_ARG=$1
    SWIFT_HEADER_DIR=$PER_VARIANT_OBJECT_FILE_DIR/$ARCH_ARG

    DELETE_SWIFT_MODULES_DIR
    if [ -d "$SWIFT_HEADER_DIR" ]; then
        HEADER_PATH=$(find "$SWIFT_HEADER_DIR" -name '*-Swift.h' 2>/dev/null)
        if [ -n "$HEADER_PATH" ]; then
            mkdir -p "$MODULES_DIR"
            CONTENT="module nsswiftsupport { \n header \"$HEADER_PATH\" \n export * \n}"
            printf "$CONTENT" > "$MODULES_DIR/module.modulemap"
        else
            echo "NSLD: Swift bridging header '*-Swift.h' not found under '$SWIFT_HEADER_DIR'"
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

# Workaround for ARCH being set to `undefined_arch` here. Extract it from command line arguments.
GEN_MODULEMAP $(getArch "$@")
printf "Generating metadata..."
GEN_METADATA
DELETE_SWIFT_MODULES_DIR
NS_LD="${NS_LD:-"$TOOLCHAIN_DIR/usr/bin/clang"}"
$NS_LD "$@"
