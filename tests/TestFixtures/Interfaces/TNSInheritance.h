//
//  TNSInheritance.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/26/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSMethodCalls.h"

@interface TNSIConstructorVirtualCalls : NSObject {
@protected
    int _x;
    int _y;
}

- (id)initWithX:(int)x andY:(int)y;
@end

@protocol TNSIBaseProtocol

@optional
@property(class) int staticBaseImplementedOptionalProperty;
@property(class) int staticBaseNotImplementedOptionalProperty;

+ (void)staticBaseImplementedOptionalMethod;
+ (void)staticBaseNotImplementedOptionalMethod;
+ (void)staticBaseNotImplementedOptionalMethodImplementedInJavaScript;

@property int baseImplementedOptionalProperty;
@property int baseNotImplementedOptionalProperty;

- (void)baseImplementedOptionalMethod;
- (void)baseNotImplementedOptionalMethod;
- (void)baseNotImplementedOptionalMethodImplementedInJavaScript;
@end

@interface TNSIBaseInterface : NSObject <TNSIBaseProtocol>
@end

@interface TNSIBaseInterface (TNSIBaseCategory)
+ (void)staticBaseImplementedCategoryMethod;
+ (void)staticBaseNotImplementedCategoryMethod;

- (void)baseImplementedCategoryMethod;
- (void)baseNotImplementedCategoryMethod;
- (void)baseNotImplementedNativeCategoryMethodOverridenInJavaScript;
@end

@protocol TNSIDerivedProtocol

@optional
+ (void)staticDerivedImplementedOptionalMethod;
+ (void)staticDerivedNotImplementedOptionalMethod;
@property(class) int staticDerivedImplementedOptionalProperty;
@property(class) int staticDerivedNotImplementedOptionalProperty;

- (void)derivedImplementedOptionalMethod;
- (void)derivedNotImplementedOptionalMethod;
- (void)derivedNotImplementedOptionalMethodImplementedInJavaScript;
@property int derivedImplementedOptionalProperty;
@property int derivedNotImplementedOptionalProperty;
@end

@interface TNSIDerivedInterface : TNSIBaseInterface <TNSIDerivedProtocol>
@end

@interface TNSIDerivedInterface (TNSIDerivedCategory)
+ (void)staticDerivedImplementedCategoryMethod;
+ (void)staticDerivedNotImplementedCategoryMethod;

- (void)derivedImplementedCategoryMethod;
- (void)derivedNotImplementedCategoryMethod;
- (void)derivedNotImplementedNativeCategoryMethodOverridenInJavaScript;
@end

@interface TNSIterableConsumer : NSObject

+ (void)consumeIterable:(id<NSFastEnumeration>)iterable;

@end
