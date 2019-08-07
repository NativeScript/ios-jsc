---
title: iOS Runtime Changelog
description: NativeScript iOS Runtime Changelog
position: 6
publish: false
slug: ios-changelog
previous_url: /Changelogs/iOS Runtime
---

6.0.2 (2019-08-07)
=====

### Bug Fixes

* **metadata-generator:** Preserve headers' relative order when sorting ([#1182](https://github.com/NativeScript/ios-runtime/pull/1182))

6.0.1 (2019-07-17)
=====

### Features

* Update WebKit to version 12.3 ([#1147](https://github.com/NativeScript/ios-runtime/pull/1147))
* Support script hash parameter in debugger protocol ([#1168](https://github.com/NativeScript/ios-runtime/issues/1168))

### Bug Fixes

* **project-template:** Build fails after adding a watchOS target ([#1171](https://github.com/NativeScript/ios-runtime/issues/1171)
* **project-template:** Surround all paths in `nsld.sh` with quotes ([177640c](https://github.com/NativeScript/ios-runtime/commit/177640c))
* **project-template:** Metadata for Swift classes is missing on the first build with Xcode 10.2 ([#1166](https://github.com/NativeScript/ios-runtime/issues/1166))

5.4.2 (2019-06-13)
=====

### Bug Fixes

* **metadata-generator:** Place Swift headers at the bottom of the umbrella header ([#1153](https://github.com/NativeScript/ios-runtime/issues/1153))
* **jsc:** Incorrect sources shown in Chrome DevTools when attaching to application ([#1158](https://github.com/NativeScript/ios-runtime/issues/1158))

5.4.1 (2019-06-06)
=====

### Bug Fixes

* **bridge:** Synchronize access to Strong handles in collection adapters ([#1144](https://github.com/NativeScript/ios-runtime/pull/1144))
* **workers:** Memory leak when creating/wrapping native objects in worker.onmessage([#1137](https://github.com/NativeScript/ios-runtime/issues/1137))
* **metadata-generator:** Convert unsigned 64-bit enum values to signed ([#1150](https://github.com/NativeScript/ios-runtime/issues/1150))
* **jsc:** Prevent 2nd destructor call from ThreadSafeRefCounted ([60b589bc5547b](https://github.com/NativeScript/ios-runtime/pull/1148/commits/60b589bc5547bb4e758fd4e9f2c20cedbbbf6afd))

### Features

* Dump Native and JS callstacks on signal ([6ec5d5c](https://github.com/NativeScript/ios-runtime/commit/6ec5d5c))

### Performance Improvements

* Cache result in getSystemVersion() ([f0e9253](https://github.com/NativeScript/ios-runtime/commit/f0e9253))

5.4.0 (2019-05-15)
=====

## What's new

* **metadata:** Add `TNS_DEBUG_METADATA_STRICT_INCLUDES` option (https://github.com/NativeScript/ios-runtime/commit/b2d03e4ccbf6815d417d91c5c7daadb1b1d451c5)
* **project-template:** Support Swift files in the .xcodeproj (https://github.com/NativeScript/ios-runtime/pull/1128)
* **project-template:** Add NS_LD variable to be used for alternate linker (https://github.com/NativeScript/ios-runtime/pull/1133)

## Bug Fixes
* **project-template:** Change angled bracketed includes to quoted (https://github.com/NativeScript/ios-runtime/pull/1116)
* **metadata:** Copy stderr log to yaml dir (https://github.com/NativeScript/ios-runtime/pull/1119)
* **marshalling:** return WrappedObject for classes with no meta (https://github.com/NativeScript/ios-runtime/pull/1125)
* **runtime:** Unicode properties (https://github.com/NativeScript/ios-runtime/pull/1129)
* **runtime:** added const to avoid using `seen` as global ()
* **metadata:** Stop randomizing modules' order of serialization (https://github.com/NativeScript/ios-runtime/pull/1141)

5.3.1 (2019-04-01)
=====

## Bug Fixes

* **livesync:** `__onLiveSync` function must be called on the UI thread (https://github.com/NativeScript/ios-runtime/pull/1108)

5.3.0 (2019-03-27)
=====

## Breaking changes

* **runtime:** UIApplication's deprecated writable properties are now read-only (https://github.com/NativeScript/ios-runtime/issues/1104)

## What's new

* **metadata:** Metadata generator upgraded to use LLVM 7.0.0 (https://github.com/NativeScript/ios-runtime/pull/1082)

## Performance Improvements

* **runtime:** Lazy evaluation of properties (https://github.com/NativeScript/ios-runtime/pull/1100)

## Bug Fixes

* **build:** Can't compile runtime with CMake 3.14 (https://github.com/NativeScript/ios-runtime/issues/1097)
* **debugger:** Unable to debug onNavigatingTo event (https://github.com/NativeScript/ios-runtime/issues/1021)
* **debugger:** Chrome DevTools: can set breakpoint in the middle of multiline log (https://github.com/NativeScript/ios-runtime/issues/1036)
* **debugger:** Catch and log inspector_modules.js loading errors (https://github.com/NativeScript/ios-runtime/pull/1081)
* **debugger:** VSCode debugger crashes on old simulators (https://github.com/NativeScript/ios-runtime/issues/1084)
* **debugger:** {N} app crashes when inspecting SearchBar with VSCode debugger (https://github.com/NativeScript/ios-runtime/issues/1085)
* **debugger:** Chrome DevTools: console.trace() doesn't log call stack in Chrome's Console (https://github.com/NativeScript/ios-runtime/issues/1099)
* **debugger:** Console evaluation doesn't work with `tns debug ios --bundle` (https://github.com/NativeScript/ios-runtime/issues/1054)
* **debugger:** Empty Elements tab in Chrome with `tns debug ios --bundle` (https://github.com/NativeScript/ios-runtime/issues/1055)
* **debugger:** Cannot add watch expressions with `tns debug ios --bundle` (https://github.com/NativeScript/ios-runtime/issues/1056)
* **debugger:** No requests are shown in Network tab with `tns debug ios --bundle` (https://github.com/NativeScript/ios-runtime/issues/1057)
* **webkit:** Make JSC log to system logs instead of only to stderr (https://github.com/NativeScript/ios-runtime/pull/1093)

5.2.1 (2019-05-23)
=====

### Bug Fixes

* **bridge:** Synchronize access to Strong handles in collection adapters ([b1cfb82](https://github.com/NativeScript/ios-runtime/commit/b1cfb82))


### Features

* Dump Native and JS callstacks on signal ([11304ed](https://github.com/NativeScript/ios-runtime/commit/11304ed))

5.2.0 (2019-02-12)
=====

## What's new

* **api:** Add OnDiscardedError handler ([#1051](https://github.com/NativeScript/ios-runtime/issues/1051))
* **api:** Provide API to release the native object wrapped by a JS one ([#1062](https://github.com/NativeScript/ios-runtime/issues/1062))
* **runtime:** Add support for Objective-C methods with same JS name and different parameters ([#1013](https://github.com/NativeScript/ios-runtime/pull/1013))
* **runtime:** Provide automatic garbage collection triggering ([edbf653](https://github.com/NativeScript/ios-runtime/commit/edbf653)), closes [#1035](https://github.com/NativeScript/ios-runtime/issues/1035)
* **runtime:** Provide support for setting JSC options in {N} applications ([#1004](https://github.com/NativeScript/ios-runtime/issues/1004))

## Bug Fixes

* **bridge:** Don't read JS properties without obtaining a lock ([8786f80](https://github.com/NativeScript/ios-runtime/commit/8786f80))
* **bridge:** Catch ObjC Exceptions and throw them to JS ([#1043](https://github.com/NativeScript/ios-runtime/pull/1043), [#1029](https://github.com/NativeScript/ios-runtime/issues/1029)),
* **bridge:** Don't read returned value of a function which threw an exception ([bdfdd9c](https://github.com/NativeScript/ios-runtime/commit/bdfdd9c))
* **bridge:** Marshal arguments of async calls in worker thread ([30bcaca](https://github.com/NativeScript/ios-runtime/commit/30bcaca))
* **bridge:** Remove ObjCWrapperObject from cache after dealloc ([b3713cb](https://github.com/NativeScript/ios-runtime/commit/b3713cb))
* **interop:** Interop.Pointer int64 creation from NativeScript side ([#921](https://github.com/NativeScript/ios-runtime/issues/921))
* **interop:** Add methods `toHexString` and `toDecimalString` to Pointer ([8b4157f](https://github.com/NativeScript/ios-runtime/commit/8b4157f))
* **interop:** Construct Pointer from a wrapped number ([8d69895](https://github.com/NativeScript/ios-runtime/commit/8d69895))
* **runtime:** Keep JS instances in Strong references after creation ([0e09ac9](https://github.com/NativeScript/ios-runtime/commit/0e09ac9))
* **runtime:** GVRKit plugin metadata generation issue ([#877](https://github.com/NativeScript/ios-runtime/issues/877))
* **runtime:** UncaughtExceptionHandler is called 2 times ([#1049](https://github.com/NativeScript/ios-runtime/issues/1049))

5.1.1 (2019-01-17)
=====

## Bug Fixes

* **debugging:** Ensure a valid listenSource on each AttachRequest ([#1058](https://github.com/NativeScript/ios-runtime/pull/1058))
* **debugging:** Logs are not shown in Chrome console tab ([#1037](https://github.com/NativeScript/ios-runtime/issues/1037))

5.1.0 (2018-12-11)
=====

## What's new

* Generate .dSYM package for NativeScript.framework ([#1016](https://github.com/NativeScript/ios-runtime/pull/1016))
* Update WebKit from iOS 12.0 tag ([#1011](https://github.com/NativeScript/ios-runtime/pull/1011))

## Bug Fixes

* **marshalling:** Memory leak in IsObjcObject ([#1018](https://github.com/NativeScript/ios-runtime/pull/1018))
* **template:** Remove VALID_ARCHS from project.pbxproj ([#1027](https://github.com/NativeScript/ios-runtime/pull/1027) related to [NativeScript/nativescript-cli#4197](https://github.com/NativeScript/nativescript-cli/issues/4197))
* **libffi:** Cannot handle double3, double4, SCNVector3 function parameters([#979](https://github.com/NativeScript/ios-runtime/issues/979))
* **metadata-typings** Accept Pointers and References for `char*` args ([#1022](https://github.com/NativeScript/ios-runtime/pull/1022))

5.0.0 (2018-10-31)
=====

## Breaking Changes
* [Drop iOS Inspector support for macOS Sierra](https://github.com/NativeScript/ios-runtime/issues/988)

## What's New
* [Update WebKit to iOS 11.4](https://github.com/NativeScript/ios-runtime/pull/936)
* [Typings generation improvements](https://github.com/NativeScript/ios-runtime/pull/986). Related to [Typings for NSArray and NSDictionary](https://github.com/NativeScript/NativeScript/issues/6001)

## Bug Fixes
* **marshalling** [Keep strong references to assigned values in ReferenceInstance](https://github.com/NativeScript/ios-runtime/commit/0e9c74b)
* **marshalling** [Native app embedding {N} crashes when opening a modal](https://github.com/NativeScript/NativeScript/issues/6019)
* **project-template** [Set IPHONEOS_DEPLOYMENT_TARGET to 9.0](https://github.com/NativeScript/ios-runtime/pull/994/commits/1b3722280eee3aba605d08cdfa6239e2f6c5b68d)
* **LiveSync** [Set IPHONEOS_DEPLOYMENT_TARGET to 9.0](https://github.com/NativeScript/ios-runtime/pull/994/commits/5c25b8597abd758f563158bacb627ceedd368ca4)
* **LiveSync** [Disable modules debugging linker option for LiveSync library to resolve build warnings in {N} apps](https://github.com/NativeScript/ios-runtime/pull/994/commits/a342fb69ed101161c9a7d67a0c8e495211845fcc)
* **libffi** [Correctly pass/return standalone vectors in native function calls](https://github.com/NativeScript/ios-runtime/pull/960)
* **marshalling** [Reading collisionBoundingPath on UIView results in Objective C exception](https://github.com/NativeScript/ios-runtime/issues/978)

4.2.0 (2018-08-07)
=====

## What's New
- [Introduce a setting for discarding uncaught exceptions from called JS methods](https://github.com/NativeScript/ios-runtime/issues/965)
- [Introduce NativeScriptEmbedder protocol](https://github.com/NativeScript/ios-runtime/issues/972)

## Bug Fixes
- [Correctly find source of CommonJS modules in setScriptSource](https://github.com/NativeScript/ios-runtime/issues/958)
- [App cannot be deployed on device when NS is built as a dynamic framework](https://github.com/NativeScript/ios-runtime/issues/970)
- [App not crashing on unhandled exception](https://github.com/NativeScript/ios-runtime/issues/971)
- [Throw an Objective C exception on fatal error](https://github.com/NativeScript/ios-runtime/issues/969)

4.1.1 (2018-06-19)
=====

## Bug Fixes
- [Fixed Chrome DevTools doesn't reconnect everytime from the first attempt](https://github.com/NativeScript/ios-runtime/issues/940)
- [Fixed empty tabs in Chrome DevTools](https://github.com/NativeScript/ios-runtime/issues/927)
- [Fixed Inspector: console.dir(object) prints "undefined"](https://github.com/NativeScript/ios-runtime/issues/930)

4.1.1 (2018-06-19)
=====

## What's New
- [Improvement: Don't close inspector socket after 30 sec. timeout](https://github.com/NativeScript/ios-runtime/pull/907)
- [Feature: SIMD matrices support](https://github.com/NativeScript/ios-runtime/issues/836)

## Bug Fixes
- [Fixed default debugging port is changed to 18183](https://github.com/NativeScript/ios-runtime/pull/926)
- [Fixed console.time() doesn't print anything in Chrome DevTools console](https://github.com/NativeScript/ios-runtime/issues/888)
- [FIxed in Chrome DevTools console console.dir() prints only [object Object]](https://github.com/NativeScript/ios-runtime/issues/906)

4.0.1  (2018-04-10)
=====

## What's New
- [Update WebKit to version ios-11.2.5](https://github.com/NativeScript/ios-runtime/pull/825)

## Bug Fixes
- [Fixed calling `require()` with an empty .js file](https://github.com/NativeScript/ios-runtime/issues/895)
- [Fixed Inspector error with --debug-brk](https://github.com/NativeScript/ios-runtime/issues/887)
- [Fixed broken Inspector’s Elements tab](https://github.com/NativeScript/ios-runtime/issues/886)
- [Fixed issue with console.dir()](https://github.com/NativeScript/ios-runtime/issues/875)
- [Fixed issue with missing console.time() messages](https://github.com/NativeScript/ios-runtime/issues/843)

3.4.1 (2018-01-11)
=====

## Bug Fixes
- [Fixed issue with canonical module path resolution](https://github.com/NativeScript/ios-runtime/pull/847)
- [Fixed various issues with iOS Inspector](https://github.com/NativeScript/ios-runtime/pull/835)
- [Fixed issue with Inspector crashing on macOS versions earlier than High Sierra (10.13)](https://github.com/NativeScript/ios-runtime/pull/854)

3.4.0 (2017-12-20)
=====

## Bug Fixes
- [Fixed missing stack-trace](https://github.com/NativeScript/ios-runtime/pull/815)
- [Fixed issue with WTF threading not initialized](https://github.com/NativeScript/NativeScript/issues/5019)
- [Fixed issue with Inspector crashing on MacOS High Sierra](https://github.com/NativeScript/ios-runtime/pull/838)

3.3.0 (2017-10-26)
=====

## What's New
- [Optimized FFI calls with CIF caching](https://github.com/NativeScript/ios-runtime/pull/795)

3.2.0 (2017-09-07)
=====

## What's New
- [Update LLVM/Clang to v4.0.0](https://github.com/NativeScript/ios-runtime/pull/780)
## Bug Fixes
- [Fixed memory leak](https://github.com/NativeScript/NativeScript/issues/4490)
- [Enable Xcode 8.3 support](https://github.com/NativeScript/ios-runtime/commit/4d86288f4bd3bb26e109c688add6a6d2ca14af0b)

3.1.0 (2017-06-22)
=====

## What's New
- [Add global.__time function](https://github.com/NativeScript/ios-runtime/pull/766)

3.0.1 (2017-05-17)
=====

## Bug Fixes
- [Fix module resolution logic](https://github.com/NativeScript/ios-runtime/pull/765)

3.0.0 (2017-05-03)
=====

## What's New
- [ObjC TS decorators for specifying protocols and exposed methods](https://github.com/NativeScript/ios-runtime/pull/753)

## Bug Fixes
- [Double click on file in ios debug inspector throws an error](https://github.com/NativeScript/ios-runtime/pull/722)
- [Livesync makes some modules executed twice](https://github.com/NativeScript/ios-runtime/pull/738)
- [Tagged (rc) versions cannot be uploaded to TestFlight/iTunes](https://github.com/NativeScript/ios-runtime/pull/760)
- [Prevent crash when materializing a property without a getter](https://github.com/NativeScript/ios-runtime/commit/93f21af78adfcca026edb5600f75c8b6ed6a3615)

2.5.1 (2017-05-17)
=====

## Bug Fixes
- Fix the AppIcon setting - [#743](https://github.com/NativeScript/ios-runtime/pull/743)

2.5.0 (2017-02-01)
=====

## What's New
- Support for Chrome DevTools remote debugging

2.4.0 (2016-11-16)
=====

## What's New
- Update the JavaScriptCore Engine (100% ES6 support)
- [Experimental] Multithreading support enabled with Web Workers API - [#620](https://github.com/NativeScript/ios-runtime/issues/620)

2.3.0 (2016-09-15)
=====

## What's New
- Marshalling Objective-C class properties - [#635](https://github.com/NativeScript/ios-runtime/pull/635)

## Bug Fixes
- Fix debugging without rebuild on iOS device - [#634](https://github.com/NativeScript/ios-runtime/pull/634)

2.2.1 (2016-08-16)
=====

## Bug Fixes
- Fixed struct marshalling on x86_64 architecture

2.2.0 (2016-08-10)
=====

- LiveSync improvements

2.1.1 (2016-07-06)
=====

## Bug Fixes
- Add `CFBundleVersion` and `CFBundleShortVersionString` keys in the `Info.plist` of the NativeScript framework

2.1.0 (2016-06-30)
=====

## Bug Fixes
- Various debugging and LiveSync improvements

## Breaking Changes
- Removed iOS 7 support

2.0.1 (2016-06-02)
=====

## Bug Fixes
- [Attaching a debugger crashes the app if it was already livesynced](https://github.com/NativeScript/ios-runtime/issues/572)

2.0.0 (2016-04-27)
=====

## Bug Fixes
- [LLVM/Clang in metadata generator is updated to v3.8.0](https://github.com/NativeScript/ios-runtime/pull/547)
- [Throw error on unknown module character encoding](https://github.com/NativeScript/ios-runtime/pull/540)

1.7.0 (2016-03-16)
=====

## What's New
- [Add methods to Objective-C protocol wrappers](https://github.com/NativeScript/ios-runtime/pull/506)
- [Throw error when overriding properties without getter/setter](https://github.com/NativeScript/ios-runtime/pull/517)
- [Provide runtime implementation for source maps](https://github.com/NativeScript/ios-runtime/pull/525)

## Bug Fixes
- [Debugger crashes when open the Storage tab](https://github.com/NativeScript/ios-runtime/pull/527)

1.6.0 (2016-02-17)
=====

## What's New
- [ES6 modules](https://github.com/NativeScript/ios-runtime/pull/468)
- [Swift-style initializers](https://github.com/NativeScript/ios-runtime/pull/476)
- [Distribute inspector application as a separate npm package](https://github.com/NativeScript/ios-runtime/pull/478)
- [Generate TypeScript comments in TypeScript declarations](https://github.com/NativeScript/ios-runtime/pull/497)
- [TNS Objective-C exception handler](https://github.com/NativeScript/ios-runtime/pull/500)
- [Wrap bridged NSError objects in JavaScript errors](https://github.com/NativeScript/ios-runtime/pull/458)
- [Allow vanilla TypeScript classes to extend null](https://github.com/NativeScript/ios-runtime/pull/455/files)
- [Performance improvements for method calls](https://github.com/NativeScript/ios-runtime/pull/438)

## Bug Fixes
- [Rename Objective-C class name in case of extend conflicts](https://github.com/NativeScript/ios-runtime/pull/479)
- [Use proper debug macro in project template](https://github.com/NativeScript/ios-runtime/pull/484)
- [Fix for debugger connecting after a delay](https://github.com/NativeScript/ios-runtime/pull/498)
- [Remove code signing identity from project template](https://github.com/NativeScript/ios-runtime/pull/501)
- [Throw an error if package.json has non-utf8 encoding](https://github.com/NativeScript/ios-runtime/pull/462)
- [Throw an error if loading module source fails](https://github.com/NativeScript/ios-runtime/pull/457)
- [TypeScript extends should not replace parent scope variables](https://github.com/NativeScript/ios-runtime/pull/454)
- [Remove quotes from paths in nativescript-build.xcconfig](https://github.com/NativeScript/ios-runtime/pull/447)

1.5.2 (2016-01-04)
=====

## Bug Fixes
- [Private iOS API usage in JavaScriptCore](https://github.com/NativeScript/webkit/commit/0ebcf48cd284269540892244ef163dbaab9e79b9)

1.5.1 (2015-12-16)
=====

## Bug Fixes
- [Loading static frameworks as shared frameworks](https://github.com/NativeScript/ios-runtime/issues/373)
- [Marshalling boxed JavaScript primitive types throws an exception](https://github.com/NativeScript/ios-runtime/issues/411)

## What's New

- [Simplify require errors](https://github.com/NativeScript/ios-runtime/pull/424)
- [Update JavaScriptCore](https://github.com/NativeScript/ios-runtime/issues/355)
- [Enable requiring of JSON files](https://github.com/NativeScript/ios-runtime/issues/294)

1.5.0 (2015-11-24)
=====

## Bug Fixes
- [Unicode console logs in stderr](https://github.com/NativeScript/ios-runtime/issues/28)
- [Fix out struct marshalling](https://github.com/NativeScript/ios-runtime/pull/370)
- [Prefix modulemap link directives with "lib" as the linker would](https://github.com/NativeScript/ios-runtime/pull/381)
- [Log Clang diagnostics when parsing modulemaps](https://github.com/NativeScript/ios-runtime/issues/316)
- [Metadata generator build fails on older machines](https://github.com/NativeScript/ios-runtime/issues/388)
- Fix some errors in TypeScript declarations - [#33](https://github.com/NativeScript/ios-metadata-generator/pull/33), [#34](https://github.com/NativeScript/ios-metadata-generator/pull/34)

## What's New

- [Add more bridged types](https://github.com/NativeScript/ios-runtime/pull/358)
- [Implement `console.dir` method](https://github.com/NativeScript/ios-runtime/commit/a654ad28e8e78b29a5b0cd3c60306836e955fb0a)

## Breaking Changes
- [Automatic memory management of CoreFoundation functions marked with `CF_IMPLICIT_BRIDGING_ENABLED`](https://github.com/NativeScript/ios-runtime/pull/351)
- [Manual memory management of CoreFoundation functions not-marked with `CF_IMPLICIT_BRIDGING_ENABLED`](https://github.com/NativeScript/ios-runtime/pull/386)

1.4.1 (2015-10-23)
=====

## Bug Fixes

- [Include merged xcconfig files from CLI (#363)](https://github.com/NativeScript/ios-runtime/pull/363)
- [Fix issues with iPhone 6s and iPad Air 2 devices (#377)](https://github.com/NativeScript/ios-runtime/pull/377)

1.4.0 (2015-10-12)
=====

## What's New

 - [iOS 9 Support: Introduce generic information in TypeScript definitions (#341)](https://github.com/NativeScript/ios-runtime/pull/341)
 - [Add async method to FFICall (#339)](https://github.com/NativeScript/ios-runtime/pull/339)
 - [Migrate to Clang 3.7 (#332)](https://github.com/NativeScript/ios-runtime/pull/332)
 - [Move project template files in internal folder (#325)](https://github.com/NativeScript/ios-runtime/pull/325)
 - [Expose compile-time constants (#329)](https://github.com/NativeScript/ios-runtime/pull/329)
 - [Schedule the runtime on the runloop of its owner thread (#323)](https://github.com/NativeScript/ios-runtime/pull/323)
 - [Inject InspectorFrontendHost in the Inspector frontend and communicate over raw sockets (#317)](https://github.com/NativeScript/ios-runtime/pull/317)
 - [Improved CocoaPods support by passing more Xcode build settings to metadata generator (#314)](https://github.com/NativeScript/ios-runtime/pull/314)
 - [Add option in template xcconfig to generate TypeScript declarations and debug metadata (#311)](https://github.com/NativeScript/ios-runtime/pull/311)
 - [Disambiguate native APIs with name collisions (#299)](https://github.com/NativeScript/ios-runtime/pull/299)
 - [Call global.__onUncaughtError if a fatal exception is thrown (#78)](https://github.com/NativeScript/ios-runtime/issues/78)
 - [Throw error if there is a metadata for a symbol, but it's not available at runtime (#349)](https://github.com/NativeScript/ios-runtime/pull/349)

## Bug Fixes

- [Fix mangling of utf8 characters in module code (#334)](https://github.com/NativeScript/ios-runtime/pull/334)
- [Require file when there is a directory with same name (#287)](https://github.com/NativeScript/ios-runtime/pull/287)
- [ReferenceConstructor should accept a single type argument (#284)](https://github.com/NativeScript/ios-runtime/pull/284)
- [Rename some enums to be consistent with how Swift exposes Objective-C enums (#318)](https://github.com/NativeScript/ios-runtime/issues/318)

1.3.0 (2015-09-16)
=====

## What's New

 - [Embed metadata in binary so it can be stripped by app thinning (#275)](https://github.com/NativeScript/ios-runtime/pull/275)
 - [Swift modules use mangled name which is different than the klassName so get the name from the metadata (#274)](https://github.com/NativeScript/ios-runtime/pull/274)
 - [Require with tilde (~) should resolve to the app folder (#254)](https://github.com/NativeScript/ios-runtime/pull/254)
 - [Pause the debugger on startup with --debug-brk (#245)](https://github.com/NativeScript/ios-runtime/pull/245)
 - [Web Inspector Page Agent (#240)](https://github.com/NativeScript/ios-runtime/pull/240)
 - [Two-way marshaling between NSData and ArrayBuffer (#235)](https://github.com/NativeScript/ios-runtime/pull/235)
 - [JavaScript functions, when passed to Objective-C as blocks, will now round-trip back to JavaScript, as the initial function object (#234)](https://github.com/NativeScript/ios-runtime/pull/234)
 - [Create a global require function (#84)](https://github.com/NativeScript/ios-runtime/issues/84)

## Bug Fixes

 - [Error when file ends with a commented line (#288)](https://github.com/NativeScript/ios-runtime/issues/288)
 - [NativeScript::SymbolLoader incorrectly caches framework bundles (#273)](https://github.com/NativeScript/ios-runtime/issues/273)
 - [Better handling of package.json main configuration (#270)](https://github.com/NativeScript/ios-runtime/issues/270)
 - [Expose a conversion between ArrayBuffers and NSData (#231)](https://github.com/NativeScript/ios-runtime/issues/231)
 - [Require doesn't look for index.js in main folder (#112)](https://github.com/NativeScript/ios-runtime/issues/112)
 - [Delete the module cache when a module throws an exception (#20)](https://github.com/NativeScript/ios-runtime/issues/20)
 - [NSDecimalNumber marshalling (#14)](https://github.com/NativeScript/ios-runtime/issues/14)
 - [Explicitly set the metadata generator's OS X deployment target (#285)](https://github.com/NativeScript/ios-runtime/pull/285)
 - [-[TNSValueWrapper value] can return null (#262)](https://github.com/NativeScript/ios-runtime/pull/262)

1.2.2 (2015-08-18)
=====

## Bug Fixes

- [Add lib/iOS folder to framework search paths #266](https://github.com/NativeScript/ios-runtime/pull/266)
- [Call Block_copy in ObjCBlockCall::finishCreation #264](https://github.com/NativeScript/ios-runtime/pull/264)

1.2.1 (2015-08-11)
=====

## Bug Fixes

 - [Timelines recording sends some long messages that hit the buffer limit of write method, so fallback to dispatch_io_write (#255)](https://github.com/NativeScript/ios-runtime/pull/255)
 - [Fix TypeScript inheritance of Objective-C classes (#252)](https://github.com/NativeScript/ios-runtime/pull/252)
 - [Work around crash when logging warnings (#248)](https://github.com/NativeScript/ios-runtime/pull/248)
 - [Do not register the instance structure (#247)](https://github.com/NativeScript/ios-runtime/pull/247)

1.2.0 (2015-07-24)
=====

## What's New

 - [Implement and consume NSFastEnumeration (#222)](https://github.com/NativeScript/ios-runtime/pull/222)
 - [Memory management of class clusters (#214)](https://github.com/NativeScript/ios-runtime/issues/214)
 - [Update to the latest JavaScriptCore (#211)](https://github.com/NativeScript/ios-runtime/pull/211)
 - [Add application that uses the updated webkit webview to show web inspector frontend (#201)](https://github.com/NativeScript/ios-runtime/pull/201)
 - [Transform (NSError **) parameters to JavaScript error throw (#186)](https://github.com/NativeScript/ios-runtime/issues/186)
 - [CMake the JSC: performance and memory diffs (#185)](https://github.com/NativeScript/ios-runtime/issues/185)
 - [iOS 9 support: metadata for Objective-C generics (#177)](https://github.com/NativeScript/ios-runtime/issues/177)
 - [WebInspector: enable WebInspector Performance Profiler (#164)](https://github.com/NativeScript/ios-runtime/issues/164)
 - [Optimize require of JavaScript modules (#139)](https://github.com/NativeScript/ios-runtime/issues/139)

## Bug Fixes

 - [Recursive calls from Objective-C to a method returning JavaScript function as block (#210)](https://github.com/NativeScript/ios-runtime/pull/210)
 - [Enums which have no common prefix are not exposed correctly (#205)](https://github.com/NativeScript/ios-runtime/issues/205)
 - [Recursive calls from JavaScript to Objective-C method receiving a block argument (#199)](https://github.com/NativeScript/ios-runtime/issues/199)
 - [Fix TypeScript extends (#178)](https://github.com/NativeScript/ios-runtime/issues/178)

1.1.0 (2015-06-10)
=====
[Milestone 1.1.0](https://github.com/NativeScript/ios-runtime/issues?q=milestone%3A1.1.0), [Release v1.1.0](https://github.com/NativeScript/ios-runtime/releases/tag/v1.1.0).

## What's New

 - NativeScript for iOS is now built using CMake
 - The runtime is now distributed as a static library and a Cocoa Framework
 - API metadata now includes information about Clang modules
 - NativeScript apps for iOS no longer ship with a WebSocket server for debugging, but rely on a plain TCP socket instead
 - Removed backwards compatibility for the pre-0.10 behavior when looking for *tns_modules*

## Bug Fixes

 - The NativeScript CLI iOS template project now strips non-device architectures from embedded frameworks
 - You can now require paths with .js extension
 - Fixed issue where invoking an Objective-C class cluster as a JavaScript constructor with `new` would cause memory leaks
 - Fixed issue where an inspector frontend connecting to the same app multiple times in a single session would not display sources
 - Accessing JavaScript from multiple threads is properly synchronized
 - The `tns-ios` package is versioned

1.0.1 (2015-05-08)
=====
 - Escape header and framework search paths in metadata generator

1.0.0 (2015-04-29)
=====
[Milestone 1.0.0](https://github.com/NativeScript/ios-runtime/issues?q=milestone%3A1.0.0), [Release v1.0.0](https://github.com/NativeScript/ios-runtime/releases/tag/v1.0.0).
 - New metadata generator using Clang
 - Fix some threading issues
 - C enumeration syntax changed
 - Remove visibility warnings when linking

0.10.0 (2015, April 17)
==
[Milestone 0.10.0](https://github.com/NativeScript/ios-runtime/issues?q=milestone%3A0.10.0), [Release v0.10.0](https://github.com/NativeScript/ios-runtime/releases/tag/v0.10.0).

## What's New

 - JavaScript Date is implicitly converted to NSDate and vice versa.
 - JSON object and JS Map, when passed to native, are wrapped in NSDictionary. NSDictionaries do **not** behave as JSON objects when returned from native.

## Bug Fixes

 - We will try to freeze the application on crash if there is a debugger attached so the debugger can be used to examine the errors.
 - When Objective-C exception is thrown from code called from JavaScript, it will be wrapped in JavaScript error and reported to the debugger.
 - We have fixed the “tagged pointers” bug on iPhone 5s with iOS7.0.
 - We have dramatically reduced the “tns-ios” package size by stripping the debug symbols from the NativeScript.framework.
 - We have fixed the project template to properly support the app-id provided from the CLI.
 - We’ve cleaned the package.tgz from some xcodebuild logs and the Chrome version of the inspector.
 - Made submodules public, fixed builds.
 - *tns_modules* are now expected in the app folder. We are backward compatible but will remove the compatibility in the future.
 - We have updated the project template to use larger resolution.
 - Promise reactions have too low a priority on the runloop.


