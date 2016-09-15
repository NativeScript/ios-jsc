#!/usr/bin/env bash

set -e

function checkpoint {
    local delimiter="********************************************************************************"

    echo "$delimiter"
    echo "> $(date +'%T') $1 "
    echo "$delimiter"
}

WORKSPACE=$(pwd)
DIST_DIR="$WORKSPACE/dist"

if [ ! -d "$WORKSPACE/build/scripts" ]; then
    echo "This script must be run from the root of the repository."
    exit 1
fi
