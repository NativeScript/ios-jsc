//
//  TKLiveSync.m
//  TKLiveSync
//
//  Created by Tsvetan Raikov on 6/16/16.
//  Copyright © 2016 Telerik. All rights reserved.
//

#import "TKLiveSync.h"
#import "SSZipArchive.h"

__attribute__((constructor))
static void TKLiveSyncInit() {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *appPath = [NSString pathWithComponents:@[ libraryPath, @"Application Support", @"LiveSync" ]];
    NSString *syncZipPath = [NSString pathWithComponents:@[ libraryPath, @"Application Support", @"LiveSync", @"sync.zip" ]];

    if ([fileManager fileExistsAtPath:syncZipPath]) {
        NSError *err;
        if ([fileManager fileExistsAtPath:appPath]) {
            [fileManager removeItemAtPath:appPath error:&err];
            if (err) {
                NSLog(@"Can't remove: %@", appPath);
            }
        }
        [fileManager createDirectoryAtPath:appPath withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
            NSLog(@"Can't create: %@", appPath);
        }
        NSLog(@"Unzipping %@", syncZipPath);
        [SSZipArchive unzipFileAtPath:syncZipPath toDestination:appPath];
        NSLog(@"Unzip finished!");
    }
}
