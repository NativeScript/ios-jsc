//
//  TNSTestNativeCallbacks.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 7/31/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#import "TNSTestNativeCallbacks.h"
#import <objc/message.h>

#if !defined(UNUSED)
#define UNUSED(variable) (void) variable
#endif

@implementation TNSTestNativeCallbacks

+ (void)inheritanceMethodCalls:(TNSDerivedInterface*)object {
    [object baseMethod];
    [object baseProtocolMethod2];
    [object baseProtocolMethod2Optional];
    [object baseProtocolMethod1];
    [object baseProtocolMethod1Optional];
    [object baseCategoryMethod];
    [object baseCategoryProtocolMethod2];
    [object baseCategoryProtocolMethod2Optional];
    [object baseCategoryProtocolMethod1];
    [object baseCategoryProtocolMethod1Optional];
    [object derivedMethod];
    [object derivedProtocolMethod2];
    [object derivedProtocolMethod2Optional];
    [object derivedProtocolMethod1];
    [object derivedProtocolMethod1Optional];
    [object derivedCategoryMethod];
    [object derivedCategoryProtocolMethod2];
    [object derivedCategoryProtocolMethod2Optional];
    [object derivedCategoryProtocolMethod1];
    [object derivedCategoryProtocolMethod1Optional];
}

+ (void)inheritanceConstructorCalls:(Class)JSDerivedInterface {
    NSAssert([[[JSDerivedInterface alloc] initBaseProtocolMethod1] isKindOfClass:JSDerivedInterface], @"initBaseProtocolMethod1 failed");
    NSAssert([[[JSDerivedInterface alloc] initBaseProtocolMethod1Optional] isKindOfClass:JSDerivedInterface], @"initBaseProtocolMethod1Optional failed");
    NSAssert([[[JSDerivedInterface alloc] initBaseProtocolMethod2] isKindOfClass:JSDerivedInterface], @"initBaseProtocolMethod2 failed");
    NSAssert([[[JSDerivedInterface alloc] initBaseProtocolMethod2Optional] isKindOfClass:JSDerivedInterface], @"initBaseProtocolMethod2Optional failed");
    NSAssert([[[JSDerivedInterface alloc] initBaseMethod] isKindOfClass:JSDerivedInterface], @"initBaseMethod failed");
    NSAssert([[[JSDerivedInterface alloc] initBaseCategoryProtocolMethod1] isKindOfClass:JSDerivedInterface], @"initBaseCategoryProtocolMethod1 failed");
    NSAssert([[[JSDerivedInterface alloc] initBaseCategoryProtocolMethod1Optional] isKindOfClass:JSDerivedInterface], @"initBaseCategoryProtocolMethod1Optional failed");
    NSAssert([[[JSDerivedInterface alloc] initBaseCategoryProtocolMethod2] isKindOfClass:JSDerivedInterface], @"initBaseCategoryProtocolMethod2 failed");
    NSAssert([[[JSDerivedInterface alloc] initBaseCategoryProtocolMethod2Optional] isKindOfClass:JSDerivedInterface], @"initBaseCategoryProtocolMethod2Optional failed");
    NSAssert([[[JSDerivedInterface alloc] initBaseCategoryMethod] isKindOfClass:JSDerivedInterface], @"initBaseCategoryMethod failed");
    NSAssert([[[JSDerivedInterface alloc] initDerivedProtocolMethod1] isKindOfClass:JSDerivedInterface], @"initDerivedProtocolMethod1 failed");
    NSAssert([[[JSDerivedInterface alloc] initDerivedProtocolMethod1Optional] isKindOfClass:JSDerivedInterface], @"initDerivedProtocolMethod1Optional failed");
    NSAssert([[[JSDerivedInterface alloc] initDerivedProtocolMethod2] isKindOfClass:JSDerivedInterface], @"initDerivedProtocolMethod2 failed");
    NSAssert([[[JSDerivedInterface alloc] initDerivedProtocolMethod2Optional] isKindOfClass:JSDerivedInterface], @"initDerivedProtocolMethod2Optional failed");
    NSAssert([[[JSDerivedInterface alloc] initDerivedMethod] isKindOfClass:JSDerivedInterface], @"initDerivedMethod failed");
    NSAssert([[[JSDerivedInterface alloc] initDerivedCategoryProtocolMethod1] isKindOfClass:JSDerivedInterface], @"initDerivedCategoryProtocolMethod1 failed");
    NSAssert([[[JSDerivedInterface alloc] initDerivedCategoryProtocolMethod1Optional] isKindOfClass:JSDerivedInterface], @"initDerivedCategoryProtocolMethod1Optional failed");
    NSAssert([[[JSDerivedInterface alloc] initDerivedCategoryProtocolMethod2] isKindOfClass:JSDerivedInterface], @"initDerivedCategoryProtocolMethod2 failed");
    NSAssert([[[JSDerivedInterface alloc] initDerivedCategoryProtocolMethod2Optional] isKindOfClass:JSDerivedInterface], @"initDerivedCategoryProtocolMethod2Optional failed");
    NSAssert([[[JSDerivedInterface alloc] initDerivedCategoryMethod] isKindOfClass:JSDerivedInterface], @"initDerivedCategoryMethod failed");
}

