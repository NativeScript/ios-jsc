//
//  MetaFile.h
//  NativeScript
//
//  Created by Ivan Buhov on 7/28/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__MetaFile__
#define __NativeScript__MetaFile__

namespace Metadata {

// Offset in metadata file
typedef int32_t MetaFileOffset;
// Elements count for arrays in metadata file
typedef int32_t MetaArrayCount;

#pragma pack(push, 1)
struct MetaFileHead {
    int8_t pointer_size;
    int8_t array_count_size;
    MetaFileOffset modulesOffset;
    MetaFileOffset globalTableOffset;
    MetaFileOffset heapOffset;
};
#pragma pack(pop)

class MetaFile {

private:
    const void* file;
    const MetaFileHead* _head;
    MetaArrayCount globalTableSlotsCount;
    MetaFileOffset* globalTableStart;
    MetaArrayCount moduleTableSlotsCount;
    MetaFileOffset* moduleTableStart;
    Byte* heapStart;

public:
    MetaFile(const char* filePath);
    MetaFile(void* fileStart);

    const void* goToHeap(MetaFileOffset offset) const {
        return heapStart + offset;
    }

    const MetaFileOffset* goToGlobalTable(UInt32 index) const {
        return globalTableStart + index;
    }

    UInt32 getGlobalTableSlotsCount() const {
        return globalTableSlotsCount;
    }

    const MetaFileOffset goToModuleTable(UInt32 index) const {
        return *(moduleTableStart + index);
    }

    UInt32 getModuleTableSlotsCount() const {
        return moduleTableSlotsCount;
    }

    const MetaFileHead* head() const {
        return this->_head;
    }
};
}

#endif /* defined(__NativeScript__MetaFile__) */