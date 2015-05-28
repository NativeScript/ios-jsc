//
//  main.m
//  TodayExtension
//
//  Created by Jason Zhekov on 5/7/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NativeScript/NativeScript.h>

static TNSRuntime* runtime;

__attribute__((constructor))
static void initRuntime() {
    runtime = [[TNSRuntime alloc] initWithApplicationPath:[NSBundle mainBundle].bundlePath];
    TNSRuntimeInspector.logsToSystemConsole = YES;

    [runtime executeModule:@"./"];
}
