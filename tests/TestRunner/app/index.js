//var d2 = getDouble2();
//console.log(d2[0], d2[1]);
//
//var d4 = getDouble4();
//console.log(d4[0], d4[1], d4[2], d4[3]);


//{ .y1 = { .x2 = 12.34, .x3 = 3.675 }, .y2 = { .x2 = 31.34, .x3 = 67.675 } };
//var str = getNestedStruct();
//console.log(str.y1.x2, str.y1.x3, str.y2.x2, str.y2.x3);

//
//var d = getDouble3();
//console.log(d[0], d[1], d[2]);

//var f = getFloat4();
//console.log(f[0], f[1], f[2], f[3]);


//var m2x2 = getMatrixFloat2x2();
//console.log(m2x2);
//
//var m4 = getMatrixDouble2x4();
//console.log(m4.columns[0][0], m4.columns[0][1], m4.columns[0][2], m4.columns[0][3]);
//console.log("-----------");
//console.log(m4.columns[1][0], m4.columns[1][1], m4.columns[1][2], m4.columns[1][3]);
//
//var m4 = getMatrixDouble3x2();
//console.log(m4.columns[0][0], m4.columns[0][1]);
//console.log("-----------");
//console.log(m4.columns[1][0], m4.columns[1][1]);

//var v = getUIViewWithBounds();
//console.log(v.origin.x, v.origin.y, v.size.width, v.size.height);

//console.log("----");
//var object = new UIView();
//object.bounds = {
//origin: {
//x: 10,
//y: 20
//},
//size: {
//width: 30,
//height: 40
//}
//};

//console.log(object.bounds.origin.x, object.bounds.origin.y);

//var str = getStructWithVectorAndDouble();
//console.log(str.fl[0],str.fl[1], str.fl[2], str.fl[3], str.dbl);

//var d = getDouble3();
//console.log(d[0], d[1], d[2]);


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
require("./shared").runAllTests();

import "./ApiTests";
import "./DeclarationConflicts";

import "./Promises";
import "./Modules";

import "./RuntimeImplementedAPIs";

execute();

UIApplicationMain(0, null, null, null);
