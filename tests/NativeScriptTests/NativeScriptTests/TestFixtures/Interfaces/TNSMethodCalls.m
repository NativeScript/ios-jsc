//
//  TNSBaseMethods.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/21/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import "TNSMethodCalls.h"

@implementation TNSBaseInterface

- (int)baseProtocolProperty1 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setBaseProtocolProperty1:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (int)baseProtocolProperty1Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setBaseProtocolProperty1Optional:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (int)baseProtocolProperty2 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setBaseProtocolProperty2:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (int)baseProtocolProperty2Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setBaseProtocolProperty2Optional:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (int)baseProperty {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setBaseProperty:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

+ (void)baseProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
+ (void)baseProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initBaseProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (instancetype)initBaseProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)baseProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (void)baseProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
+ (void)baseProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
+ (void)baseProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initBaseProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (instancetype)initBaseProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)baseProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (void)baseProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
+ (void)baseMethod {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initBaseMethod {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)baseMethod {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
+ (void)baseVariadicMethod:(id)x, ... {
    [TNSGetOutput() appendFormat:@"base instance %@ called", NSStringFromSelector(_cmd)];
}
@end

@implementation TNSBaseInterface (TNSBaseCategory)

- (int)baseCategoryProtocolProperty1 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setBaseCategoryProtocolProperty1:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

- (int)baseCategoryProtocolProperty1Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setBaseCategoryProtocolProperty1Optional:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

- (int)baseCategoryProtocolProperty2 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setBaseCategoryProtocolProperty2:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

- (int)baseCategoryProtocolProperty2Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setBaseCategoryProtocolProperty2Optional:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

- (int)baseCategoryProperty {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setBaseCategoryProperty:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

+ (void)baseCategoryProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
+ (void)baseCategoryProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initBaseCategoryProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (instancetype)initBaseCategoryProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)baseCategoryProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (void)baseCategoryProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
+ (void)baseCategoryProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
+ (void)baseCategoryProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initBaseCategoryProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (instancetype)initBaseCategoryProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)baseCategoryProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (void)baseCategoryProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
+ (void)baseCategoryMethod {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initBaseCategoryMethod {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)baseCategoryMethod {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
@end



@implementation TNSDerivedInterface

- (int)derivedProtocolProperty1 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setDerivedProtocolProperty1:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (int)derivedProtocolProperty1Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setDerivedProtocolProperty1Optional:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (int)derivedProtocolProperty2 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setDerivedProtocolProperty2:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (int)derivedProtocolProperty2Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setDerivedProtocolProperty2Optional:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (int)derivedProperty {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setDerivedProperty:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

+ (void)derivedProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
+ (void)derivedProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initDerivedProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (instancetype)initDerivedProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)derivedProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (void)derivedProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
+ (void)derivedProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
+ (void)derivedProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initDerivedProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (instancetype)initDerivedProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)derivedProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (void)derivedProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
+ (void)derivedMethod {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initDerivedMethod {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)derivedMethod {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
@end

@implementation TNSDerivedInterface (TNSDerivedCategory)

- (int)derivedCategoryProtocolProperty1 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setDerivedCategoryProtocolProperty1:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

- (int)derivedCategoryProtocolProperty1Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setDerivedCategoryProtocolProperty1Optional:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

- (int)derivedCategoryProtocolProperty2 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setDerivedCategoryProtocolProperty2:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

- (int)derivedCategoryProtocolProperty2Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setDerivedCategoryProtocolProperty2Optional:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

- (int)derivedCategoryProperty {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
    return 0;
}
- (void)setDerivedCategoryProperty:(int)value {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}

+ (void)derivedCategoryProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
+ (void)derivedCategoryProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initDerivedCategoryProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (instancetype)initDerivedCategoryProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)derivedCategoryProtocolMethod1 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (void)derivedCategoryProtocolMethod1Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
+ (void)derivedCategoryProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
+ (void)derivedCategoryProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initDerivedCategoryProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (instancetype)initDerivedCategoryProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)derivedCategoryProtocolMethod2 {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
- (void)derivedCategoryProtocolMethod2Optional {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
+ (void)derivedCategoryMethod {
    [TNSGetOutput() appendFormat:@"static %@ called", NSStringFromSelector(_cmd)];
}
- (instancetype)initDerivedCategoryMethod {
    [TNSGetOutput() appendFormat:@"constructor %@ called", NSStringFromSelector(_cmd)];
    return self;
}
- (void)derivedCategoryMethod {
    [TNSGetOutput() appendFormat:@"instance %@ called", NSStringFromSelector(_cmd)];
}
@end
