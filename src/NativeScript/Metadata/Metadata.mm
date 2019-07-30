//
//  Metadata.mm
//  NativeScript
//
//  Created by Ivan Buhov on 8/1/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "Metadata.h"
#include "SymbolLoader.h"
#include <UIKit/UIKit.h>
#include <sys/stat.h>

namespace Metadata {

using namespace std;

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

    return iosVersion = encodeVersion(majorVersion, minorVersion);
}
std::unordered_map<std::string, MembersCollection> getMetasByJSNames(MembersCollection members) {
    std::unordered_map<std::string, MembersCollection> result;
    for (auto member : members) {
        result[member->jsName()].add(member);
    }
    return result;
}

static int compareIdentifiers(const char* nullTerminated, const char* notNullTerminated, size_t length) {
    int result = strncmp(nullTerminated, notNullTerminated, length);
    return (result == 0) ? strlen(nullTerminated) - length : result;
}

const InterfaceMeta* GlobalTable::findInterfaceMeta(WTF::StringImpl* identifier) const {
    return this->findInterfaceMeta(reinterpret_cast<const char*>(identifier->utf8().data()), identifier->length(), identifier->hash());
}

const InterfaceMeta* GlobalTable::findInterfaceMeta(const char* identifierString) const {
    unsigned hash = WTF::StringHasher::computeHashAndMaskTop8Bits<LChar>(reinterpret_cast<const LChar*>(identifierString));
    return this->findInterfaceMeta(identifierString, strlen(identifierString), hash);
}

const InterfaceMeta* GlobalTable::findInterfaceMeta(const char* identifierString, size_t length, unsigned hash) const {
    const Meta* meta = MetaFile::instance()->globalTable()->findMeta(identifierString, length, hash, /*onlyIfAvailable*/ false);
    if (meta == nullptr) {
        return nullptr;
    }

    // Meta should be an interface, but it could also be a protocol in case of a
    // private interface having the same name as a public protocol
    assert(meta->type() == MetaType::Interface || (meta->type() == MetaType::ProtocolType && objc_getClass(meta->name()) != nullptr && objc_getProtocol(meta->name()) != nullptr));

    if (meta->type() != MetaType::Interface) {
        return nullptr;
    }

    const InterfaceMeta* interfaceMeta = static_cast<const InterfaceMeta*>(meta);
    if (interfaceMeta->isAvailable()) {
        return interfaceMeta;
    } else {
        const char* baseName = interfaceMeta->baseName();

        NSLog(@"** \"%s\" introduced in iOS SDK %d.%d is currently unavailable, attempting to load its base: \"%s\". **",
              std::string(identifierString, length).c_str(),
              getMajorVersion(interfaceMeta->introducedIn()),
              getMinorVersion(interfaceMeta->introducedIn()),
              baseName);

        return this->findInterfaceMeta(baseName);
    }
}

const ProtocolMeta* GlobalTable::findProtocol(WTF::StringImpl* identifier) const {
    return this->findProtocol(reinterpret_cast<const char*>(identifier->utf8().data()), identifier->length(), identifier->hash());
}

const ProtocolMeta* GlobalTable::findProtocol(const char* identifierString) const {
    unsigned hash = WTF::StringHasher::computeHashAndMaskTop8Bits<LChar>(reinterpret_cast<const LChar*>(identifierString));
    return this->findProtocol(identifierString, strlen(identifierString), hash);
}

const ProtocolMeta* GlobalTable::findProtocol(const char* identifierString, size_t length, unsigned hash) const {
    // Do not check for availability when returning a protocol. Apple regularly create new protocols and move
    // existing interface members there (e.g. iOS 12.0 introduced the UIFocusItemScrollableContainer protocol
    // in UIKit which contained members that have existed in UIScrollView since iOS 2.0)

    auto meta = this->findMeta(identifierString, length, hash, /*onlyIfAvailable*/ false);
    ASSERT(!meta || meta->type() == ProtocolType);
    return static_cast<const ProtocolMeta*>(meta);
}

