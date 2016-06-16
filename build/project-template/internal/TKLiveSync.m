//
//  TKLiveSync.m
//  __PROJECT_NAME__
//
//  Created by Tsvetan Raikov on 6/16/16.
//  Copyright © 2016 Telerik. All rights reserved.
//

#import "TKLiveSync.h"
#import "SSZipArchive.h"

@implementation TKLiveSync

+ (NSString*)initAppFolder {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *appPath = [NSString pathWithComponents:@[ libraryPath, @"Application Support", @"LiveSync", @"app" ]];
    NSString *syncZipPath = [NSString pathWithComponents:@[ libraryPath, @"Application Support", @"LiveSync", @"sync.zip" ]];
    NSError *err;
    if ([fm fileExistsAtPath:syncZipPath]) {
        if ([fm fileExistsAtPath:appPath]) {
            [fm removeItemAtPath:appPath error:&err];
            if (err) {
                NSLog(@"Can't remove: %@", appPath);
            }
        }
        [fm createDirectoryAtPath:appPath withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
            NSLog(@"Can't create: %@", appPath);
        }
        NSLog(@"Unzipping %@", syncZipPath);
        [SSZipArchive unzipFileAtPath:syncZipPath toDestination:appPath uniqueId:nil];
        NSLog(@"Unzip finished!");
        return appPath;
    }
    if ([fm fileExistsAtPath:appPath]) {
        return appPath;
    }
    return [[NSBundle mainBundle] bundlePath];
}

@end
