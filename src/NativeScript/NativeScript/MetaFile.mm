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

namespace Metadata {

using namespace std;

void* loadFile(const char* filePath) {
    const char* path = [[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithUTF8String:filePath]] UTF8String];
    int fd = open(path, O_RDONLY);
    struct stat fileStat;
    fstat(fd, &fileStat);
    void* file = mmap(NULL, (size_t)fileStat.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    close(fd);
    return file;
}

MetaFile::MetaFile(const char* filePath)
    : MetaFile(loadFile(filePath)) {}

MetaFile::MetaFile(void* fileStart)
        : file(fileStart),
          _head((const MetaFileHead*)this->file),
          globalTableSlotsCount(*(const MetaArrayCount*)((Byte*)fileStart + this->_head->globalTableOffset)),
          globalTableStart((MetaFileOffset*)((Byte*)fileStart + this->_head->globalTableOffset + this->_head->array_count_size)),
          moduleTableSlotsCount(*(const MetaArrayCount*)((Byte*)fileStart + this->_head->modulesOffset)),
          moduleTableStart((MetaFileOffset*)((Byte*)fileStart + this->_head->modulesOffset + this->_head->array_count_size)),
          heapStart((Byte*)((Byte*)fileStart + this->_head->heapOffset)) { }
}