# NativeScript for iOS Runtime

```shell
git clone --recursive git@github.com:NativeScript/ios-runtime.git
```

## Requirements
 - OSX 10.10.3+
 - Xcode 6.3+
 - [cmake](http://www.cmake.org/) - It is available in [Homebrew](http://brew.sh) as `cmake`.
 - [llvm 3.7](http://www.llvm.org/releases/download.html#3.7.0) - used to build the [metadata generator](https://github.com/NativeScript/ios-metadata-generator) submodule. Be sure to have `llvm-config` in PATH or otherwise export the `LLVM_CONFIG_PATH` environment variable to point to the folder that contains it.

## Building
Run `build/scripts/build.sh` in the root of the repository. This will produce a static library and Cocoa Framework versions of the iOS runtime and a build of the metadata generator and place them in the `dist` folder. The script depends on the repo's git submodules, so if you run into issues make sure to update them using `git submodule update --init`.

## Creating an Xcode Project
```shell
mkdir cmake-build && cd cmake-build
cmake .. -G Xcode
```

## NPM Package
The `tns-ios` package is built with grunt. Install `grunt-cli` with npm and then run `npm install .` in the root of the repo to install the local grunt dependencies.

To build the npm package run `grunt package` in the **root** of the repo. This should produce a `dist/tns-ios-*.tgz` file, which should contain the NativeScript static library and Cocoa Framework, the NativeScript CLI template project, the API metadata generator and the Web Inspector frontend.

## Tests
To run the tests build and run the TestRunner target from the generated Xcode project as described above.
