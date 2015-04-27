//
//  MetadataTests.m
//  NativeScript
//
//  Created by Ivan Buhov on 9/16/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <string.h>
#include "Metadata.h"

using namespace Metadata;

@interface MetadataTests : XCTestCase

@end

@implementation MetadataTests

/// Iterator Tests

static double getSystemVersion() {
    static UInt8 iosVersion;
    if (iosVersion != 0) {
        return iosVersion;
    }

    NSString* version = [[UIDevice currentDevice] systemVersion];
    return [version doubleValue];
}

- (void)testMetaIterator {
    MetaFileReader* metadata = getMetadata();
    for (MetaIterator it = metadata->begin(); it != metadata->end(); ++it) {
        XCTAssertTrue((*it) != nullptr);
        XCTAssertTrue((*it)->isAvailable());
    }
}

- (void)testAllProperties__Iterator {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("TNSBaseCategoryProtocol1");

    int count = 0;
    for (auto iter = interfaceMeta->getPropertiesIterator(); iter.hasNext(); iter.next()) {
        XCTAssertTrue(iter.currentItem() != nullptr);
        XCTAssertTrue(iter.currentItem()->isAvailable());
        count++;
    }
    XCTAssertEqual(2, count);
}

- (void)testPropertiesWithAvailability__Iterator_ {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("CBUUID");

    int count = 0;
    for (auto iter = interfaceMeta->getPropertiesIterator(); iter.hasNext(); iter.next()) {
        XCTAssertTrue(iter.currentItem() != nullptr);
        XCTAssertTrue(iter.currentItem()->isAvailable());
        count++;
    }
    int expected = 1;
    if (getSystemVersion() >= 7.1) {
        expected = 2;
    }
    XCTAssertEqual(expected, count);
}

- (void)testAllInstanceMethods__Iterator {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("TNSBaseCategoryProtocol1");

    int count = 0;
    for (auto iter = interfaceMeta->getInstanceMethodsIterator(); iter.hasNext(); iter.next()) {
        XCTAssertTrue(iter.currentItem() != nullptr);
        XCTAssertTrue(iter.currentItem()->isAvailable());
        count++;
    }
    XCTAssertEqual(4, count);
}

- (void)testInstanceMethodsWithAvailability__Iterator {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("CLLocationManager");

    int count = 0;
    for (auto iter = interfaceMeta->getInstanceMethodsIterator(); iter.hasNext(); iter.next()) {
        XCTAssertTrue(iter.currentItem() != nullptr);
        XCTAssertTrue(iter.currentItem()->isAvailable());
        count++;
    }
    int expected = 15;
    if (getSystemVersion() >= 8.0) {
        expected = 19;
    }
    XCTAssertEqual(expected, count);
}

- (void)testAllStaticMethods__Iterator {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("TNSBaseCategoryProtocol1");

    int count = 0;
    for (auto iter = interfaceMeta->getStaticMethodsIterator(); iter.hasNext(); iter.next()) {
        XCTAssertTrue(iter.currentItem() != nullptr);
        XCTAssertTrue(iter.currentItem()->isAvailable());
        count++;
    }
    XCTAssertEqual(2, count);
}

- (void)testStaticMethodsWithAvailability__Iterator {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("UIAppearance");

    int count = 0;
    for (auto iter = interfaceMeta->getStaticMethodsIterator(); iter.hasNext(); iter.next()) {
        XCTAssertTrue(iter.currentItem() != nullptr);
        XCTAssertTrue(iter.currentItem()->isAvailable());
        count++;
    }
    int expected = 2;
    if (getSystemVersion() >= 8.0) {
        expected = 4;
    }
    XCTAssertEqual(expected, count);
}

- (void)testAllImplementedProtocolsMethods__Iterator {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("NSArray");

    int count = 0;
    for (auto iter = interfaceMeta->getProtocolsIterator(); iter.hasNext(); iter.next()) {
        XCTAssertTrue(iter.currentItem() != nullptr);
        XCTAssertTrue(iter.currentItem()->isAvailable());
        count++;
    }
    XCTAssertEqual(4, count);
}

///

- (void)testIdentifiersHash {
    const char* identifier = "NSObject";
    unsigned hash = WTF::StringHasher::computeHashAndMaskTop8Bits<LChar>((const LChar*)identifier);
    XCTAssertEqual(7933827u, hash);
}

- (void)testAvaliability_Simple {
    InterfaceMeta* meta = (InterfaceMeta*)getMetadata()->findMeta("NSObject");
    XCTAssertEqual(16, meta->introducedIn()); // 2.0 -> 00010 000 -> 16
}