+ (void)inheritancePropertyCalls:(TNSDerivedInterface*)object {
    object.baseProtocolProperty1 = 0;
    UNUSED(object.baseProtocolProperty1);
    object.baseProtocolProperty1Optional = 0;
    UNUSED(object.baseProtocolProperty1Optional);
    object.baseProtocolProperty2 = 0;
    UNUSED(object.baseProtocolProperty2);
    object.baseProtocolProperty2Optional = 0;
    UNUSED(object.baseProtocolProperty2Optional);
    object.baseProperty = 0;
    UNUSED(object.baseProperty);
    object.baseCategoryProtocolProperty1 = 0;
    UNUSED(object.baseCategoryProtocolProperty1);
    object.baseCategoryProtocolProperty1Optional = 0;
    UNUSED(object.baseCategoryProtocolProperty1Optional);
    object.baseCategoryProtocolProperty2 = 0;
    UNUSED(object.baseCategoryProtocolProperty2);
    object.baseCategoryProtocolProperty2Optional = 0;
    UNUSED(object.baseCategoryProtocolProperty2Optional);
    object.baseCategoryProperty = 0;
    UNUSED(object.baseCategoryProperty);
    object.derivedProtocolProperty1 = 0;
    UNUSED(object.derivedProtocolProperty1);
    object.derivedProtocolProperty1Optional = 0;
    UNUSED(object.derivedProtocolProperty1Optional);
    object.derivedProtocolProperty2 = 0;
    UNUSED(object.derivedProtocolProperty2);
    object.derivedProtocolProperty2Optional = 0;
    UNUSED(object.derivedProtocolProperty2Optional);
    object.derivedProperty = 0;
    UNUSED(object.derivedProperty);
    object.derivedCategoryProtocolProperty1 = 0;
    UNUSED(object.derivedCategoryProtocolProperty1);
    object.derivedCategoryProtocolProperty1Optional = 0;
    UNUSED(object.derivedCategoryProtocolProperty1Optional);
    object.derivedCategoryProtocolProperty2 = 0;
    UNUSED(object.derivedCategoryProtocolProperty2);
    object.derivedCategoryProtocolProperty2Optional = 0;
    UNUSED(object.derivedCategoryProtocolProperty2Optional);
    object.derivedCategoryProperty = 0;
    UNUSED(object.derivedCategoryProperty);
}

+ (void)inheritanceVoidSelector:(id)object {
    SEL sel = NSSelectorFromString(@"voidSelector");
    NSAssert([object respondsToSelector:sel], @"Object does not respond to selector");
    ((void (*)(id, SEL))objc_msgSend)(object, sel);
}

+ (id)inheritanceVariadicSelector:(id)object {
    SEL sel = NSSelectorFromString(@"variadicSelector:x:");
    NSAssert([object respondsToSelector:sel], @"Object does not respond to selector");
    id result = ((id (*)(id, SEL, NSString*, int))objc_msgSend)(object, sel, @"native", 9);
    return result;
}

+ (void)inheritanceOptionalProtocolMethodsAndCategories:(TNSIDerivedInterface*)object {
    BOOL responds;

    // Base
    [object baseImplementedOptionalMethod];

    responds = [object respondsToSelector:@selector(baseNotImplementedOptionalMethod)];
    NSAssert(!responds, NSStringFromSelector(_cmd));

    [object baseNotImplementedOptionalMethodImplementedInJavaScript];

    [object baseImplementedCategoryMethod];

    responds = [object respondsToSelector:@selector(baseNotImplementedCategoryMethod)];
    NSAssert(!responds, NSStringFromSelector(_cmd));

    [object baseNotImplementedNativeCategoryMethodOverridenInJavaScript];

    // Derived
    [object derivedImplementedOptionalMethod];

    responds = [object respondsToSelector:@selector(derivedNotImplementedOptionalMethod)];
    NSAssert(!responds, NSStringFromSelector(_cmd));

    [object derivedNotImplementedOptionalMethodImplementedInJavaScript];

    [object derivedImplementedCategoryMethod];

    responds = [object respondsToSelector:@selector(derivedNotImplementedCategoryMethod)];
    NSAssert(!responds, NSStringFromSelector(_cmd));

    [object derivedNotImplementedNativeCategoryMethodOverridenInJavaScript];
}

+ (void)apiCustomGetterAndSetter:(TNSApi*)object {
    NSAssert(object.property == 3, NSStringFromSelector(_cmd));
}

+ (void)apiOverrideWithCustomGetterAndSetter:(TNSApi*)object {
    NSAssert(object.property == -6, NSStringFromSelector(_cmd));
}