const Meta* GlobalTable::findMeta(WTF::StringImpl* identifier, bool onlyIfAvailable) const {
    return this->findMeta(reinterpret_cast<const char*>(identifier->utf8().data()), identifier->length(), identifier->hash(), onlyIfAvailable);
}

const Meta* GlobalTable::findMeta(const char* identifierString, bool onlyIfAvailable) const {
    unsigned hash = WTF::StringHasher::computeHashAndMaskTop8Bits<LChar>(reinterpret_cast<const LChar*>(identifierString));
    return this->findMeta(identifierString, strlen(identifierString), hash, onlyIfAvailable);
}

const Meta* GlobalTable::findMeta(const char* identifierString, size_t length, unsigned hash, bool onlyIfAvailable) const {
    int bucketIndex = hash % buckets.count;
    if (this->buckets[bucketIndex].isNull()) {
        return nullptr;
    }
    const ArrayOfPtrTo<Meta>& bucketContent = buckets[bucketIndex].value();
    for (ArrayOfPtrTo<Meta>::iterator it = bucketContent.begin(); it != bucketContent.end(); it++) {
        const Meta* meta = (*it).valuePtr();
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

// MethodMeta class
bool MethodMeta::isImplementedInClass(Class klass, bool isStatic) const {
    // class can be null for Protocol prototypes, treat all members in a protocol as implemented
    if (klass == nullptr) {
        return true;
    }

    // Some members are implemented by extension of classes defined in a different
    // module than the class, ensure they've been initialized
    NativeScript::SymbolLoader::instance().ensureModule(this->topLevelModule());

    if (isStatic) {
        return [klass respondsToSelector:this->selector()] || ([klass resolveClassMethod:this->selector()]);
    } else {
        if ([klass instancesRespondToSelector:this->selector()] || [klass resolveInstanceMethod:this->selector()]) {
            return true;
        }

        // Last resort - allocate an object and ask it if it supports the selector.
        // There are two kinds of scenarios that need this additional check:
        //   1. The `alloc` method is overridden and returns an instance of another class
        //      E.g. [NSAttributedString alloc] returns a NSConcreteAttributedString*
        //   2. The message is forwarded to another object. E.g. `UITextField` forwards
        //      `autocapitalizationType` to an instance of `UITextInputTraits`
        static std::unordered_map<Class, id> sampleInstances;

        auto it = sampleInstances.find(klass);
        if (it == sampleInstances.end()) {
            it = sampleInstances.insert(std::make_pair(klass, [klass alloc])).first;
        }
        id sampleInstance = it->second;
        return [sampleInstance respondsToSelector:this->selector()];
    }
}

// BaseClassMeta

std::set<const ProtocolMeta*> BaseClassMeta::protocolsSet() const {
    std::set<const ProtocolMeta*> protocols;
    this->forEachProtocol([&protocols](const ProtocolMeta* protocolMeta) {
        protocols.insert(protocolMeta);
    },
                          /*additionalProtocols*/ nullptr);

    return protocols;
}

std::set<const ProtocolMeta*> BaseClassMeta::deepProtocolsSet() const {
    std::set<const ProtocolMeta*> protocols;
    this->deepProtocolsSet(protocols);
    return protocols;
}

void BaseClassMeta::deepProtocolsSet(std::set<const ProtocolMeta*>& protocols) const {
    if (this->type() == Interface) {
        auto interfaceMeta = static_cast<const InterfaceMeta*>(this);
        if (auto baseMeta = interfaceMeta->baseMeta()) {
            baseMeta->deepProtocolsSet(protocols);
        }
    }

    this->forEachProtocol([&protocols](const ProtocolMeta* protocolMeta) {
        protocolMeta->deepProtocolsSet(protocols);
        protocols.insert(protocolMeta);
    },
                          /*additionalProtocols*/ nullptr);
}

const MemberMeta* BaseClassMeta::member(const char* identifier, size_t length, MemberType type,
                                        bool includeProtocols, bool onlyIfAvailable,
                                        const ProtocolMetas& additionalProtocols) const {

    MembersCollection members = this->members(identifier, length, type, includeProtocols, onlyIfAvailable, additionalProtocols);

    // It's expected to receive only one occurence when member is used. If more than one results can
    // be found consider (1) using BaseClassMeta::members to process all of them; or (2) fixing metadata
    // generator to disambiguate and remove the redundant one(s); or (3) modify this method so that it doesn't arbitrary
    // choose one and drop the other(s) but deterministically decides which one has to be returned.
    ASSERT(members.size() <= 1);

    return members.size() > 0 ? *members.begin() : nullptr;
}

void collectInheritanceChainMembers(const char* identifier, size_t length, MemberType type, bool onlyIfAvailable, const BaseClassMeta* meta, std::function<void(const MemberMeta*)> collectMember) {

    const ArrayOfPtrTo<MemberMeta>* members = nullptr;
    // Scan method overloads (methods with different selectors and number of arguments which have the same jsName)
    // in base classes. Properties cannot be overridden like that so there's no need to traverse the hierarchy.
    bool shouldScanForOverrides = true;
    switch (type) {
    case MemberType::InstanceMethod:
        members = &meta->instanceMethods->castTo<PtrTo<MemberMeta>>();
        break;
    case MemberType::StaticMethod:
        members = &meta->staticMethods->castTo<PtrTo<MemberMeta>>();
        break;
    case MemberType::InstanceProperty:
        shouldScanForOverrides = false;
        members = &meta->instanceProps->castTo<PtrTo<MemberMeta>>();
        break;
    case MemberType::StaticProperty:
        shouldScanForOverrides = false;
        members = &meta->staticProps->castTo<PtrTo<MemberMeta>>();
        break;
    }

    int resultIndex = -1;
    resultIndex = members->binarySearchLeftmost([&](const PtrTo<MemberMeta>& member) { return compareIdentifiers(member->jsName(), identifier, length); });

    if (resultIndex >= 0) {
        for (const MemberMeta* m = (*members)[resultIndex].valuePtr();
             resultIndex < members->count && (strncmp(m->jsName(), identifier, length) == 0 && strlen(m->jsName()) == length);
             m = (*members)[++resultIndex].valuePtr()) {
            if (m->isAvailable() || !onlyIfAvailable) {
                collectMember(m);
            }
        }

        if (shouldScanForOverrides && meta->type() == MetaType::Interface) {
            const BaseClassMeta* superClass = static_cast<const InterfaceMeta*>(meta)->baseMeta();
            if (superClass) {
                collectInheritanceChainMembers(identifier, length, type, onlyIfAvailable, superClass, collectMember);
            }
        }
    }

    // Instance members of NSObject can be called as static as well (e.g. [NSString performSelector:@selector(alloc)]
    static const char* nsObject = "NSObject";
    static const int nsObjectLen = strlen(nsObject);
    if (strncmp(meta->name(), nsObject, nsObjectLen + 1) == 0) {
        if (type == MemberType::StaticMethod) {
            collectInheritanceChainMembers(identifier, length, MemberType::InstanceMethod, onlyIfAvailable, meta, collectMember);
        } else if (type == MemberType::StaticProperty) {
            collectInheritanceChainMembers(identifier, length, MemberType::InstanceProperty, onlyIfAvailable, meta, collectMember);
        }
    }
}

const MembersCollection BaseClassMeta::members(const char* identifier, size_t length, MemberType type,
                                               bool includeProtocols, bool onlyIfAvailable,
                                               const ProtocolMetas& additionalProtocols) const {

    MembersCollection result;

    if (type == MemberType::InstanceMethod || type == MemberType::StaticMethod) {

        // We need to return base class members as well. Otherwise,
        // if an overloaded method is overriden by a derived class
        // the FunctionWrapper's *functionsContainer* will contain
        // overriden members metas only.
        std::map<int, const MemberMeta*> membersMap;
        collectInheritanceChainMembers(identifier, length, type, onlyIfAvailable, this, [&](const MemberMeta* member) {
            const MethodMeta* method = static_cast<const MethodMeta*>(member);
            membersMap.emplace(method->encodings()->count, member);
        });
        for (std::map<int, const MemberMeta*>::iterator it = membersMap.begin(); it != membersMap.end(); ++it) {
            result.add(it->second);
        }

    } else { // member is a property
        collectInheritanceChainMembers(identifier, length, type, onlyIfAvailable, this, [&](const MemberMeta* member) {
            result.add(member);
        });
    }

    if (result.size() > 0) {
        return result;
    }

    // search in protocols
    if (includeProtocols) {
        this->forEachProtocol([&result, identifier, length, type, includeProtocols, onlyIfAvailable](const ProtocolMeta* protocolMeta) {
            const MembersCollection members = protocolMeta->members(identifier, length, type, includeProtocols, onlyIfAvailable, ProtocolMetas());
            result.add(members.begin(), members.end());
        },
                              &additionalProtocols);
    }

    return result;
}

std::vector<const PropertyMeta*> BaseClassMeta::instancePropertiesWithProtocols(std::vector<const PropertyMeta*>& container, KnownUnknownClassPair klasses, const ProtocolMetas& additionalProtocols) const {
    this->instanceProperties(container, klasses);
    this->forEachProtocol([&container, klasses](const ProtocolMeta* protocolMeta) {
        protocolMeta->instancePropertiesWithProtocols(container, klasses, ProtocolMetas());
    },
                          &additionalProtocols);
    return container;
}

std::vector<const PropertyMeta*> BaseClassMeta::staticPropertiesWithProtocols(std::vector<const PropertyMeta*>& container, KnownUnknownClassPair klasses, const ProtocolMetas& additionalProtocols) const {
    this->staticProperties(container, klasses);
    this->forEachProtocol([&container, klasses](const ProtocolMeta* protocolMeta) {
        protocolMeta->staticPropertiesWithProtocols(container, klasses, ProtocolMetas());
    },
                          &additionalProtocols);
    return container;
}

vector<const MethodMeta*> BaseClassMeta::initializers(vector<const MethodMeta*>& container, KnownUnknownClassPair klasses) const {
    // search in instance methods
    int16_t firstInitIndex = this->initializersStartIndex;
    if (firstInitIndex != -1) {
        for (int i = firstInitIndex; i < instanceMethods->count; i++) {
            const MethodMeta* method = instanceMethods.value()[i].valuePtr();
            if (!method->isInitializer()) {
                break;
            }

            if (method->isAvailableInClasses(klasses, /*isStatic*/ false)) {
                container.push_back(method);
            }
        }
    }
    return container;
}

vector<const MethodMeta*> BaseClassMeta::initializersWithProtocols(vector<const MethodMeta*>& container, KnownUnknownClassPair klasses, const ProtocolMetas& additionalProtocols) const {
    this->initializers(container, klasses);
    for (Array<String>::iterator it = this->protocols->begin(); it != this->protocols->end(); it++) {
        const ProtocolMeta* protocolMeta = MetaFile::instance()->globalTable()->findProtocol((*it).valuePtr());
        if (protocolMeta != nullptr)
            protocolMeta->initializersWithProtocols(container, klasses, ProtocolMetas());
    }
    for (const ProtocolMeta* protocolMeta : additionalProtocols) {
        protocolMeta->initializersWithProtocols(container, klasses, ProtocolMetas());
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

static MetaFile* metaFileInstance(nullptr);

MetaFile* MetaFile::instance() {
    return metaFileInstance;
}

MetaFile* MetaFile::setInstance(void* metadataPtr) {
    metaFileInstance = reinterpret_cast<MetaFile*>(metadataPtr);
    return metaFileInstance;
}
}