- (void)testAvaliability_Simple2 {
    InterfaceMeta* meta = (InterfaceMeta*)getMetadata()->findMeta("NSMutableDictionary");
    MethodMeta* method = meta->instanceMethod("setObjectForKeyedSubscript");
    XCTAssertEqual(48, method->introducedIn()); // 6.0 -> 00110 000 -> 48
}

- (void)testNullTerminatedVariadicMethods {
    InterfaceMeta* meta = (InterfaceMeta*)getMetadata()->findMeta("NSArray");

    MethodMeta* method1 = meta->instanceMethod("initWithObjects");
    MethodMeta* method2 = meta->staticMethod("arrayWithObjects");

    XCTAssertTrue(method1->isVariadic() && method1->isVariadicNullTerminated());
    XCTAssertTrue(method2->isVariadic() && method2->isVariadicNullTerminated());
}

- (void)testStruct_SimpleStruct1 {
    StructMeta* structMeta = (StructMeta*)getMetadata()->findMeta("NSRange");
    const char* fieldsNames[] = { "location", "length" };

    [self assertStruct:structMeta
                   hasName:"_NSRange"
                 hasJSName:"NSRange"
               inFramework:"Foundation"
            hasFieldsCount:2
            hasFieldsNames:fieldsNames
        hasFieldsEncodings:"II"];
}

- (void)testStruct_SimpleStruct2 {
    StructMeta* structMeta = (StructMeta*)getMetadata()->findMeta("CGRect");
    const char* fieldsNames[] = { "origin", "size" };

    [self assertStruct:structMeta
                   hasName:"CGRect"
                 hasJSName:"CGRect"
               inFramework:"CoreGraphics"
            hasFieldsCount:2
            hasFieldsNames:fieldsNames
        hasFieldsEncodings:"{CGPoint}{CGSize}"];
}

- (void)testStruct_ComplexStruct {
    StructMeta* structMeta = (StructMeta*)getMetadata()->findMeta("TNSStructWithPointers");
    const char* fieldsNames[] = { "a", "x", "y", "z" };

    [self assertStruct:structMeta
                   hasName:"TNSStructWithPointers"
                 hasJSName:"TNSStructWithPointers"
               inFramework:"UsrLib"
            hasFieldsCount:4
            hasFieldsNames:fieldsNames
        hasFieldsEncodings:"/v|^i^{TNSSimpleStruct}^{TNSStructWithPointers}"];
}

- (void)testStruct_NestedStruct {
    // top level struct
    StructMeta* structMeta1 = (StructMeta*)getMetadata()->findMeta("TNSNestedAnonymousStruct");

    const char* fieldsNames1[] = { "x1", "y1" };

    [self assertStruct:structMeta1
                   hasName:"TNSNestedAnonymousStruct"
                 hasJSName:"TNSNestedAnonymousStruct"
               inFramework:"UsrLib"
            hasFieldsCount:2
            hasFieldsNames:fieldsNames1
        hasFieldsEncodings:"i{?=i{?=i,x3,},x2,y2,}"];
}

- (void)testFunction_DefinedInHeaders {
    FunctionMeta* functionMeta = (FunctionMeta*)getMetadata()->findMeta("NSMakeRange");
    XCTAssertEqual(nullptr, functionMeta);
}

- (void)testMethod_WithBlock {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("TNSObjCTypes");
    MethodMeta* methodMeta = (MethodMeta*)interfaceMeta->instanceMethod("methodWithBlockScope");

    [self assertMethod:methodMeta
                  hasJSName:"methodWithBlockScope"
                inFramework:"UsrLib"
                 isVariadic:false
                hasSelector:"methodWithBlockScope:"
                hasEncoding:"%iiii|i"
        hasCompilerEncoding:"@?12@0:4i8"];
}

- (void)testFunction_WithClassArgument {
    FunctionMeta* functionMeta = (FunctionMeta*)getMetadata()->findMeta("NSStringFromClass");

    [self assertFunction:functionMeta
                 hasName:"NSStringFromClass"
               hasJSName:"NSStringFromClass"
             inFramework:"Foundation"
              isVariadic:false
            hasEncodings:"@\"NSString\"#"];
}

/* Temporarily all variadic functions and methods are removed from metadata */
//- (void)testFunction_Variadic {
//    FunctionMeta* functionMeta = (FunctionMeta*)getMetadata()->findMeta("NSLog");
//
//    [self assertFunction:functionMeta
//                 hasName:"NSLog"
//               hasJSName:"NSLog"
//             inFramework:"Foundation"
//              isVariadic:true
//            hasEncodings:"v@\"NSString\""];
//}

