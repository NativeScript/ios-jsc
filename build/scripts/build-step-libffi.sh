#!/usr/bin/env bash

set -euxo pipefail

function build {
    local ARCH=$1
    local BINARY_DIR="build_$PLATFORM_NAME-$ARCH-$CONFIGURATION"


    local TRIPLE
    if [ "$ARCH" == "i386" ]; then
        TRIPLE="i386-apple-darwin11"
    elif [ "$ARCH" == "x86_64" ]; then
        TRIPLE="x86_64-apple-darwin13"
    elif [ "$ARCH" == "armv7" ]; then
        TRIPLE="arm-apple-darwin11"
    elif [ "$ARCH" == "arm64" ]; then
        TRIPLE="aarch64-apple-darwin13"
    else
        echo "Invalid architecture: $ARCH"
        exit 1
    fi

    if [ ! -e ./configure ]; then 
        autoreconf -i
    fi

    mkdir -p "$BINARY_DIR" && pushd "$_"

    local COMPILER_FLAGS="-arch $ARCH -isysroot $SDKROOT -$DEPLOYMENT_TARGET_CLANG_FLAG_NAME=${!DEPLOYMENT_TARGET_CLANG_ENV_NAME}"

    (
        export CC="clang $COMPILER_FLAGS"
        export CXX="clang++ $COMPILER_FLAGS"

        export CFLAGS="-O$GCC_OPTIMIZATION_LEVEL"

        if [ "$GCC_GENERATE_DEBUGGING_SYMBOLS" == "YES" ]; then
            CFLAGS="$CFLAGS -g"
        fi

        if [ ! -e Makefile ]; then
            ./../configure --disable-shared --host="$TRIPLE"
        fi

        make
    )

    popd
}

for CURRENT_ARCH in $ARCHS; do
    build "$CURRENT_ARCH"
done
