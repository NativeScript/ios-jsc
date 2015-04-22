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

class MetaFile {

private:
    const void* file;
    MetaArrayCount globalTableSlotsCount;
    MetaFileOffset* globalTableStart;
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
};
}

#endif /* defined(__NativeScript__MetaFile__) */