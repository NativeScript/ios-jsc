#!/bin/sh

export SRCROOT=$PWD
export InspectorScripts=$PWD/../../../webkit/Source/JavaScriptCore/inspector/scripts
# export CREATE_HASH_TABLE="$SRCROOT/create_hash_table"
# export CREATE_REGEXP_TABLES="$SRCROOT/create_regex_tables"
# export CREATE_KEYWORD_LOOKUP="$SRCROOT/KeywordLookupGenerator.py"

# mkdir -p DerivedSources/JavaScriptCore
# cd DerivedSources/JavaScriptCore

echo $InspectorScripts
PYTHONPATH=$InspectorScripts python $SRCROOT/generate_typescript_interfaces.py

# make -f ../../DerivedSources.make JavaScriptCore=../.. BUILT_PRODUCTS_DIR=../..
# cd ../..
