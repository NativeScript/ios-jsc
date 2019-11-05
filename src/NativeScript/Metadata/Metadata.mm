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

const MemberMeta* BaseClassMeta::deepMember(const char* identifier, size_t length, MemberType type, bool includeProtocols, bool onlyIfAvailable, const ProtocolMetas& additionalProtocols) const {
    const MemberMeta* memberMeta = nullptr;

    ProtocolMetas emptyProtocols;
    const ProtocolMetas* protocols = &additionalProtocols;
    for (auto currentClass = this; currentClass != nullptr; currentClass = (currentClass->type() == MetaType::Interface) ? static_cast<const InterfaceMeta*>(currentClass)->baseMeta() : nullptr) {
        if ((memberMeta = currentClass->member(identifier, length, type, includeProtocols, onlyIfAvailable, *protocols))) {
            break;
        }
        // Do not recheck protocols when visiting base classes
        protocols = &emptyProtocols;
    }

    return memberMeta;
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
        const ProtocolMeta* protocolMeta = MetaFile::instance()->globalTableJs()->findProtocol((*it).valuePtr());
        if (protocolMeta != nullptr)
            protocolMeta->initializersWithProtocols(container, klasses, ProtocolMetas());
    }
    for (const ProtocolMeta* protocolMeta : additionalProtocols) {
        protocolMeta->initializersWithProtocols(container, klasses, ProtocolMetas());
    }
    return container;
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
