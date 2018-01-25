# iOS Runtime for NativeScript
[![Waffle.io - NativeScript iOS Runtime](https://badge.waffle.io/NativeScript/ios-runtime.svg?columns=In%20Progress)](https://waffle.io/NativeScript/ios-runtime)

Contains the source code for the NativeScript's iOS Runtime. [NativeScript](https://www.nativescript.org/) is a framework which enables developers to write truly native mobile applications for Android and iOS using JavaScript and CSS. Each mobile platform has its own ecosystem and offers completely different development tools and language(s) - Java for Android and Objective C (Swift) for iOS. In order to translate JavaScript code to the corresponding native APIs some kind of proxy mechanism is needed. This is exactly what the "Runtime" parts of NativeScript are responsible for. The iOS Runtime may be thought of as "The Bridge" between the JavaScript and the iOS world. A NativeScript application for iOS is a standard native package (ipa) which besides the JavaScript files embed the runtime as well.


```shell
git clone --recursive git@github.com:NativeScript/ios-runtime.git
```

<!-- TOC depthFrom:2 -->

- [Requirements](#requirements)
- [Architecture Diagram](#architecture-diagram)
- [Local Development](#local-development)
- [Building a Distribution Package](#building-a-distribution-package)
- [Get Help](#get-help)

<!-- /TOC -->


## Requirements
 - OS X 10.11+
 - [Xcode 8+](https://developer.apple.com/xcode/)
 - [CMake 3.3.2](https://cmake.org/files/v3.3/cmake-3.3.2-Darwin-x86_64.dmg) - Make sure to install the command line tools from the menu.
 - [llvm 4.0](http://releases.llvm.org/download.html#4.0.0) - used to build the [metadata generator](https://github.com/NativeScript/ios-metadata-generator) submodule. Be sure to have the folder containing `llvm-config` in `PATH` or make a symlink to in `/usr/local/bin/`.
 - [Automake](https://www.gnu.org/software/automake/) - available in [Homebrew](http://brew.sh) as `automake`.
 - [GNU Libtool](http://www.gnu.org/software/libtool/) - available in [Homebrew](http://brew.sh) as `libtool`.
 - Checkout all git submodules using `git submodule update --init`.

## Architecture Diagram
The NativeScript iOS Runtime architecture can be summarized in the following diagram. 

![iOS Runtime diagram](https://github.com/NativeScript/docs/blob/master/docs/img/ns-runtime-ios.png)

For more details on how it works, read the [documentation](https://docs.nativescript.org/runtimes/ios/overview). 

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

## Get Help
Please, use [github issues](https://github.com/NativeScript/ios-runtime/issues) strictly for [reporting bugs](CONTRIBUTING.md#reporting-bugs) or [requesting features](CONTRIBUTING.md#requesting-new-features). For general questions and support, check out the [NativeScript community forum](https://discourse.nativescript.org/) or ask our experts in [NativeScript community Slack channel](http://developer.telerik.com/wp-login.php?action=slack-invitation).
