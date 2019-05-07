#!/usr/bin/env bash
source ./.build_env_vars.sh

MODULES_DIR=$SRCROOT/internal/Swift-Modules

function DELETE_SWIFT_MODULES_DIR() {
  rm -rf $MODULES_DIR
}

function GEN_MODULEMAP() {
  DERIVED_SOURCES=$DERIVED_FILES_DIR

  if [ -d "$DERIVED_SOURCES" ]; then
    count=`ls $DERIVED_SOURCES/*-Swift.h 2>/dev/null | wc -l`

      if [ $count == 1 ]
      then
          HEADER_PATH=`find $DERIVED_SOURCES -name *-Swift.h`
          DELETE_SWIFT_MODULES_DIR

          mkdir -p $MODULES_DIR
          CONTENT="module nsswiftsupport { \n header \"$HEADER_PATH\" \n export * \n}"
          printf "$CONTENT" > "$MODULES_DIR/module.modulemap"
      else
      echo "NSLD: Swift bridging header '*-Swift.h' not found"
      fi
  else
    echo "NSLD: Derived sources directory not found"
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




