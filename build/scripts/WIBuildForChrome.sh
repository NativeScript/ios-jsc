#!/bin/bash

SRC_PATH=.
WI_PATH=$SRC_PATH/src/debugging/WebInspectorUI
DIST_PATH=$SRC_PATH/dist/WebInspectorUI
CHROME_PATH=$DIST_PATH/Chrome
SCRIPT_PATH=$SRC_PATH/build/scripts

# copy the WebInspector version built for Safari
mkdir -p $CHROME_PATH
cp -rf $WI_PATH/ $CHROME_PATH/

# run babel compiler for all inspector sources except External and Images directory
$SRC_PATH/node_modules/babel/bin/babel/index.js $CHROME_PATH --ignore $CHROME_PATH/External, $CHROME_PATH/Images --out-dir $CHROME_PATH --blacklist strict

# copy the polyfills file in chrome folder
cp $SRC_PATH/src/debugging/polyfills.js $CHROME_PATH/polyfills.js

# include the necessary <script> tag in Main.html on some hardcoded line number
sed -i '' '161s/.*/	<script src="polyfills.js"><\/script>/' $CHROME_PATH/Main.html