- (void)testFunction_WithTypedefPointerToCFStruct {
    //CFStringRef should be treated as NSString object
    FunctionMeta* functionMeta = (FunctionMeta*)getMetadata()->findMeta("CFCopyTypeIDDescription");

    [self assertFunction:functionMeta
                 hasName:"CFCopyTypeIDDescription"
               hasJSName:"CFCopyTypeIDDescription"
             inFramework:"CoreFoundation"
              isVariadic:false
            hasEncodings:"@\"NSString\"L"];
}

- (void)testEnum_Simple1 {
    JsCodeMeta* jsCodeMeta = (JsCodeMeta*)getMetadata()->findMeta("NSComparisonResult");

    [self assertJsCode:jsCodeMeta
               hasName:"NSComparisonResult"
             hasJSName:"NSComparisonResult"
           inFramework:"Foundation"
             hasJsCode:"__tsEnum({NSOrderedAscending:-1,NSOrderedSame:0,NSOrderedDescending:1})"];
}

- (void)testEnum_Simple2 {
    JsCodeMeta* enumMeta = (JsCodeMeta*)getMetadata()->findMeta("NSStringEncodingConversionOptions");

    [self assertJsCode:enumMeta
               hasName:"NSStringEncodingConversionOptions"
             hasJSName:"NSStringEncodingConversionOptions"
           inFramework:"Foundation"
             hasJsCode:"__tsEnum({NSStringEncodingConversionAllowLossy:1,NSStringEncodingConversionExternalRepresentation:2})"];
}

- (void)testVar_Simple1 {
    VarMeta* varMeta = (VarMeta*)getMetadata()->findMeta("kCFCoreFoundationVersionNumber");

    [self assertVar:varMeta
            hasName:"kCFCoreFoundationVersionNumber"
          hasJSName:"kCFCoreFoundationVersionNumber"
        inFramework:"CoreFoundation"
        hasEncoding:"d"];
}

- (void)testVar_Simple2 {
    VarMeta* varMeta = (VarMeta*)getMetadata()->findMeta("NSRangeException");

    [self assertVar:varMeta
            hasName:"NSRangeException"
          hasJSName:"NSRangeException"
        inFramework:"Foundation"
        hasEncoding:"@\"NSString\""];
}

- (void)testProtocol_Simple {
    ProtocolMeta* protocolMeta = (ProtocolMeta*)getMetadata()->findMeta("TNSDerivedProtocol1");

    [self assertProtocol:protocolMeta
                  hasName:"TNSDerivedProtocol1"
                hasJSName:"TNSDerivedProtocol1"
              inFramework:"UsrLib"
        hasProtocolsCount:0
             hasProtocols:NULL];
}

- (void)testProtocol_WithSimpleHierarchy {
    ProtocolMeta* protocolMeta = (ProtocolMeta*)getMetadata()->findMeta("TNSDerivedProtocol2");
    const char* protocolsNames[] = { "TNSDerivedProtocol1" };

    [self assertProtocol:protocolMeta
                  hasName:"TNSDerivedProtocol2"
                hasJSName:"TNSDerivedProtocol2"
              inFramework:"UsrLib"
        hasProtocolsCount:1
             hasProtocols:protocolsNames];
}

- (void)testProtocol_RealName {
    ProtocolMeta* protocolMeta = (ProtocolMeta*)getMetadata()->findMeta("NSObjectProtocol");

    [self assertProtocol:protocolMeta
                  hasName:"NSObject"
                hasJSName:"NSObjectProtocol"
              inFramework:"UsrLib"
        hasProtocolsCount:0
             hasProtocols:NULL];
}

- (void)testProtocol_InstanceMethod_Simple {
    ProtocolMeta* protocolMeta = (ProtocolMeta*)getMetadata()->findMeta("NSObjectProtocol");
    MethodMeta* methodMeta = protocolMeta->instanceMethod("performSelectorWithObjectWithObject");

    [self assertMethod:methodMeta
                  hasJSName:"performSelectorWithObjectWithObject"
                inFramework:"UsrLib"
                 isVariadic:false
                hasSelector:"performSelector:withObject:withObject:"
                hasEncoding:"@:@@"
        hasCompilerEncoding:"@20@0:4:8@12@16"]; // @40@0:8:16@24@32
}

