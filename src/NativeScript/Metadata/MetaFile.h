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

class MetaFile {

private:
    const void* file;
    ArrayCount globalTableSlotsCount;
    Offset* globalTableStart;
    ArrayCount topLevelModulesCount;
    Offset* topLevelModulesTableStart;
    Byte* heapStart;

public:
    MetaFile(const char* filePath);
    MetaFile(void* fileStart);

    const void* goToHeap(Offset offset) const {
        return heapStart + offset;
    }

    const Offset* goToGlobalTable(UInt32 index) const {
        return globalTableStart + index;
    }

    UInt32 getGlobalTableSlotsCount() const {
        return globalTableSlotsCount;
    }

    const Offset* goToModulesTable(UInt32 index) const {
        return topLevelModulesTableStart + index;
    }

    UInt32 getModulesTableCount() const {
        return topLevelModulesCount;
    }
};
}

#endif /* defined(__NativeScript__MetaFile__) */