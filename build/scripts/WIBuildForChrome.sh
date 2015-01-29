#!/bin/bash

SRC_PATH=.
WI_PATH=$SRC_PATH/dist/WebInspectorUI
SAFARI_PATH=$WI_PATH/Safari
CHROME_PATH=$WI_PATH/Chrome
SCRIPT_PATH=$SRC_PATH/build/scripts

# copy the WebInspector version built for Safari
cp -rf $SAFARI_PATH/. $CHROME_PATH/

# run traceur compiler for every *.js file in chrome folder
FILES=$(find $CHROME_PATH -type f -name "*.js")
for f in $FILES
do
	echo ${f#$CHROME_PATH}
	$SRC_PATH/node_modules/traceur/traceur --script $f --out $f 
done

# copy the traceur runtime file in chrome folder
cp $SRC_PATH/node_modules/traceur/bin/traceur-runtime.js $CHROME_PATH/traceur-runtime.js

# include the necessary <script> tag in Main.html on some hardcoded line number
sed -i '' '143s/.*/	<script src="traceur-runtime.js"><\/script>/' $CHROME_PATH/Main.html