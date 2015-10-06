//
//  TNSBridgedTypes.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 6/10/15.
//  Copyright (c) 2015 Jason Zhekov. All rights reserved.
//

#import "TNSBridgedTypes.h"

TNSObjectRef TNSObjectGet() {
    static NSObject* object;
    if (!object) {
        object = [[NSObject alloc] init];
    }
    return (__bridge TNSObjectRef)(object);
}

TNSMutableObjectRef TNSMutableObjectGet() {
    static NSObject* object;
    if (!object) {
        object = [[NSObject alloc] init];
    }
    return (__bridge TNSMutableObjectRef)(object);
}
