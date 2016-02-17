//
//  TNSConstructorResolution.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/24/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

typedef struct TNSCStructure {
    int x;
    int y;
} TNSCStructure;

@interface TNSCInterface : NSObject
- (id)initWithEmpty;
- (id)initWithPrimitive:(int)x;
- (id)initWithStructure:(TNSCStructure)x;
- (id)initWithString:(NSString*)x;
- (id)initWithParameter1:(NSString*)x parameter2:(NSString*)y error:(NSError**)error;
@end
