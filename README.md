# ios-runtime

## Clone the repository
Use `--recursive` flag to `git clone` command to clone all repository dependencies

```
git clone git@github.com:NativeScript/ios-runtime.git --recursive
```
or if you have already cloned it without `--recursive` flag just run

```
git submodule update --init --recursive
```

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

## NPM Package Build
To build npm package run `grunt package` in the **root** of the repo.

#### Artefacts
The build should produce a `dist/tns-ios-*.tgz` file which is the NPM package. It should contain NativeScript.framework, NativeScript template project, Metadata Generator Tool and Metadata Merger Tool.

## Building Metadata Generator and Metadata Merger
Running `grunt metadataGenerator` in the **root** of the repo will build the metadata generator tool. The command will produce `dist/metadataGenerator` folder with `MetadataGenerator` tool inside.

Running `grunt metadataMerger` in the **root** of the repo will build the metadata merger tool. The command will produce `dist/metadataMerger` folder with `MetadataMerger` tool inside.

Running `grunt metadataTools` in the **root** of the repo will generate both metadata generator and metadata merger tools.

## iOS SDK metadata generation
After you have built **Metadata Generator** and **Metadata Merger** tools (`grunt metadataTools`) you can use them to generate metadata for the iOS SDK by running `grunt dist-metadata`.

#### Artefacts
There should be a `dist/metadata/iPhoneSDK` folder which contains metadata in yaml and binary format.

## Tests metadata generation
After you have built **Metadata Generator** and **Metadata Merger** tools (`grunt metadataTools`) you can use them to generate metadata for the iOS SDK by running `grunt test-metadata`.

#### Artefacts
There should be a `dist/metadata/tests` folder which contains metadata in yaml and binary format.

## Test
To run the tests on a connected device: `grunt test`.

#### Artefacts
There should be a `junit-result.xml` file in the root of the repo.

## Running Examples/TNSApp
The TNSApp requires generated metadata for the iOS SDK (`grunt metadataTools` and `grunt dist-metadata`).
This should be enough to open, build and run the Examples/TNSApp project in Xcode.
