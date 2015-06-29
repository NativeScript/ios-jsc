//
//  TNSTestNativeCallbacks.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 7/31/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "Interfaces/TNSInheritance.h"
#include "Api/TNSApi.h"
#include "Marshalling/TNSRecords.h"

@interface TNSTestNativeCallbacks : NSObject

+ (void)inheritanceMethodCalls:(TNSDerivedInterface*)derivedInterface;

+ (void)inheritanceConstructorCalls:(Class)JSDerivedInterface;

+ (void)inheritancePropertyCalls:(TNSDerivedInterface*)object;

+ (void)inheritanceVoidSelector:(id)object;

+ (id)inheritanceVariadicSelector:(id)object;

+ (void)inheritanceOptionalProtocolMethodsAndCategories:(TNSIDerivedInterface*)object;

+ (void)apiCustomGetterAndSetter:(TNSApi*)object;

+ (void)apiOverrideWithCustomGetterAndSetter:(TNSApi*)object;

+ (void)apiReadonlyPropertyInProtocolAndOverrideWithSetterInInterface:(UIView*)object;

+ (void)apiDescriptionOverride:(id)object;

+ (void)protocolImplementationMethods:(id<TNSBaseProtocol1, NSObject>)object;

+ (void)protocolImplementationProtocolInheritance:(id<TNSBaseProtocol2, NSObject>)object;

+ (void)protocolImplementationOptionalMethods:(id<TNSBaseProtocol2, NSObject>)object;

+ (void)protocolImplementationProperties:(id<TNSBaseProtocol1, NSObject>)object;

+ (TNSSimpleStruct)recordsSimpleStruct:(TNSSimpleStruct)object;

+ (TNSNestedStruct)recordsNestedStruct:(TNSNestedStruct)object;

+ (TNSStructWithArray)recordsStructWithArray:(TNSStructWithArray)object;

+ (TNSNestedAnonymousStruct)recordsNestedAnonymousStruct:(TNSNestedAnonymousStruct)object;

+ (TNSComplexStruct)recordsComplexStruct:(TNSComplexStruct)object;

+ (void)apiNSMutableArrayMethods:(NSMutableArray*)object;

+ (void)apiSwizzle:(TNSSwizzleKlass*)object;

+ (NSString*)callRecursively:(NSString* (^)())block;

@end