//- (void)testProtocol_InstanceMethod_WithStruct {
//    ProtocolMeta* protocolMeta = (ProtocolMeta*)getMetadata()->findMeta("NSObjectProtocol");
//    MethodMeta* methodMeta = protocolMeta->instanceMethod("zone");
//
//    [self assertMethod:methodMeta
//                  hasJSName:"zone"
//                inFramework:"UsrLib"
//                 isVariadic:false
//                hasSelector:"zone"
//                hasEncoding:"^{_NSZone}"
//        hasCompilerEncoding:"^{_NSZone=}8@0:4"];
//}

- (void)testProtocol_Property_Simple1 {
    ProtocolMeta* protocolMeta = (ProtocolMeta*)getMetadata()->findMeta("NSFilePresenter");
    PropertyMeta* propertyMeta = protocolMeta->property("presentedItemURL");

    // assert property
    [self assertProperty:propertyMeta
               hasJSName:"presentedItemURL"
             inFramework:"Foundation"
               hasGetter:true
               hasSetter:false];

    // assert getter
    [self assertMethod:propertyMeta->getter()
                  hasJSName:"presentedItemURL"
                inFramework:"Foundation"
                 isVariadic:false
                hasSelector:"presentedItemURL"
                hasEncoding:"@\"NSURL\""
        hasCompilerEncoding:"@8@0:4"]; // @16@0:8
}

- (void)testProtocol_Property_Simple2 {
    ProtocolMeta* protocolMeta = (ProtocolMeta*)getMetadata()->findMeta("TNSBaseProtocol2");
    PropertyMeta* propertyMeta = protocolMeta->property("baseProtocolProperty2");

    // assert property
    [self assertProperty:propertyMeta
               hasJSName:"baseProtocolProperty2"
             inFramework:"UsrLib"
               hasGetter:true
               hasSetter:true];

    // assert getter
    [self assertMethod:propertyMeta->getter()
                  hasJSName:"baseProtocolProperty2"
                inFramework:"UsrLib"
                 isVariadic:false
                hasSelector:"baseProtocolProperty2"
                hasEncoding:"i"
        hasCompilerEncoding:"i8@0:4"]; // i16@0:8

    // assert setter
    [self assertMethod:propertyMeta->setter()
                  hasJSName:"setBaseProtocolProperty2"
                inFramework:"UsrLib"
                 isVariadic:false
                hasSelector:"setBaseProtocolProperty2:"
                hasEncoding:"vi"
        hasCompilerEncoding:"v12@0:4i8"]; // v20@0:8i16
}

- (void)testProtocol_Property_FromImplementedProtocol {
    ProtocolMeta* protocolMeta = (ProtocolMeta*)getMetadata()->findMeta("TNSBaseProtocol2");
    PropertyMeta* propertyMeta = protocolMeta->property("baseProtocolProperty1");

    // assert property
    [self assertProperty:propertyMeta
               hasJSName:"baseProtocolProperty1"
             inFramework:"UsrLib"
               hasGetter:true
               hasSetter:true];

    // assert getter
    [self assertMethod:propertyMeta->getter()
                  hasJSName:"baseProtocolProperty1"
                inFramework:"UsrLib"
                 isVariadic:false
                hasSelector:"baseProtocolProperty1"
                hasEncoding:"i"
        hasCompilerEncoding:"i8@0:4"]; // i16@0:8

    // assert setter
    [self assertMethod:propertyMeta->setter()
                  hasJSName:"setBaseProtocolProperty1"
                inFramework:"UsrLib"
                 isVariadic:false
                hasSelector:"setBaseProtocolProperty1:"
                hasEncoding:"vi"
        hasCompilerEncoding:"v12@0:4i8"]; // v20@0:8i16
}

- (void)testInterface_Simple {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("NSObject");
    const char* protocolsNames[] = { "NSObjectProtocol" };

    [self assertInterface:interfaceMeta
                  hasName:"NSObject"
                hasJSName:"NSObject"
              inFramework:"UsrLib"
        hasProtocolsCount:1
             hasProtocols:protocolsNames
              hasBaseName:NULL];
}

