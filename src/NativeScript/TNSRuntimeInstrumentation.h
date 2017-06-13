//
//  TNSRuntime+Inspector.h
//  NativeScript
//
//  Created by Panayot Cankov on 06.13.17.
//  Copyright (c) 2014 г. Progress. All rights reserved.
//

#import "TNSRuntime.h"
#import <Foundation/Foundation.h>

@interface TNSRuntimeInstrumentation : NSObject

+ (void)initWithApplicationPath: (NSString*) path;
+ (id) profile: (NSString*) name withBlock: (id (^)())block;
+ (id) profileBlock: (id (^)()) block withName: (NSString* (^)()) nameBlock;

@end
