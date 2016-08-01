//
//  TNSBaseMethods.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/21/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

@protocol TNSBaseProtocol1
@property int baseProtocolProperty1;
@property (class) int baseProtocolProperty1;
+ (void)baseProtocolMethod1;
- (instancetype)initBaseProtocolMethod1;
- (void)baseProtocolMethod1;

@optional
@property int baseProtocolProperty1Optional;
@property (class) int baseProtocolProperty1Optional;
+ (void)baseProtocolMethod1Optional;
- (instancetype)initBaseProtocolMethod1Optional;
- (void)baseProtocolMethod1Optional;
@end

@protocol TNSBaseProtocol2 <TNSBaseProtocol1>
@property int baseProtocolProperty2;
@property (class) int baseProtocolProperty2;
+ (void)baseProtocolMethod2;
- (instancetype)initBaseProtocolMethod2;
- (void)baseProtocolMethod2;

@optional
@property int baseProtocolProperty2Optional;
@property (class) int baseProtocolProperty2Optional;
+ (void)baseProtocolMethod2Optional;
- (instancetype)initBaseProtocolMethod2Optional;
- (void)baseProtocolMethod2Optional;
@end

@interface TNSBaseInterface : NSObject <TNSBaseProtocol2>
@property int baseProperty;
@property (class) int baseProperty;
+ (void)baseMethod;
- (instancetype)initBaseMethod;
- (void)baseMethod;
@end

@protocol TNSBaseCategoryProtocol1
@property int baseCategoryProtocolProperty1;
@property (class) int baseCategoryProtocolProperty1;
+ (void)baseCategoryProtocolMethod1;
- (instancetype)initBaseCategoryProtocolMethod1;
- (void)baseCategoryProtocolMethod1;

@optional
@property int baseCategoryProtocolProperty1Optional;
@property (class) int baseCategoryProtocolProperty1Optional;
+ (void)baseCategoryProtocolMethod1Optional;
- (instancetype)initBaseCategoryProtocolMethod1Optional;
- (void)baseCategoryProtocolMethod1Optional;
@end

@protocol TNSBaseCategoryProtocol2 <TNSBaseCategoryProtocol1>
@property int baseCategoryProtocolProperty2;
@property (class) int baseCategoryProtocolProperty2;
+ (void)baseCategoryProtocolMethod2;
- (instancetype)initBaseCategoryProtocolMethod2;
- (void)baseCategoryProtocolMethod2;

@optional
@property int baseCategoryProtocolProperty2Optional;
@property (class) int baseCategoryProtocolProperty2Optional;
+ (void)baseCategoryProtocolMethod2Optional;
- (instancetype)initBaseCategoryProtocolMethod2Optional;
- (void)baseCategoryProtocolMethod2Optional;
@end

@interface TNSBaseInterface (TNSBaseCategory) <TNSBaseCategoryProtocol2>
@property int baseCategoryProperty;
@property (class) int baseCategoryProperty;
+ (void)baseCategoryMethod;
- (instancetype)initBaseCategoryMethod;
- (void)baseCategoryMethod;
@end

@protocol TNSDerivedProtocol1
@property int derivedProtocolProperty1;
@property (class) int derivedProtocolProperty1;
+ (void)derivedProtocolMethod1;
- (instancetype)initDerivedProtocolMethod1;
- (void)derivedProtocolMethod1;

@optional
@property int derivedProtocolProperty1Optional;
@property (class) int derivedProtocolProperty1Optional;
+ (void)derivedProtocolMethod1Optional;
- (instancetype)initDerivedProtocolMethod1Optional;
- (void)derivedProtocolMethod1Optional;
@end

@protocol TNSDerivedProtocol2 <TNSDerivedProtocol1>
@property int derivedProtocolProperty2;
@property (class) int derivedProtocolProperty2;
+ (void)derivedProtocolMethod2;
- (instancetype)initDerivedProtocolMethod2;
- (void)derivedProtocolMethod2;

@optional
@property int derivedProtocolProperty2Optional;
@property (class) int derivedProtocolProperty2Optional;
+ (void)derivedProtocolMethod2Optional;
- (instancetype)initDerivedProtocolMethod2Optional;
- (void)derivedProtocolMethod2Optional;
@end

@interface TNSDerivedInterface : TNSBaseInterface <TNSDerivedProtocol2>
@property int derivedProperty;
@property (class) int derivedProperty;
+ (void)derivedMethod;
- (instancetype)initDerivedMethod;
- (void)derivedMethod;
@end

@protocol TNSDerivedCategoryProtocol1
@property int derivedCategoryProtocolProperty1;
@property (class) int derivedCategoryProtocolProperty1;
+ (void)derivedCategoryProtocolMethod1;
- (instancetype)initDerivedCategoryProtocolMethod1;
- (void)derivedCategoryProtocolMethod1;

@optional
@property int derivedCategoryProtocolProperty1Optional;
@property (class) int derivedCategoryProtocolProperty1Optional;
+ (void)derivedCategoryProtocolMethod1Optional;
- (instancetype)initDerivedCategoryProtocolMethod1Optional;
- (void)derivedCategoryProtocolMethod1Optional;
@end

@protocol TNSDerivedCategoryProtocol2 <TNSDerivedCategoryProtocol1>
@property int derivedCategoryProtocolProperty2;
@property (class) int derivedCategoryProtocolProperty2;
+ (void)derivedCategoryProtocolMethod2;
- (instancetype)initDerivedCategoryProtocolMethod2;
- (void)derivedCategoryProtocolMethod2;

@optional
@property int derivedCategoryProtocolProperty2Optional;
@property (class) int derivedCategoryProtocolProperty2Optional;
+ (void)derivedCategoryProtocolMethod2Optional;
- (instancetype)initDerivedCategoryProtocolMethod2Optional;
- (void)derivedCategoryProtocolMethod2Optional;
@end

@interface TNSDerivedInterface (TNSDerivedCategory) <TNSDerivedCategoryProtocol2>
@property int derivedCategoryProperty;
@property (class) int derivedCategoryProperty;
+ (void)derivedCategoryMethod;
- (instancetype)initDerivedCategoryMethod;
- (void)derivedCategoryMethod;
@end
