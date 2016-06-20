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
    NSString *liveSyncPath = [NSString pathWithComponents:@[ libraryPath, @"Application Support", @"LiveSync" ]];
    NSString *appPath = [NSString pathWithComponents:@[ liveSyncPath, @"app" ]];
    NSString *syncZipPath = [NSString pathWithComponents:@[ liveSyncPath, @"sync.zip" ]];

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
        [SSZipArchive unzipFileAtPath:syncZipPath toDestination:liveSyncPath];
        [fileManager removeItemAtPath:syncZipPath error:&err];
        if (err) {
            NSLog(@"Can't remove: %@", syncZipPath);
        }
    }
}
