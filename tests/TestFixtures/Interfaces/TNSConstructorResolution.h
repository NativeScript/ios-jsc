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

@protocol TNSCProtocol
// Ensure we have unimplemented methods before and after
// the implemented ones (in alphabetical order)
@optional
- (id)initAWithIntNotImplemented:(int)x andInt:(int)y andInt:(int)z;

@required
- (id)initWithInt:(int)x andInt:(int)y;

@optional
- (id)initWithStringOptional:(NSString*)x andString:(NSString*)y;
- (id)initZWithIntNotImplemented:(int)x andInt:(int)y andInt:(int)z;
@end

@interface TNSCInterface : NSObject <TNSCProtocol>
- (id)initWithEmpty;
- (id)initWithPrimitive:(int)x;
- (id)initWithStructure:(TNSCStructure)x;
- (id)initWithString:(NSString*)x;
- (id)initWithParameter1:(NSString*)x parameter2:(NSString*)y error:(NSError**)error;
- (id)initWithConflict1:(NSString*)x conflict2:(NSString*)y conflict3:(NSString*)z;
- (id)initWithConflict1_:(NSString*)x conflict2_:(NSString*)y conflict3_:(NSString*)z;
@end
