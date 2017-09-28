# Attach JS Debugger on Run from Xcode
1. `cd src/debugging`
2. `./launch-proxy.sh`
3. In Xcode add `--nativescript-debug-brk` command line arg in the app scheme of the NativeScript application to be debugged
4. Launch the application with Xcode and (within the 30 seconds timeout for the frontend to attach) open one of the following:


### In {N} inspector application:
* Launch `src/debugging/Inspector/Inspector` application with arguments: `full-path-to-src/debugging/WebInspectorUI/Main.html '{N} Debugger'`

###### For currently unknown reasons you may start receiving error ***Unable to connect error 36*** when launching the application. Restarting the iOS simulator can solve the issue.

### In Chrome DevTools:
* Paste `chrome-devtools://devtools/remote/serve_file/@02e6bde1bbe34e43b309d4ef774b1168d25fd024/inspector.html?experiments=true&ws=localhost:8080` in the address bar

`02e6bde1bbe34e43b309d4ef774b1168d25fd024` is the [SHA of Chromium commit](https://chromium.googlesource.com/chromium/src.git/+/02e6bde1bbe34e43b309d4ef774b1168d25fd024) for the currently tested vesion of Chrome (55.0.2883.100). When we upgrade the [tools version used by CLI](https://github.com/NativeScript/nativescript-cli/blob/0b89d3efe4630feb3270babf6294857bac93bee5/lib/services/debug-service-base.ts#L37) we will need to accordingly change it.

### In Safari:

* Open `WebInspectorUI/Main.html` in latest Safari version

[***Safari 11***] Ensure that ***Disable local file restrictions*** option is turned on in the ***Develop*** menu.
###### Note that if you've just updated the WebKit version even the   [Safari Technology Preview version](https://developer.apple.com/safari/download/) may be missing some features used by the frontend. [The latest nightly WebKit version](https://webkit.org/nightly/archives/) that uses that specific JavaScriptCore must be used in this case. Updating and re-building `src/debugging/Inspector/Inspector` application should always work as well.

#To run in Google Chrome:

```shell
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome dist/WebInspectorUI/Chrome/Main.html --allow-file-access-from-files -incognito
```

