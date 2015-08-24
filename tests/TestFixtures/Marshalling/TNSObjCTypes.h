//
//  TNSObjCTypes.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/25/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

typedef struct TNSOStruct {
    int x;
    int y;
    int z;
} TNSOStruct;

void TNSFunctionWithCFTypeRefArgument(CFTypeRef x);
CFTypeRef TNSFunctionWithSimpleCFTypeRefReturn();
CFTypeRef TNSFunctionWithCreateCFTypeRefReturn();

typedef int (^NumberReturner)(int, int, int);

@interface TNSObjCTypes : NSObject
+ (void)methodWithComplexBlock:(id (^)(int, id, SEL, NSObject*, TNSOStruct))block;

- (void)methodWithIdOutParameter:(NSString**)value;
- (void)methodWithLongLongOutParameter:(long long*)value;
- (void)methodWithStructOutParameter:(TNSOStruct*)value;

- (void)methodWithSimpleBlock:(void (^)(void))block;
- (void)methodWithComplexBlock:(id (^)(int, id, SEL, NSObject*, TNSOStruct))block;

- (NumberReturner)methodWithBlockScope:(int)number;
- (id)methodReturningBlockAsId:(int)number;

- (NSDate*)methodWithNSDate:(NSDate*)date;
- (void (^)(void))methodWithBlock:(void (^)(void))block;
- (NSArray*)methodWithNSArray:(NSArray*)array;
- (NSDictionary*)methodWithNSDictionary:(NSDictionary*)dictionary;
- (NSData*)methodWithNSData:(NSData*)data;
- (NSDecimalNumber*)methodWithNSDecimalNumber:(NSDecimalNumber*)number;
- (NSNumber*)methodWithNSCFBool;
- (NSNull*)methodWithNSNull;
@end