- (void)testInterface_WithProtocolHierarchy {
    InterfaceMeta* nsStringMeta = (InterfaceMeta*)getMetadata()->findMeta("NSString");
    const char* nsStringProtocolsNames[] = { "NSCopying", "NSMutableCopying", "NSSecureCoding" };

    [self assertInterface:nsStringMeta
                  hasName:"NSString"
                hasJSName:"NSString"
              inFramework:"Foundation"
        hasProtocolsCount:3
             hasProtocols:nsStringProtocolsNames
              hasBaseName:"NSObject"];

    ProtocolMeta* nsCopyingMeta = (ProtocolMeta*)nsStringMeta->protocolAt(0);

    [self assertProtocol:nsCopyingMeta
                  hasName:"NSCopying"
                hasJSName:"NSCopying"
              inFramework:"Foundation"
        hasProtocolsCount:0
             hasProtocols:NULL];

    ProtocolMeta* nsMutableCopyingMeta = (ProtocolMeta*)nsStringMeta->protocolAt(1);

    [self assertProtocol:nsMutableCopyingMeta
                  hasName:"NSMutableCopying"
                hasJSName:"NSMutableCopying"
              inFramework:"Foundation"
        hasProtocolsCount:0
             hasProtocols:NULL];

    ProtocolMeta* nsSecureCodingMeta = (ProtocolMeta*)nsStringMeta->protocolAt(2);
    const char* nsSecureCodingNames[] = { "NSCoding" };

    [self assertProtocol:nsSecureCodingMeta
                  hasName:"NSSecureCoding"
                hasJSName:"NSSecureCoding"
              inFramework:"Foundation"
        hasProtocolsCount:1
             hasProtocols:nsSecureCodingNames];

    ProtocolMeta* nsCodingMeta = nsSecureCodingMeta->protocolAt(0);
    [self assertProtocol:nsCodingMeta
                  hasName:"NSCoding"
                hasJSName:"NSCoding"
              inFramework:"Foundation"
        hasProtocolsCount:0
             hasProtocols:NULL];
}

- (void)testInterface_BaseWithHierarchy {
    InterfaceMeta* nsMutableArrayMeta = (InterfaceMeta*)getMetadata()->findMeta("NSMutableArray");

    [self assertInterface:nsMutableArrayMeta
                  hasName:"NSMutableArray"
                hasJSName:"NSMutableArray"
              inFramework:"Foundation"
        hasProtocolsCount:0
             hasProtocols:NULL
              hasBaseName:"NSArray"];

    InterfaceMeta* nsArrayMeta = (InterfaceMeta*)nsMutableArrayMeta->baseMeta();
    const char* nsArrayProtocolsNames[] = { "NSCopying", "NSFastEnumeration", "NSMutableCopying", "NSSecureCoding" };

    [self assertInterface:nsArrayMeta
                  hasName:"NSArray"
                hasJSName:"NSArray"
              inFramework:"Foundation"
        hasProtocolsCount:4
             hasProtocols:nsArrayProtocolsNames
              hasBaseName:"NSObject"];

    InterfaceMeta* nsObjectMeta = (InterfaceMeta*)nsArrayMeta->baseMeta();
    const char* nsObjectProtocolsNames[] = { "NSObjectProtocol" };

    [self assertInterface:nsObjectMeta
                  hasName:"NSObject"
                hasJSName:"NSObject"
              inFramework:"UsrLib"
        hasProtocolsCount:1
             hasProtocols:nsObjectProtocolsNames
              hasBaseName:NULL];
}

- (void)testInterface_InstanceMethod_Simple {
    InterfaceMeta* nsStringMeta = (InterfaceMeta*)getMetadata()->findMeta("NSString");
    MethodMeta* methodMeta = nsStringMeta->instanceMethod("characterAtIndex");

    [self assertMethod:methodMeta
                  hasJSName:"characterAtIndex"
                inFramework:"Foundation"
                 isVariadic:false
                hasSelector:"characterAtIndex:"
                hasEncoding:"UI"
        hasCompilerEncoding:"S12@0:4I8"];
}

// Temporarily all variadic functions and methods are removed from metadata
//- (void)testInterface_InstanceMethod_Variadic {
//    InterfaceMeta* nsStringMeta = (InterfaceMeta*)getMetadata()->findMeta("NSString");
//    MethodMeta* methodMeta = nsStringMeta->instanceMethod("stringByAppendingFormat");
//
//    [self assertMethod:methodMeta
//                  hasJSName:"stringByAppendingFormat"
//                inFramework:"Foundation"
//                 isVariadic:true
//                hasSelector:"stringByAppendingFormat:"
//                hasEncoding:"@\"NSString\"@\"NSString\""
//        hasCompilerEncoding:"@24@0:8@16"]; // the compiler encoding may differ
//}

