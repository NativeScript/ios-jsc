//
//  TKLiveSync.m
//  TKLiveSync
//
//  Created by Tsvetan Raikov on 6/16/16.
//  Copyright © 2016 Telerik. All rights reserved.
//

#import "TKLiveSync.h"
#include "unzip.h"

static void tryExtractLiveSyncArchive()
{
    NSFileManager* fileManager = [NSFileManager defaultManager];

    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString* liveSyncPath = [NSString pathWithComponents:@[ libraryPath, @"Application Support", @"LiveSync" ]];
    NSString* syncZipPath = [NSString pathWithComponents:@[ liveSyncPath, @"sync.zip" ]];

    if (![fileManager fileExistsAtPath:syncZipPath]) {
        return;
    }

    NSError* err;

    NSString* appPath = [NSString pathWithComponents:@[ liveSyncPath, @"app" ]];
    if ([fileManager fileExistsAtPath:appPath]) {
        [fileManager removeItemAtPath:appPath error:&err];
        if (err) {
            NSLog(@"Can't remove %@: %@", appPath, err);
        }
    }

    NSLog(@"Unzipping LiveSync folder. This could take a while...");
    NSDate* startDate = [NSDate date];
    int64_t unzippedFilesCount = unzip(syncZipPath.UTF8String, liveSyncPath.UTF8String);
    NSLog(@"Unzipped %lld entries in %fms.", unzippedFilesCount, -[startDate timeIntervalSinceNow] * 1000);

    [fileManager removeItemAtPath:syncZipPath error:&err];
    if (err) {
        NSLog(@"Can't remove %@: %@", syncZipPath, err);
    }
}

static void trySetLiveSyncApplicationPath()
{
    NSFileManager* fileManager = [NSFileManager defaultManager];

    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString* liveSyncPath = [NSString pathWithComponents:@[ libraryPath, @"Application Support", @"LiveSync" ]];
    NSString* appFolderPath = [NSString pathWithComponents:@[ liveSyncPath, @"app" ]];

    if (![fileManager fileExistsAtPath:appFolderPath]) {
        return;
    }

    NSString* nativeScriptModulesPath = [appFolderPath stringByAppendingPathComponent:@"tns_modules"];

    // fileExistsAtPath: returns false if the file is a symlink so using this instead
    if (![fileManager attributesOfItemAtPath:nativeScriptModulesPath error:nil]) {
        NSLog(@"tns_modules folder not livesynced. Using tns_modules from the already deployed bundle...");

        NSString* bundleNativeScriptModulesPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"app/tns_modules"];

        NSError* error;
        if (![fileManager createSymbolicLinkAtPath:nativeScriptModulesPath withDestinationPath:bundleNativeScriptModulesPath error:&error]) {
            NSLog(@"Failed to symlink tns_modules folder: %@", error);
        }
    }

    if (setenv("TNSApplicationPath", liveSyncPath.UTF8String, 0) == -1) {
        perror("Could not set application path");
    }
}

__attribute__((constructor)) static void TKLiveSyncInit()
{
    tryExtractLiveSyncArchive();
    trySetLiveSyncApplicationPath();
}
