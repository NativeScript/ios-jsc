// Inform the test results runner that the runtime is up.
console.log('Application Start!');

import "./Infrastructure/timers";

global.UNUSED = function (param) {
};

var args = NSProcessInfo.processInfo.arguments;
var logjunit = args.containsObject("-logjunit");

// Provides an output channel for jasmine JUnit test result xml.
global.__JUnitSaveResults = function (text) {
    TNSSaveResults(text);

    if (logjunit) {
        text.split('\n').forEach(function (line) {
            console.log("TKUnit: " + line);
        });
    }
};

global.__approot = NSString.stringWithString(NSBundle.mainBundle.bundlePath).stringByResolvingSymlinksInPath;

import "./Infrastructure/Jasmine/jasmine-2.0.1/boot";

import "./Marshalling/Primitives/Function";
import "./Marshalling/Primitives/Static";
import "./Marshalling/Primitives/Instance";
import "./Marshalling/Primitives/Derived";

import "./Marshalling/ObjCTypesTests";
import "./Marshalling/ConstantsTests";
import "./Marshalling/RecordTests";
import "./Marshalling/NSStringTests";
import "./Marshalling/TypesTests";
import "./Marshalling/PointerTests";
import "./Marshalling/ReferenceTests";
import "./Marshalling/FunctionPointerTests";
import "./Marshalling/EnumTests";
import "./Marshalling/ProtocolTests";

// import "./Inheritance/ConstructorResolutionTests";
import "./Inheritance/InheritanceTests";
import "./Inheritance/ProtocolImplementationTests";
import "./Inheritance/TypeScriptTests";

import "./MethodCallsTests";
import "./FunctionsTests";
import "./VersionDiffTests";
import "./ObjCConstructors";

import "./MetadataTests";

// Tests common for all runtimes.
import "./shared";

import "./ApiTests";
import "./DeclarationConflicts";

import "./Promises";
import "./Modules";

execute();

UIApplicationMain(0, null, null, null);
