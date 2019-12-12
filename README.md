# iOS Runtime for NativeScript

Contains the source code for the NativeScript's iOS Runtime. [NativeScript](https://www.nativescript.org/) is a framework which enables developers to write truly native mobile applications for Android and iOS using JavaScript and CSS. Each mobile platform has its own ecosystem and offers completely different development tools and language(s) - Java for Android and Objective C (Swift) for iOS. In order to translate JavaScript code to the corresponding native APIs some kind of proxy mechanism is needed. This is exactly what the "Runtime" parts of NativeScript are responsible for. The iOS Runtime may be thought of as "The Bridge" between the JavaScript and the iOS world. A NativeScript application for iOS is a standard native package (ipa) which besides the JavaScript files embed the runtime as well.

```shell
git clone --recursive git@github.com:NativeScript/ios-runtime.git
```

<!-- TOC depthFrom:2 -->

- [Requirements](#requirements)
- [Architecture Diagram](#architecture-diagram)
- [Local Development](#local-development)
- [Building a Distribution Package](#building-a-distribution-package)
- [Contribute](#contribute)
- [Get Help](#get-help)

<!-- /TOC -->

## Requirements

## Requirements
 - OS X 10.15+
 - [Xcode 11+](https://developer.apple.com/xcode/)
 - [CMake 3.14.4](https://github.com/Kitware/CMake/releases/download/v3.14.4/cmake-3.14.4-Darwin-x86_64.dmg) or later. After installing CMake.app add a symlink to cmake in `usr/local/bin` using the following command `ln -s /Applications/CMake.app/Contents/bin/cmake /usr/local/bin`
 - [LLVM 8.0](http://releases.llvm.org/download.html#8.0.0) - used to build the [metadata generator](https://github.com/NativeScript/ios-metadata-generator) submodule. Be sure to have the folder containing `llvm-config` in `PATH` or make a symlink to in `/usr/local/bin/`.
 - [Automake](https://www.gnu.org/software/automake/) - available in [Homebrew](http://brew.sh) as `automake`.
 - [GNU Libtool](http://www.gnu.org/software/libtool/) - available in [Homebrew](http://brew.sh) as `libtool`.
 - [Perl (installed on macOS by default but deprecated since macOS X 10.15)](https://www.perl.org/get.html#osx)
 - Checkout all git submodules using `git submodule update --init`.

## Architecture Diagram

The NativeScript iOS Runtime architecture can be summarized in the following diagram.

![iOS Runtime diagram](https://github.com/NativeScript/docs/blob/master/docs/img/ns-runtime-ios.png)

For more details on how it works, read the [documentation](https://docs.nativescript.org/runtimes/ios/overview).

## Local Development

To be able to open and build {N} iOS Runtime in Xcode you need to configure it for WebKit development and generate the Xcode project files using cmake. To do this execute the following:

```shell
sudo ./src/webkit/Tools/Scripts/configure-xcode-for-ios-development
./cmake-gen.sh
open "cmake-build/NativeScript.xcodeproj"
```

After you open the newly generated project in Xcode you can run the `TestRunner` target or the `Gameraww` example app.

For more information on WebKit configuration see [Building iOS Port section of WebKit's README](https://github.com/WebKit/webkit/blob/master/ReadMe.md#building-ios-port)

## Building a Distribution Package

To build the [`tns-ios` npm package](https://www.npmjs.com/package/tns-ios) run `./build/scripts/package-tns-ios.sh` in the **root** of the repository. The package contains the NativeScript Cocoa Framework, the NativeScript CLI template project and the API metadata generator.

To build the [`tns-ios-inspector` npm package](https://www.npmjs.com/package/tns-ios-inspector) run `./build/scripts/package-tns-ios-inspector.sh` in the **root** of the repository. The package contains the Web Inspector frontend.

## Contribute

We love PRs! Check out the [contributing guidelines](CONTRIBUTING.md). If you want to contribute, but you are not sure where to start - look for [issues labeled `help wanted`](https://github.com/NativeScript/ios-runtime/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22).

## Get Help

Please, use [github issues](https://github.com/NativeScript/ios-runtime/issues) strictly for [reporting bugs](CONTRIBUTING.md#reporting-bugs) or [requesting features](CONTRIBUTING.md#requesting-new-features). For general questions and support, check out [Stack Overflow](https://stackoverflow.com/questions/tagged/nativescript) or ask our experts in [NativeScript community Slack channel](http://developer.telerik.com/wp-login.php?action=slack-invitation).