// Temporarily all variadic functions and methods are removed from metadata
//- (void)testInterface_InstanceMethod_WithVaListArgument {
//    InterfaceMeta* nsStringMeta = (InterfaceMeta*)getMetadata()->findMeta("NSString");
//    MethodMeta* methodMeta = nsStringMeta->instanceMethod("initWithFormatArguments");
//
//    [self assertMethod:methodMeta
//                  hasJSName:"initWithFormatArguments"
//                inFramework:"Foundation"
//                 isVariadic:false
//                hasSelector:"initWithFormat:arguments:"
//                hasEncoding:"&@\"NSString\"~"
//        hasCompilerEncoding:"@32@0:8@16[1{__va_list_tag=II^v^v}]24"]; // the compiler encoding may differ
//}

- (void)testInterface_InstanceMethod_MethodFromBaseClass {
    InterfaceMeta* nsStringMeta = (InterfaceMeta*)getMetadata()->findMeta("NSString");
    MethodMeta* methodMeta = nsStringMeta->instanceMethod("doesNotRecognizeSelector");
    XCTAssertEqual(nullptr, methodMeta);

    InterfaceMeta* nsObjectMeta = (InterfaceMeta*)getMetadata()->findMeta("NSObject");
    methodMeta = nsObjectMeta->instanceMethod("doesNotRecognizeSelector");

    [self assertMethod:methodMeta
                  hasJSName:"doesNotRecognizeSelector"
                inFramework:"UsrLib"
                 isVariadic:false
                hasSelector:"doesNotRecognizeSelector:"
                hasEncoding:"v:"
        hasCompilerEncoding:"v12@0:4:8"]; // v24@0:8:16
}

- (void)testInterface_Property_WithoutSetter {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("NSRegularExpression");
    PropertyMeta* propertyMeta = interfaceMeta->property("pattern");

    [self assertProperty:propertyMeta
               hasJSName:"pattern"
             inFramework:"Foundation"
               hasGetter:true
               hasSetter:false];

    [self assertMethod:propertyMeta->getter()
                  hasJSName:"pattern"
                inFramework:"Foundation"
                 isVariadic:false
                hasSelector:"pattern"
                hasEncoding:"@\"NSString\""
        hasCompilerEncoding:"@8@0:4"]; // @16@0:8
}

- (void)testInterface_Property_WithoutDefaultGetterName {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("NSByteCountFormatter");
    PropertyMeta* propertyMeta = interfaceMeta->property("adaptive");

    [self assertProperty:propertyMeta
               hasJSName:"adaptive"
             inFramework:"Foundation"
               hasGetter:true
               hasSetter:true];

    [self assertMethod:propertyMeta->getter()
                  hasJSName:"isAdaptive"
                inFramework:"Foundation"
                 isVariadic:false
                hasSelector:"isAdaptive"
                hasEncoding:"B"
        hasCompilerEncoding:"c8@0:4"]; // c16@0:8

    [self assertMethod:propertyMeta->setter()
                  hasJSName:"setAdaptive"
                inFramework:"Foundation"
                 isVariadic:false
                hasSelector:"setAdaptive:"
                hasEncoding:"vB"
        hasCompilerEncoding:"v12@0:4c8"]; // v20@0:8c16
}

- (void)testInterface_StaticMethod {
    InterfaceMeta* nsStringMeta = (InterfaceMeta*)getMetadata()->findMeta("NSString");
    MethodMeta* methodMeta = nsStringMeta->staticMethod("stringWithCharactersLength");

    [self assertMethod:methodMeta
                  hasJSName:"stringWithCharactersLength"
                inFramework:"Foundation"
                 isVariadic:false
                hasSelector:"stringWithCharacters:length:"
                hasEncoding:"&^UI"
        hasCompilerEncoding:"@16@0:4r^S8I12"]; // @28@0:8r^S16I24
}

- (void)testInterface_StaticMethod_MethodFromBaseClass {
    InterfaceMeta* nsStringMeta = (InterfaceMeta*)getMetadata()->findMeta("NSString");
    MethodMeta* methodMeta = nsStringMeta->staticMethod("alloc");

    XCTAssertEqual(nullptr, methodMeta);

    InterfaceMeta* nsObjectMeta = (InterfaceMeta*)getMetadata()->findMeta("NSObject");
    methodMeta = nsObjectMeta->staticMethod("alloc");

    [self assertMethod:methodMeta
                  hasJSName:"alloc"
                inFramework:"UsrLib"
                 isVariadic:false
                hasSelector:"alloc"
                hasEncoding:"&"
        hasCompilerEncoding:"@8@0:4"]; // @16@0:8
}