+ (void)apiReadonlyPropertyInProtocolAndOverrideWithSetterInInterface:(UIView*)object {
    NSAssert(CGRectEqualToRect([object bounds], CGRectMake(10, 20, 30, 40)), NSStringFromSelector(_cmd));
}

+ (void)apiDescriptionOverride:(id)object {
    NSAssert([[object description] isEqualToString:@"js description"], NSStringFromSelector(_cmd));
}

+ (void)protocolImplementationMethods:(id<TNSBaseProtocol1, NSObject>)object {
    NSAssert([object conformsToProtocol:@protocol(TNSBaseProtocol1)], NSStringFromSelector(_cmd));
    NSAssert([[object class] conformsToProtocol:@protocol(TNSBaseProtocol1)], NSStringFromSelector(_cmd));
    [object baseProtocolMethod1];
}

+ (void)protocolImplementationProtocolInheritance:(id<TNSBaseProtocol2, NSObject>)object {
    NSAssert([object conformsToProtocol:@protocol(TNSBaseProtocol1)], NSStringFromSelector(_cmd));
    NSAssert([[object class] conformsToProtocol:@protocol(TNSBaseProtocol1)], NSStringFromSelector(_cmd));
    [object baseProtocolMethod1];

    NSAssert([object conformsToProtocol:@protocol(TNSBaseProtocol2)], NSStringFromSelector(_cmd));
    NSAssert([[object class] conformsToProtocol:@protocol(TNSBaseProtocol2)], NSStringFromSelector(_cmd));
    [object baseProtocolMethod2];
}

+ (void)protocolImplementationOptionalMethods:(id<TNSBaseProtocol2, NSObject>)object {
    BOOL responds;

    responds = [object respondsToSelector:@selector(baseProtocolMethod1Optional)];
    NSAssert(responds, NSStringFromSelector(_cmd));
    [object baseProtocolMethod1Optional];

    responds = [object respondsToSelector:@selector(baseProtocolMethod2Optional)];
    NSAssert(!responds, NSStringFromSelector(_cmd));
}

+ (void)protocolImplementationProperties:(id<TNSBaseProtocol1, NSObject>)object {
    object.baseProtocolProperty1 = 0;
    UNUSED(object.baseProtocolProperty1);
    object.baseProtocolProperty1Optional = 0;
    UNUSED(object.baseProtocolProperty1Optional);
}

+ (TNSSimpleStruct)recordsSimpleStruct:(TNSSimpleStruct)object {
    TNSLog([NSString stringWithFormat:@"%d %d", object.x, object.y]);
    return object;
}

+ (TNSNestedStruct)recordsNestedStruct:(TNSNestedStruct)object {
    TNSLog([NSString stringWithFormat:@"%d %d %d %d", object.a.x, object.a.y, object.b.x, object.b.y]);
    return object;
}

+ (TNSStructWithArray)recordsStructWithArray:(TNSStructWithArray)object {
    TNSLog([NSString stringWithFormat:@"%d %d %d %d %d", object.x, object.arr[0], object.arr[1], object.arr[2], object.arr[3]]);
    return object;
}

+ (TNSNestedAnonymousStruct)recordsNestedAnonymousStruct:(TNSNestedAnonymousStruct)object {
    TNSLog([NSString stringWithFormat:@"%d %d %d", object.x1, object.y1.x2, object.y1.y2.x3]);
    return object;
}

+ (TNSComplexStruct)recordsComplexStruct:(TNSComplexStruct)object {
    TNSLog([NSString stringWithFormat:@"%d %d %d %d %d %d %d",
                                      object.x1,
                                      object.y1[0].x2,
                                      object.y1[0].y2.x3[0],
                                      object.y1[0].y2.x3[1],
                                      object.y1[1].x2,
                                      object.y1[2].y2.x3[0],
                                      object.y1[3].y2.x3[1]]);
    return object;
}

+ (void)apiNSMutableArrayMethods:(NSMutableArray*)object {
    [object addObject:@"b"];
    [object addObject:@"x"];
    [object addObject:@"c"];
    [object addObject:@"y"];
    [object addObject:@"z"];
    [object insertObject:@"a" atIndex:0];
    [object removeObjectAtIndex:2];
    [object removeLastObject];
    object[3] = @"d";
    TNSLog([NSString stringWithFormat:@"%tu%tu", [object count], [object hash]]);

    for (id x in object) {
        TNSLog([NSString stringWithFormat:@"%@", x]);
    }
}

+ (void)apiSwizzle:(TNSSwizzleKlass*)object {
    object.aProperty = 3;
    TNSLog([NSString stringWithFormat:@"%d", object.aProperty]);
    TNSLog([NSString stringWithFormat:@"%d", [[object class] staticMethod:3]]);
    TNSLog([NSString stringWithFormat:@"%d", [object instanceMethod:3]]);
}

+ (NSString*)callRecursively:(NSString* (^)())block {
    return block();
}

@end
