//
//  TNSFunctions.m
//  NativeScriptTests
//
//  Created by Yavor Georgiev on 25.02.14.
//  Copyright (c) 2014 г. Jason Zhekov. All rights reserved.
//

#import "TNSFunctions.h"

CFArrayRef CFArrayCreateWithString(CFStringRef string) {
    const void *values[] = {string};
    return CFArrayCreate(kCFAllocatorDefault, values, 1, &kCFTypeArrayCallBacks);
}
