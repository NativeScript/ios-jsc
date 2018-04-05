//
//  TNSRuntime+Inspector.h
//  NativeScript
//
//  Created by Panayot Cankov on 06.13.17.
//  Copyright (c) 2014 г. Progress. All rights reserved.
//

#import "TNSRuntimeInstrumentation.h"
#include "ManualInstrumentation.h"

@implementation TNSRuntimeInstrumentation : NSObject

+ (void)initWithApplicationPath:(NSString*)applicationPath {
    BOOL enable = NO;
    NSString* packageJsonPath = [applicationPath stringByAppendingPathComponent:@"app/package.json"];
    NSData* data = [NSData dataWithContentsOfFile:packageJsonPath];
    if (data) {
        NSError* error = nil;
        id packageJson = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (!error && [@"timeline" isEqual:packageJson[@"profiling"]]) {
            enable = YES;
        }
    }
    if (enable) {
        tns::instrumentation::Frame::enable();
    } else {
        tns::instrumentation::Frame::disable();
    }
}

+ (id)profile:(NSString*)name withBlock:(id (^)())block {
    tns::instrumentation::Frame frame(name.UTF8String);
    return block();
}

+ (id)profileBlock:(id (^)())block withName:(NSString* (^)())nameBlock {
    tns::instrumentation::Frame frame;
    id result = block();
    if (frame.check()) {
        frame.log(nameBlock().UTF8String);
    }
    return result;
}

@end