- (void)testInteraface_OverridedMethod {
    InterfaceMeta* nsArrayMeta = (InterfaceMeta*)getMetadata()->findMeta("NSArray");
    MethodMeta* initMethodMeta = nsArrayMeta->instanceMethod("init");
    XCTAssertEqual(nullptr, initMethodMeta);

    InterfaceMeta* nsObjectMeta = (InterfaceMeta*)getMetadata()->findMeta("NSObject");
    initMethodMeta = nsObjectMeta->instanceMethod("init");

    [self assertMethod:initMethodMeta
                  hasJSName:"init"
                inFramework:"UsrLib"
                 isVariadic:false
                hasSelector:"init"
                hasEncoding:"&"
        hasCompilerEncoding:"@8@0:4"]; // @16@0:8
}

- (void)testAllProperties_Simple1 {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("TNSBaseInterface");
    const char* propertiesNames[] = { "baseCategoryProperty", "baseProperty" };

    int propertiesCount = 0;
    for (auto propertiesIter = interfaceMeta->getPropertiesIterator(); propertiesIter.hasNext(); propertiesIter.next()) {
        XCTAssertEqual(0, strcmp(propertiesIter.currentItem()->jsName(), propertiesNames[propertiesCount]));
        propertiesCount++;
    }
    XCTAssertEqual(2, propertiesCount);
}

- (void)testAllProperties__Simple2 {
    InterfaceMeta* interfaceMeta = (InterfaceMeta*)getMetadata()->findMeta("TNSDerivedInterface");
    const char* propertiesNames[] = { "derivedCategoryProperty", "derivedProperty" };

    int propertiesCount = 0;
    for (auto propertiesIter = interfaceMeta->getPropertiesIterator(); propertiesIter.hasNext(); propertiesIter.next()) {
        XCTAssertEqual(0, strcmp(propertiesIter.currentItem()->jsName(), propertiesNames[propertiesCount]));
        propertiesCount++;
    }
    XCTAssertEqual(2, propertiesCount);
}

/*
 Duplication handling is not supported for now
- (void) testMembers_Duplicates_Local
{
    InterfaceMetaInfo *interfaceMeta = [Metadata metadataForIdentifier: @"TNSMetadata"];
    MembersCollectionMetaInfo *memberMeta = [interfaceMeta metadataForInstanceMember: @"localDuplicate"];
    
    [self assertMethod: memberMeta.members[0]
           hasSelector: @selector(localDuplicate:)
   hasCompilerEncoding: @"@24@0:8@16"
            isVariadic: NO
           inFramework: @"Foundation"
hasReturnValueEncoding: @"@\"NSString\""
hasParametersEncodings: @[ @"@\"NSString\"" ]];
    
    [self assertMethod: memberMeta.members[1]
           hasSelector: @selector(localDuplicate)
   hasCompilerEncoding: @"@16@0:8"
            isVariadic: NO
           inFramework: @"Foundation"
hasReturnValueEncoding: @"@\"NSString\""
hasParametersEncodings: @[]];
}

- (void) testMembers_Duplicates_Protocol
{
    InterfaceMetaInfo *interfaceMeta = [Metadata metadataForIdentifier: @"TNSMetadata"];
    MembersCollectionMetaInfo *memberMeta = [interfaceMeta metadataForInstanceMember: @"protocolDupliCate"];
    
    XCTAssertTrue([memberMeta isKindOfClass:[MembersCollectionMetaInfo class]], @"");
    XCTAssertEqual(4, [memberMeta.members count], @"");
}
*/

- (void)assertVar:(VarMeta*)varMeta
          hasName:(const char*)name
        hasJSName:(const char*)jsName
      inFramework:(const char*)framework
      hasEncoding:(const char*)encoding {
    [self assertMeta:varMeta
             hasName:name
           hasJSName:jsName
        hasFramework:framework];

    XCTAssertEqual(0, strcmp(varMeta->encoding(), encoding));
}

- (void)assertStruct:(StructMeta*)structMeta
               hasName:(const char*)structName
             hasJSName:(const char*)jsName
           inFramework:(const char*)framework
        hasFieldsCount:(int)fieldsCount
        hasFieldsNames:(const char**)fieldsNames
    hasFieldsEncodings:(const char*)fieldsEncodings {
    [self assertMeta:structMeta
             hasName:structName
           hasJSName:jsName
        hasFramework:framework];

    XCTAssertEqual(0, strcmp(structMeta->fieldsEncodings(), fieldsEncodings));
    XCTAssertEqual(fieldsCount, structMeta->fieldsCount());

    for (int i = 0; i < structMeta->fieldsCount(); i++) {
        XCTAssertEqual(0, strcmp(structMeta->fieldAt(i), fieldsNames[i]));
    }
}

