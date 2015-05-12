//
//  MetaFileReader.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 8/29/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "MetaFileReader.h"
#include "Metadata.h"

namespace Metadata {

std::function<bool(const Meta*)> metaPredicate = [](const Meta* meta) -> bool {
    return meta->isAvailable();
};

static MetaFile metaFile((std::string("metadata-") + std::string(CURRENT_ARCH) + std::string(".bin")).c_str());
static MetaFileReader metaFileReader(metaFile);

MetaFileReader* getMetadata() { return &metaFileReader; }

int compareIdentifiers(const char* nullTerminated, const char* notNullTerminated, size_t length) {
    int result = strncmp(nullTerminated, notNullTerminated, length);
    return (result == 0) ? strlen(nullTerminated) - length : result;
}

const Meta* MetaFileReader::findMeta(const char* identifierString, size_t length, unsigned hash) {
    const void* savedCursor = this->asPointer();

    int gtIndex = hash % file.getGlobalTableSlotsCount();

    this->moveInGlobalTable((UInt32)gtIndex);
    if (this->isNullOffset()) {
        this->moveToPointer(savedCursor);
        return nullptr;
    }
    MetaArrayCount arrayCount = this->follow()->readArrayCount();
    const void* arrayBegin = this->moveWithCounts(1)->asPointer();
    for (MetaArrayCount i = 0; i < arrayCount; i++) {
        const Meta* meta = this->moveWithOffsets(i)->follow()->readMetaDirect();
        const char* jsName = meta->jsName();
        if (compareIdentifiers(jsName, identifierString, length) == 0) {
            this->moveToPointer(savedCursor);
            if (metaPredicate(meta)) {
                return meta;
            } else {
                return nullptr;
            }
        }
        this->moveToPointer(arrayBegin);
    }

    this->moveToPointer(savedCursor);
    return nullptr;
}

int MetaFileReader::findInSortedMetaArray(const char* identifier, int length) {
    const void* savedCursor = this->asPointer();
    MetaArrayCount arrayLength = this->readArrayCount();
    const void* arrayBegin = this->moveWithCounts(1)->asPointer();

    // Binary search
    int left = 0;
    int right = arrayLength - 1;
    int mid = 0;
    while (left <= right) {
        mid = (right + left) / 2;
        const Meta* meta = this->moveWithOffsets(mid)->follow()->readMetaDirect();
        const char* jsName = meta->jsName();
        int comparisonResult = compareIdentifiers(jsName, identifier, length);
        if (comparisonResult < 0) {
            left = mid + 1;
        } else if (comparisonResult > 0) {
            right = mid - 1;
        } else {
            this->moveToPointer(savedCursor);
            return mid;
        }
        this->moveToPointer(arrayBegin);
    }

    this->moveToPointer(savedCursor);
    return -(left + 1);
}

MetaIterator MetaFileReader::begin() {
    return MetaIterator(this);
}

MetaIterator MetaFileReader::end() {
    return MetaIterator(this, this->globalTableSlotsCount());
}

void MetaIterator::findNext() {
    if (this->globalTableIndex == this->globalTableLength) {
        return;
    }

    do {
        this->currentListLength = this->fileReader->moveInGlobalTable(this->globalTableIndex)->follow()->readArrayCount();
        if (!this->fileReader->moveInGlobalTable(this->globalTableIndex)->isNullOffset()) {
            while (this->currentListIndex < this->currentListLength) {
                if (this->getCurrent() != nullptr) {
                    return;
                }
                this->currentListIndex++;
            }
        }
        this->currentListIndex = 0;
        this->globalTableIndex++;
    } while (this->globalTableIndex < this->globalTableLength);
}

const Meta* MetaIterator::getCurrent() {
    return this->fileReader->moveInGlobalTable(globalTableIndex)->follow()->moveWithCounts(1)->moveWithOffsets(currentListIndex)->follow()->readMeta();
}

void MetaIterator::reset(int32_t globalTableIndex) {
    this->currentListIndex = 0;
    this->globalTableIndex = globalTableIndex;
    this->findNext();
}

MetaIterator::MetaIterator(MetaFileReader* fileReader, int32_t globalTableIndex)
    : fileReader(fileReader)
    , globalTableLength(fileReader->globalTableSlotsCount()) {
    this->reset(globalTableIndex);
}

MetaIterator& Metadata::MetaIterator::operator++() {
    this->currentListIndex++;
    this->findNext();
    return *this;
}

const Meta* Metadata::MetaIterator::operator*() {
    return this->getCurrent();
}
}