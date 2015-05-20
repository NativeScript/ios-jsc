//
//  Metadata.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 8/1/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include <UIKit/UIKit.h>
#include <sys/stat.h>
#include "Metadata.h"

namespace Metadata {

using namespace std;

void* loadFileInMemory(const char* filePath) {
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

/**
 * \brief Gets the system version of the current device.
 */
static UInt8 getSystemVersion() {
    static UInt8 iosVersion;
    if (iosVersion != 0) {
        return iosVersion;
    }

    NSString* version = [[UIDevice currentDevice] systemVersion];
    NSArray* versionTokens = [version componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
    UInt8 majorVersion = (UInt8)[versionTokens[0] intValue];
    UInt8 minorVersion = (UInt8)[versionTokens[1] intValue];

    iosVersion = (majorVersion << 3) | minorVersion;

    return iosVersion;
}

bool startsWith(const char* pre, const char* str) {
    size_t lenpre = strlen(pre),
           lenstr = strlen(str);
    return lenstr < lenpre ? false : strncmp(pre, str, lenpre) == 0;
}

int compareIdentifiers(const char* nullTerminated, const char* notNullTerminated, size_t length) {
    int result = strncmp(nullTerminated, notNullTerminated, length);
    return (result == 0) ? strlen(nullTerminated) - length : result;
}

const Meta* GlobalTable::findMeta(WTF::StringImpl* identifier, bool onlyIfAvailable) const {
    return this->findMeta((const char*)identifier->characters8(), identifier->length(), identifier->hash(), onlyIfAvailable);
}

const Meta* GlobalTable::findMeta(const char* identifierString, bool onlyIfAvailable) const {
    unsigned hash = WTF::StringHasher::computeHashAndMaskTop8Bits<LChar>((const LChar*)identifierString);
    return this->findMeta(identifierString, strlen(identifierString), hash, onlyIfAvailable);
}

const Meta* GlobalTable::findMeta(const char* identifierString, size_t length, unsigned hash, bool onlyIfAvailable) const {
    int bucketIndex = hash % buckets.count;
    if (this->buckets[bucketIndex].isNull()) {
        return nullptr;
    }
    ArrayOfPtrTo<Meta>& bucketContent = buckets[bucketIndex].value();
    for (ArrayOfPtrTo<Meta>::iterator it = bucketContent.begin(); it != bucketContent.end(); it++) {
        Meta* meta = (*it).valuePtr();
        if (compareIdentifiers(meta->jsName(), identifierString, length) == 0) {
            return onlyIfAvailable ? (meta->isAvailable() ? meta : nullptr) : meta;
        }
    }
    return nullptr;
}

// Meta
bool Meta::isAvailable() const {
    UInt8 introducedIn = this->introducedIn();
    UInt8 systemVersion = getSystemVersion();
    return introducedIn == 0 || introducedIn <= systemVersion;
}

// BaseClassMeta
MemberMeta* BaseClassMeta::member(const char* identifier, size_t length, MemberType type, bool includeProtocols, bool onlyIfAvailable) const {
    const ArrayOfPtrTo<MemberMeta>* members;
    switch (type) {
    case MemberType::InstanceMethod:
        members = &this->instanceMethods->castTo<PtrTo<MemberMeta>>();
        break;
    case MemberType::StaticMethod:
        members = &this->staticMethods->castTo<PtrTo<MemberMeta>>();
        break;
    case MemberType::Property:
        members = &this->props->castTo<PtrTo<MemberMeta>>();
        break;
    }

    int resultIndex = -1;
    if (members != nullptr) {
        resultIndex = members->binarySearch([&](const PtrTo<MemberMeta>& member) { return compareIdentifiers(member->jsName(), identifier, length); });
    }

    if (resultIndex >= 0) {
        MemberMeta* memberMeta = (*members)[resultIndex].valuePtr();
        return onlyIfAvailable ? (memberMeta->isAvailable() ? memberMeta : nullptr) : memberMeta;
    }

    // search in protcols
    if (includeProtocols) {
        for (Array<String>::iterator it = protocols->begin(); it != protocols->end(); ++it) {
            const ProtocolMeta* protocolMeta = (ProtocolMeta*)MetaFile::instance()->globalTable()->findMeta((*it).valuePtr());
            if (protocolMeta != nullptr) {
                if (MemberMeta* method = protocolMeta->member(identifier, length, type, onlyIfAvailable)) {
                    return method;
                }
            }
        }
    }

    return nullptr;
}

std::vector<PropertyMeta*> BaseClassMeta::propertiesWithProtocols(std::vector<PropertyMeta*>& container) const {
    this->properties(container);
    for (Array<String>::iterator it = protocols->begin(); it != protocols->end(); ++it) {
        const ProtocolMeta* protocolMeta = (ProtocolMeta*)MetaFile::instance()->globalTable()->findMeta((*it).valuePtr(), false);
        if (protocolMeta != nullptr)
            protocolMeta->propertiesWithProtocols(container);
    }
    return container;
}

vector<MethodMeta*> BaseClassMeta::initializers(vector<MethodMeta*>& container) const {
    // search in instance methods
    int16_t firstInitIndex = this->initializersStartIndex;
    if (firstInitIndex != -1) {
        for (int i = firstInitIndex; i < instanceMethods->count; i++) {
            MethodMeta* method = instanceMethods.value()[i].valuePtr();
            if (startsWith("init", method->jsName())) {
                container.push_back(method);
            } else {
                break;
            }
        }
    }
    return container;
}

vector<MethodMeta*> BaseClassMeta::initializersWithProtcols(vector<MethodMeta*>& container) const {
    this->initializers(container);
    for (Array<String>::iterator it = this->protocols->begin(); it != this->protocols->end(); it++) {
        const ProtocolMeta* protocolMeta = (ProtocolMeta*)MetaFile::instance()->globalTable()->findMeta((*it).valuePtr(), false);
        if (protocolMeta != nullptr)
            protocolMeta->initializersWithProtcols(container);
    }
    return container;
}

const Meta* GlobalTable::iterator::getCurrent() {
    return this->_globalTable->buckets[_topLevelIndex].value()[_bucketIndex].valuePtr();
}

GlobalTable::iterator& GlobalTable::iterator::operator++() {
    this->_bucketIndex++;
    this->findNext();
    return *this;
}

const Meta* GlobalTable::iterator::operator*() {
    return this->getCurrent();
}

bool GlobalTable::iterator::operator==(const iterator& other) const {
    return _globalTable == other._globalTable && _topLevelIndex == other._topLevelIndex && _bucketIndex == other._bucketIndex;
}

bool GlobalTable::iterator::operator!=(const iterator& other) const {
    return !(*this == other);
}

void GlobalTable::iterator::findNext() {
    if (this->_topLevelIndex == this->_globalTable->buckets.count) {
        return;
    }

    do {
        if (!this->_globalTable->buckets[_topLevelIndex].isNull()) {
            int bucketLength = this->_globalTable->buckets[_topLevelIndex].value().count;
            while (this->_bucketIndex < bucketLength) {
                if (this->getCurrent() != nullptr) {
                    return;
                }
                this->_bucketIndex++;
            }
        }
        this->_bucketIndex = 0;
        this->_topLevelIndex++;
    } while (this->_topLevelIndex < this->_globalTable->buckets.count);
}

MetaFile* MetaFile::instance() {
    static MetaFile* instance((MetaFile*)loadFileInMemory((std::string("metadata-") + std::string(CURRENT_ARCH) + std::string(".bin")).c_str()));
    return instance;
}
}