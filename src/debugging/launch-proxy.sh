#!/bin/bash

if [ ! -d node_modules ]; then
    echo Installing npm dependencies
    npm install --production
fi

while true; do
    echo Launching WebSocket proxy server
    node debugger-proxy.js
    sleep 5
done
