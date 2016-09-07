# NativeScript for iOS Runtime

```shell
git clone --recursive git@github.com:NativeScript/ios-runtime.git
```

## Requirements
 - OS X 10.11+
 - [Xcode 7+](https://developer.apple.com/xcode/)
 - [CMake 3.1.3](https://cmake.org/files/v3.1/cmake-3.1.3-Darwin-x86_64.dmg) - Make sure to install the command line tools from the menu.
 - [llvm 3.9](http://www.llvm.org/releases/download.html#3.9.0) - used to build the [metadata generator](https://github.com/NativeScript/ios-metadata-generator) submodule. Be sure to have `llvm-config` in `PATH` or otherwise export the `LLVM_CONFIG_PATH` environment variable to point to the folder that contains it.
 - [Automake](https://www.gnu.org/software/automake/) - available in [Homebrew](http://brew.sh) as `automake`
 - [GNU Libtool](http://www.gnu.org/software/libtool/) - available in [Homebrew](http://brew.sh) as `libtool`

## Building
Run `build/scripts/build.sh` in the root of the repository. This will produce a Cocoa Framework versions of the iOS runtime and a build of the metadata generator and place them in the `dist` folder. The script depends on the repo's git submodules, so if you run into issues make sure to update them using `git submodule update --init`.

## Creating an Xcode Project
```shell
mkdir cmake-build && cd cmake-build
cmake .. -G Xcode
```

## NPM Package

To build the npm package run ```sh build/scripts/build-runtime.sh``` in the **root** of the repository. This should produce a `dist/tns-ios-*.tgz` file, which should contain the NativeScript Cocoa Framework, the NativeScript CLI template project, the API metadata generator and the Web Inspector frontend.

## Tests
To run the tests build and run the TestRunner target from the generated Xcode project as described above.
