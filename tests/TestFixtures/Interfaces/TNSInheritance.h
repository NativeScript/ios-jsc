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
- (void)baseImplementedOptionalMethod;
- (void)baseNotImplementedOptionalMethod;
- (void)baseNotImplementedOptionalMethodImplementedInJavaScript;
@end

@interface TNSIBaseInterface : NSObject <TNSIBaseProtocol>
@end

@interface TNSIBaseInterface (TNSIBaseCategory)
- (void)baseImplementedCategoryMethod;
- (void)baseNotImplementedCategoryMethod;
- (void)baseNotImplementedNativeCategoryMethodOverridenInJavaScript;
@end

@protocol TNSIDerivedProtocol

@optional
- (void)derivedImplementedOptionalMethod;
- (void)derivedNotImplementedOptionalMethod;
- (void)derivedNotImplementedOptionalMethodImplementedInJavaScript;
@end

@interface TNSIDerivedInterface : TNSIBaseInterface <TNSIDerivedProtocol>
@end

@interface TNSIDerivedInterface (TNSIDerivedCategory)
- (void)derivedImplementedCategoryMethod;
- (void)derivedNotImplementedCategoryMethod;
- (void)derivedNotImplementedNativeCategoryMethodOverridenInJavaScript;
@end

@interface TNSIterableConsumer : NSObject

+ (void)consumeIterable:(id<NSFastEnumeration>)iterable;

@end
