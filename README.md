# NativeScript for iOS Runtime

```shell
git clone --recursive git@github.com:NativeScript/ios-runtime.git
```

## Requirements
 - OS X 10.11+
 - [Xcode 8+](https://developer.apple.com/xcode/)
 - [CMake 3.1.3](https://cmake.org/files/v3.1/cmake-3.1.3-Darwin-x86_64.dmg) - Make sure to install the command line tools from the menu.
 - [llvm 3.9](http://www.llvm.org/releases/download.html#3.9.0) - used to build the [metadata generator](https://github.com/NativeScript/ios-metadata-generator) submodule. Be sure to have the folder containing `llvm-config` in `PATH` or make a symlink to in `/usr/local/bin/`.
 - [Automake](https://www.gnu.org/software/automake/) - available in [Homebrew](http://brew.sh) as `automake`.
 - [GNU Libtool](http://www.gnu.org/software/libtool/) - available in [Homebrew](http://brew.sh) as `libtool`.
 - Checkout all git submodules using `git submodule update --init`.

## Local Development
Execute the following commands:
```shell
mkdir "cmake-build" && cd "cmake-build"
cmake .. -G "Xcode"
open "NativeScript.xcodeproj"
```

After you open the newly generated project in Xcode you can run the `TestRunner` target or the `Gameraww` example app.

## Building a Distribution Package
To build the [`tns-ios` npm package](https://www.npmjs.com/package/tns-ios) run `./build/scripts/package-tns-ios.sh` in the **root** of the repository. The package contains the NativeScript Cocoa Framework, the NativeScript CLI template project and the API metadata generator.

To build the [`tns-ios-inspector` npm package](https://www.npmjs.com/package/tns-ios-inspector) run `./build/scripts/package-tns-ios-inspector.sh` in the **root** of the repository. The package contains the Web Inspector frontend.
