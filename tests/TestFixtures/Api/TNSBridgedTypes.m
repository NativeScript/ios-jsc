//
//  TNSBridgedTypes.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 6/10/15.
//  Copyright (c) 2015 Jason Zhekov. All rights reserved.
//

#import "TNSBridgedTypes.h"

TNSBridgedTypeRef TNSBridgedGet() {
    static NSObject* object;
    if (!object) {
        object = [[NSObject alloc] init];
    }
    return (void*)(object);
}

TNSMutableBridgedTypeRef TNSMutableBridgedGet() {
    static NSObject* object;
    if (!object) {
        object = [[NSObject alloc] init];
    }
    return (void*)(object);
}

TNSRelatedTypeRef TNSRelatedGet() {
    static NSObject* object;
    if (!object) {
        object = [[NSObject alloc] init];
    }
    return (void*)(object);
}