- (void)assertFunction:(FunctionMeta*)functionMeta
               hasName:(const char*)name
             hasJSName:(const char*)jsName
           inFramework:(const char*)framework
            isVariadic:(bool)isVariadic
          hasEncodings:(const char*)parametersEncodings {
    [self assertMeta:functionMeta
             hasName:name
           hasJSName:jsName
        hasFramework:framework];

    XCTAssertEqual(isVariadic, functionMeta->isVariadic());
    XCTAssertEqual(0, strcmp(parametersEncodings, functionMeta->encoding()));
}

- (void)assertJsCode:(JsCodeMeta*)jsCodeMeta
             hasName:(const char*)name
           hasJSName:(const char*)jsName
         inFramework:(const char*)framework
           hasJsCode:(const char*)jsCode {
    [self assertMeta:jsCodeMeta
             hasName:name
           hasJSName:jsName
        hasFramework:framework];

    XCTAssertTrue(strcmp(jsCodeMeta->jsCode(), jsCode));
}

- (void)assertProtocol:(ProtocolMeta*)protocol
               hasName:(const char*)name
             hasJSName:(const char*)jsName
           inFramework:(const char*)framework
     hasProtocolsCount:(int)protocolsCount
          hasProtocols:(const char**)protocols {
    [self assertBaseClass:protocol
                  hasName:name
                hasJSName:jsName
              inFramework:framework
        hasProtocolsCount:protocolsCount
             hasProtocols:protocols];
}

- (void)assertInterface:(InterfaceMeta*)interface
                hasName:(const char*)name
              hasJSName:(const char*)jsName
            inFramework:(const char*)framework
      hasProtocolsCount:(int)protocolsCount
           hasProtocols:(const char**)protocols
            hasBaseName:(const char*)baseName {
    [self assertBaseClass:interface
                  hasName:name
                hasJSName:jsName
              inFramework:framework
        hasProtocolsCount:protocolsCount
             hasProtocols:protocols];
    if (baseName == NULL) {
        XCTAssertEqual(baseName, interface->baseName());
    } else {
        XCTAssertEqual(0, strcmp(baseName, interface->baseName()));
    }
}

- (void)assertBaseClass:(BaseClassMeta*)baseClass
                hasName:(const char*)name
              hasJSName:(const char*)jsName
            inFramework:(const char*)framework
      hasProtocolsCount:(int)protocolsCount
           hasProtocols:(const char**)protocols {
    [self assertMeta:baseClass
             hasName:name
           hasJSName:jsName
        hasFramework:framework];

    XCTAssertEqual(protocolsCount, baseClass->protocolsCount());

    for (int i = 0; i < baseClass->protocolsCount(); i++) {
        XCTAssertEqual(0, strcmp(baseClass->protocolJsNameAt(i), protocols[i]));
    }
}

- (void)assertMethod:(MethodMeta*)methodMeta
              hasJSName:(const char*)jsName
            inFramework:(const char*)framework
             isVariadic:(bool)isVariadic
            hasSelector:(const char*)selector
            hasEncoding:(const char*)encoding
    hasCompilerEncoding:(const char*)compilerEncoding {
    [self assertMeta:methodMeta
             hasName:jsName
           hasJSName:jsName
        hasFramework:framework];

    XCTAssertEqual(isVariadic, methodMeta->isVariadic());
    XCTAssertEqual(0, strcmp(selector, methodMeta->selectorAsString()));
    XCTAssertEqual(0, strcmp(encoding, methodMeta->encoding()));
}

- (void)assertProperty:(PropertyMeta*)propertyMeta
             hasJSName:(const char*)jsName
           inFramework:(const char*)framework
             hasGetter:(bool)hasGetter
             hasSetter:(bool)hasSetter {
    [self assertMeta:propertyMeta
             hasName:jsName
           hasJSName:jsName
        hasFramework:framework];

    XCTAssertEqual(hasGetter, propertyMeta->hasGetter());
    XCTAssertEqual(hasSetter, propertyMeta->hasSetter());
}

- (void)assertMeta:(Meta*)meta
           hasName:(const char*)name
         hasJSName:(const char*)jsName
      hasFramework:(const char*)framework {
    XCTAssert(strcmp(meta->name(), name) == 0);
    XCTAssert(strcmp(meta->jsName(), jsName) == 0);
    XCTAssert(strcmp(meta->framework(), framework) == 0);
}

@end
