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

@interface TNSPrivateInterfaceResults : NSObject

// inspired from NSURLSession (see https://github.com/NativeScript/ios-runtime/issues/1149)
//- (NSURLSessionDownloadTask *)downloadTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;
// claim to return TNSIBaseInterface but instances are objects of an unrelated type which implements the methods
+ (TNSIBaseInterface*)instanceFromUnrelatedPrivateType;

// inspired from MTLCreateSystemDefaultDevice
//MTL_EXTERN id <MTLDevice> __nullable MTLCreateSystemDefaultDevice(void) API_AVAILABLE(macos(10.11), ios(8.0)) NS_RETURNS_RETAINED;
+ (id<TNSIBaseProtocol>)instanceFromPrivateTypeImplementingProtocol;

+ (id<TNSIBaseProtocol, TNSIDerivedProtocol>)instanceFromPrivateTypeImplementingTwoProtocols;

+ (id<TNSIBaseProtocol>)instanceFromPublicTypeImplementingProtocol;

@end

@protocol TNSBlacklistedProtocol
@end

@interface TNSBlacklistedInterface : NSObject <TNSBlacklistedProtocol>
@end
