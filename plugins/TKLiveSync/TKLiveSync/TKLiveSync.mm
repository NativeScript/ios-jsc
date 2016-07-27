//
//  TKLiveSync.m
//  TKLiveSync
//
//  Created by Tsvetan Raikov on 6/16/16.
//  Copyright © 2016 Telerik. All rights reserved.
//

#import "TKLiveSync.h"
#include "libzip_ios/zip.h"
#include <libgen.h>
#include <time.h>
#include <utime.h>
#include <sys/stat.h>
#include <string>

static void mkdir_rec(const char *dir)
{
    char opath[256];
    snprintf(opath, sizeof(opath), "%s", dir);
    size_t len = strlen(opath);

    if (opath[len - 1] == '/')
        opath[len - 1] = 0;

    for (char *p = opath + 1; *p; p++)
    {
        if (*p == '/')
        {
            *p = 0;
            mkdir(opath, S_IRWXU);
            *p = '/';
        }
    }
    
    mkdir(opath, S_IRWXU);
}

// Copied from https://github.com/NativeScript/android-runtime/blob/v2.1.0/runtime/src/main/jni/AssetExtractor.cpp
static int64_t unzip(const char* syncZipPath, const char* destination) {
    int err = 0;
    auto z = zip_open(syncZipPath, 0, &err);

    assert(z != nullptr);
    zip_int64_t num = zip_get_num_entries(z, 0);
    struct zip_stat sb;
    struct zip_file *zf;
    char buf[65536];
    auto pathcopy = new char[1024];

    for (zip_int64_t i = 0; i < num; i++)
    {
        zip_stat_index(z, i, ZIP_STAT_MTIME, &sb);
        auto name = sb.name;

        std::string assetFullname { destination };
        assetFullname.append("/");
        assetFullname.append(name);

        struct stat attrib;
        auto shouldOverwrite = true;
        int ret = stat(assetFullname.c_str(), &attrib);
        if (ret == 0 /* file exists */)
        {
            auto diff = difftime(sb.mtime, attrib.st_mtime);
            shouldOverwrite = diff > 0;
        }

        if (shouldOverwrite)
        {
            strcpy(pathcopy, name);
            auto path = dirname(pathcopy);
            std::string dirFullname(destination);
            dirFullname.append("/");
            dirFullname.append(path);
            mkdir_rec(dirFullname.c_str());

            zf = zip_fopen_index(z, i, 0);
            assert(zf != nullptr);

            auto fd = fopen(assetFullname.c_str(), "w");

            if (fd != nullptr)
            {
                zip_int64_t sum = 0;
                while (sum != sb.size)
                {
                    zip_int64_t len = zip_fread(zf, buf, sizeof(buf));
                    assert(len > 0);

                    fwrite(buf, 1, static_cast<size_t>(len), fd);
                    sum += len;
                }
                fclose(fd);

                utimbuf t;
                t.modtime = sb.mtime;
                ret = utime(assetFullname.c_str(), &t);
            }

            zip_fclose(zf);
        }
    }
    delete[] pathcopy;
    zip_close(z);

    return num;
}

__attribute__((constructor))
static void TKLiveSyncInit() {
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *liveSyncPath = [NSString pathWithComponents:@[ libraryPath, @"Application Support", @"LiveSync" ]];
    NSString *syncZipPath = [NSString pathWithComponents:@[ liveSyncPath, @"sync.zip" ]];

    if ([fileManager fileExistsAtPath:syncZipPath]) {
        NSError *err;

        NSString *appPath = [NSString pathWithComponents:@[ liveSyncPath, @"app" ]];
        if ([fileManager fileExistsAtPath:appPath]) {
            [fileManager removeItemAtPath:appPath error:&err];
            if (err) {
                NSLog(@"Can't remove: %@", appPath);
            }
        }

        NSLog(@"Unzipping LiveSync folder. This could take a while ...");
        NSDate* startDate = [NSDate date];
        int64_t unzippedFilesCount = unzip(syncZipPath.UTF8String, liveSyncPath.UTF8String);
        NSLog(@"Unzipped %lld entries in %fms.", unzippedFilesCount, -[startDate timeIntervalSinceNow] * 1000);

        [fileManager removeItemAtPath:syncZipPath error:&err];
        if (err) {
            NSLog(@"Can't remove: %@", syncZipPath);
        }
    }
}
