#!/bin/bash

JSC_HEADERS_SOURCE_PATH=./dist/jsc/Production-iphoneos/usr/local/include
JSC_HEADERS_DEST_PATH=./dist/jsc/include

# Copy JavaScriptCode headers in JavaScriptCore folder
cp -rfp $JSC_HEADERS_SOURCE_PATH/ $JSC_HEADERS_DEST_PATH/JavaScriptCore

# Move wtf/ folder outside JavaScriptCore/ folder
cp -rp $JSC_HEADERS_DEST_PATH/JavaScriptCore/wtf $JSC_HEADERS_DEST_PATH
rm -rf $JSC_HEADERS_DEST_PATH/JavaScriptCore/wtf

# make yarr folder and copy all Yarr*.h headers in it
mkdir $JSC_HEADERS_DEST_PATH/JavaScriptCore/yarr
for f in $JSC_HEADERS_DEST_PATH/JavaScriptCore/Yarr*.h; 
do
	BASENAME="${f##*/}"
	cp -p "$f" "$JSC_HEADERS_DEST_PATH/JavaScriptCore/yarr/$BASENAME";
done

# replace "#include <heap/Strong.h>" with #include "Strong.h" in ScriptArguments.h
sed -i '' '35s/.*/#include "Strong.h"/' $JSC_HEADERS_DEST_PATH/JavaScriptCore/ScriptArguments.h