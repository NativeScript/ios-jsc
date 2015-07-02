//
//  TNSApi.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 3/10/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

typedef NS_ENUM(NSInteger, TNSEnums) {
    TNSEnum1 = -1,
    TNSEnum2,
    TNSEnum3,
};

typedef NS_OPTIONS(NSInteger, TNSOptions){
    TNSOption1 = 1 << 0,
    TNSOption2 = 1 << 1,
    TNSOption3 = 1 << 2,
};

enum {
    AnonymousEnumField = -1
};

extern NSString* const TNSConstant;

void functionThrowsException();

@interface TNSApi : NSObject

@property(getter=customGetter, setter=customSetter:) int property;

typedef UIColor NIKColor;
@property(strong, nonatomic) NIKColor* strokeColor; // ^{UIColor=#}

+ (void)methodThrowsException;
- (void)methodThrowsException;

- (void)methodCalledInDealloc;

+ (BOOL)method:(NSInteger)errorCode error:(NSError**)outError;
@end

@interface TNSConflictingSelectorTypes1 : NSObject
+ (void)method:(long long)x;
- (void)method:(long long)x;
@end

@interface TNSConflictingSelectorTypes2 : NSObject
+ (id)method:(id)x;
- (id)method:(id)x;
@end

@interface TNSSwizzleKlass : NSObject
@property(assign) int aProperty;
+ (int)staticMethod:(int)x;
- (int)instanceMethod:(int)x;
@end
