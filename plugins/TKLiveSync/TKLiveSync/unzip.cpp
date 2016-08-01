//
//  unzip.cpp
//  TKLiveSync
//
//  Created by Jason Zhekov on 7/29/16.
//  Copyright © 2016 Telerik. All rights reserved.
//

#include "unzip.h"
#include "libzip_ios/zip.h"
#include <assert.h>
#include <libgen.h>
#include <limits.h>
#include <string>
#include <sys/stat.h>

static void mkdir_rec(const char* dir)
{
    char opath[PATH_MAX];
    snprintf(opath, sizeof(opath), "%s", dir);
    size_t len = strlen(opath);

    if (opath[len - 1] == '/')
        opath[len - 1] = 0;

    for (char* p = opath + 1; *p; p++) {
        if (*p == '/') {
            *p = 0;
            mkdir(opath, S_IRWXU);
            *p = '/';
        }
    }

    mkdir(opath, S_IRWXU);
}

int64_t unzip(const char* syncZipPath, const char* destination)
{
    int err = 0;
    auto z = zip_open(syncZipPath, 0, &err);

    assert(z != nullptr);
    zip_int64_t num = zip_get_num_entries(z, 0);
    struct zip_stat sb;
    struct zip_file* zf;
    char buf[65536];
    auto pathcopy = new char[PATH_MAX];

    for (zip_int64_t i = 0; i < num; i++) {
        zip_stat_index(z, i, ZIP_STAT_MTIME, &sb);
        auto name = sb.name;

        std::string assetFullname{ destination };
        assetFullname.append("/");
        assetFullname.append(name);

        strcpy(pathcopy, name);
        auto path = dirname(pathcopy);
        std::string dirFullname(destination);
        dirFullname.append("/");
        dirFullname.append(path);
        mkdir_rec(dirFullname.c_str());

        zf = zip_fopen_index(z, i, 0);
        assert(zf != nullptr);

        auto fd = fopen(assetFullname.c_str(), "w");

        if (fd != nullptr) {
            zip_int64_t sum = 0;
            while (sum != sb.size) {
                zip_int64_t len = zip_fread(zf, buf, sizeof(buf));
                assert(len > 0);

                fwrite(buf, 1, static_cast<size_t>(len), fd);
                sum += len;
            }
            fclose(fd);
        }

        zip_fclose(zf);
    }
    delete[] pathcopy;
    zip_close(z);

    return num;
}
