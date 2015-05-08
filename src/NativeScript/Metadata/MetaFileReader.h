//
//  MetaFileReader.h
//  NativeScript
//
//  Created by Ivan Buhov on 8/29/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__MetaFileReader__
#define __NativeScript__MetaFileReader__

#include "MetaFile.h"
#include <functional>

namespace Metadata {

struct Meta;
class MetaIterator;

extern std::function<bool(const Meta*)> metaPredicate;

class MetaFileReader {

private:
    const void* cursor;
    MetaFile file;

    const inline Meta* readMetaDirect() {
        return static_cast<const Meta*>(cursor);
    }

public:
    MetaFileReader(MetaFile file)
        : cursor(0)
        , file(file) {
    }

    MetaFileReader* moveWithBytes(int count) {
        cursor = (Byte*)cursor + count;
        return this;
    }

    MetaFileReader* moveWithOffsets(int count) {
        cursor = (MetaFileOffset*)cursor + count;
        return this;
    }

    MetaFileReader* moveWithCounts(int count) {
        cursor = (MetaArrayCount*)cursor + count;
        return this;
    }

    MetaFileReader* moveInHeap(MetaFileOffset offset) {
        cursor = this->file.goToHeap(offset);
        return this;
    }

    MetaFileReader* moveInGlobalTable(UInt32 index) {
        cursor = this->file.goToGlobalTable(index);
        return this;
    }

    MetaFileReader* moveToPointer(const void* pointer) {
        cursor = pointer;
        return this;
    }

    MetaFileReader* follow() {
        cursor = this->file.goToHeap(this->readOffset());
        return this;
    }

    const char* readString() {
        return (char*)cursor;
    }

    Byte readByte() {
        return *(Byte*)cursor;
    }

    MetaFileOffset readOffset() {
        return *(MetaFileOffset*)cursor;
    }

    const Meta* readMeta() {
        const Meta* meta = readMetaDirect();
        if (metaPredicate(meta)) {
            return meta;
        }
        return nullptr;
    }

    MetaArrayCount readArrayCount() {
        return *(MetaArrayCount*)cursor;
    }

    int16_t read16BitInteger() {
        return *(int16_t*)cursor;
    }

    const void* asPtr() {
        return cursor;
    }
    
    template<typename T>
    const T* asPtrTo() {
        return (T*)cursor;
    }

    MetaFileOffset asOffsetInHeap() {
        return (MetaFileOffset)((Byte*)cursor - (Byte*)this->file.goToHeap(0));
    }

    bool isNullByte() {
        return *(Byte*)cursor == 0;
    }

    bool isNullOffset() {
        return *(MetaFileOffset*)cursor == 0;
    }

    const Meta* findMeta(WTF::StringImpl* identifier) {
        return this->findMeta((const char*)identifier->characters8(), identifier->length(), identifier->hash());
    }

    const Meta* findMeta(const char* identifierString) {
        unsigned hash = WTF::StringHasher::computeHashAndMaskTop8Bits<LChar>((const LChar*)identifierString);
        return this->findMeta(identifierString, strlen(identifierString), hash);
    }

    const Meta* findMeta(const char* identifier, size_t length, unsigned hash);

    int findInSortedMetaArray(const char* identifier, int length);

    MetaArrayCount globalTableSlotsCount() const {
        return this->file.getGlobalTableSlotsCount();
    }

    MetaIterator begin();

    MetaIterator end();
};

MetaFileReader* getMetadata();

int compareIdentifiers(const char* nullTerminated, const char* notNullTerminated, size_t length);

class MetaIterator {
    friend bool operator==(const MetaIterator& a, const MetaIterator& b);

    friend bool operator!=(const MetaIterator& a, const MetaIterator& b);

private:
    MetaFileReader* fileReader;

    MetaArrayCount globalTableLength;
    int32_t globalTableIndex;

    MetaArrayCount currentListLength;
    int32_t currentListIndex;

    void findNext();

    const Meta* getCurrent();

public:
    MetaIterator(MetaFileReader* fileReader)
        : MetaIterator(fileReader, 0) {
    }

    MetaIterator(MetaFileReader* fileReader, int32_t globalTableIndex);

    void reset(int32_t globalTableIndex);

    MetaIterator& operator++();

    const Meta* operator*();
};

inline bool operator==(const MetaIterator& a, const MetaIterator& b) {
    return a.globalTableIndex == b.globalTableIndex && a.currentListIndex == b.currentListIndex;
}

inline bool operator!=(const MetaIterator& a, const MetaIterator& b) {
    return !operator==(a, b);
}
}

#endif /* defined(__NativeScript__MetaFileReader__) */
