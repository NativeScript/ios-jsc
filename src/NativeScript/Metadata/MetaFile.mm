//
//  MetaFile.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 8/5/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "MetaFile.h"
#include <iostream>
#include <sys/stat.h>
#include <stdio.h>

namespace Metadata {

using namespace std;

void* loadFile(const char* filePath) {
    const char* path = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithUTF8String:filePath]] UTF8String];
    int fd = open(path, O_RDONLY);
    if (fd == -1) {
        perror("Could not load metadata file");
        exit(1);
    }
    struct stat fileStat;
    fstat(fd, &fileStat);
    void* file = mmap(NULL, (size_t)fileStat.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    close(fd);
    return file;
}

MetaFile::MetaFile(const char* filePath)
    : MetaFile(loadFile(filePath)) {}

MetaFile::MetaFile(void* fileStart)
    : file(fileStart)
    , globalTableSlotsCount(*(const MetaArrayCount*)this->file)
    , globalTableStart((MetaFileOffset*)((MetaArrayCount*)this->file + 1))
    , heapStart((Byte*)(this->globalTableStart + this->globalTableSlotsCount)) {
}
}