# NPM Package Build
## Installing Grunt
We have a [grunt](http://gruntjs.com) build setup. To run the build you will need to be able to exec the following tools from the command line:
 - [node](http://nodejs.org)
 - [npm](http://npmjs.org)
 - Xcode6
 - [xcodebuild](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcodebuild.1.html) (using Xcode6, in case of multiple Xcode installations check [xcode-select](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcode-select.1.html))
 - [xcpretty](https://github.com/supermarin/xcpretty)
 - [homebrew](http://brew.sh/) - Used to install various dependencies
 - [mono](http://www.mono-project.com/) - 64 bit version required, install with `brew install mono`
 - [cmake](http://www.cmake.org/) - Required at path, install with `brew install cmake`
 - [boost](http://www.boost.org/) - Install with `brew install boost`

With npm install grunt-cli:
`sudo npm install -g grunt-cli`

Then install the grunt modules in the **root** of the repo:
`npm install`

## Running Examples/TNSApp
The TNSApp requires metadata for the iOS frameworks. To generate it run `grunt dist-metadata` in the **root** of the repo. This should be enough to open, build and run the Examples/TNSApp project in xcode.

## NPM Package Build
To build run grunt in the **root** of the repo: `grunt`.

#### Artefacts
The build should produce a "dist" directory in the root of the repo with the NPM package inside.
It should contain NativeScript.framework, and a NativeScript template project.

## iOS SDK metadata generation
Run `grunt dist-metadata`

#### Artefacts
There should be a `Binaries/MetadataBin/iPhoneOS8.0.sdk/metadata.bin` file.

## Test
To run the tests on a connected device: `grunt test`. You need to have [iFuse](https://github.com/libimobiledevice/ifuse) installed.

#### Artefacts
There should be a `junit-result.xml` file in the root of the repo.

## Tests metadata generation
To generate metadata for the tests: `grunt test-metadata`.

#### Artefacts
There should be a `Binaries/MetadataBin/TNSTestCases/metadata.bin` file.

## Third-party metadata generation
To generate metadata for a third-party library: `grunt metadata -header Test.h -output . -cflags="..."`.

#### Artefacts
There should be a `metadata.bin` file in the same directory.

