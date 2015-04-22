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

@interface TNSCInterface11 : NSObject
@end

@protocol TNSCProtocol1
@end

@interface TNSCInterface : NSObject
- (id)init;

- (id)initWithPrimitive:(int)x;
- (id)initWithInterface:(TNSCInterface11*)x;
- (id)initWithStructure:(TNSCStructure)x;
- (id)initWithProtocol:(id<TNSCProtocol1>)x;
- (id)initWithString:(NSString*)x;

- (id)initWithPrimitive:(int)x instance:(TNSCInterface11*)y structure:(TNSCStructure)z protocol:(id<TNSCProtocol1>)a string:(NSString*)b number:(NSNumber*)c;
@end
