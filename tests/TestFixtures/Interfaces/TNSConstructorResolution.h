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
- (id)initWithPrimitive:(int)x;
- (id)initWithStructure:(TNSCStructure)x;
- (id)initWithString:(NSString*)x;
@end
