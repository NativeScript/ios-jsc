#!/bin/bash

JSC_HEADERS_SOURCE_PATH=./dist/jsc/Production-iphoneos/usr/local/include
JSC_HEADERS_DEST_PATH=./src/NativeScript/deps/include

# Copy JavaScriptCode headers in JavaScriptCore folder
cp -rf $JSC_HEADERS_SOURCE_PATH/ $JSC_HEADERS_DEST_PATH/JavaScriptCore

# Move wtf/ folder outside JavaScriptCore/ folder
mv $JSC_HEADERS_DEST_PATH/JavaScriptCore/wtf $JSC_HEADERS_DEST_PATH

# make yarr folder and move all Yarr*.h headers in it
mkdir $JSC_HEADERS_DEST_PATH/JavaScriptCore/yarr
for f in $JSC_HEADERS_DEST_PATH/JavaScriptCore/Yarr*.h; 
do
	BASENAME="${f##*/}"
	mv "$f" "$JSC_HEADERS_DEST_PATH/JavaScriptCore/yarr/$BASENAME";
done

# replace "#include <heap/Strong.h>" with #include "Strong.h" in ScriptArguments.h
sed -i '' '35s/.*/#include "Strong.h"/' $JSC_HEADERS_DEST_PATH/JavaScriptCore/ScriptArguments.h 