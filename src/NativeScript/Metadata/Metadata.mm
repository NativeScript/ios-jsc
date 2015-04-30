//
//  Metadata.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 8/1/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include <UIKit/UIKit.h>
#include "Metadata.h"

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
    UInt8 majorVersion = (UInt8)([version characterAtIndex:0] - '0');
    UInt8 minorVersion = (UInt8)([version characterAtIndex:2] - '0');

    iosVersion = (majorVersion << 3) | minorVersion;

    return iosVersion;
}

bool startsWith(const char* pre, const char* str) {
    size_t lenpre = strlen(pre),
           lenstr = strlen(str);
    return lenstr < lenpre ? false : strncmp(pre, str, lenpre) == 0;
}

// Meta
bool Meta::isAvailable() const {
    UInt8 introducedIn = this->introducedIn();
    UInt8 systemVersion = getSystemVersion();

    return !((introducedIn != 0) && (introducedIn > systemVersion));
}

// BaseClassMeta
MetaFileOffset BaseClassMeta::offsetOf(MemberType type) const {
    MetaFileOffset offset = 0;
    switch (type) {
    case InstanceMethod:
        offset = this->_instanceMethods;
        break;
    case StaticMethod:
        offset = this->_staticMethods;
        break;
    case Property:
        offset = this->_properties;
        break;
    }
    return offset;
}

MemberMeta* BaseClassMeta::member(const char* identifier, size_t length, MemberType type, bool includeProtocols) const {
    MetaFileOffset offset = this->offsetOf(type);

    int resultIndex = -1;

    if (offset != 0) {
        resultIndex = getMetadata()->moveInHeap(offset)->findInSortedMetaArray(identifier, length);
    }

    if (resultIndex >= 0)
        return (MemberMeta*)getMetadata()->moveWithCounts(1)->moveWithOffsets(resultIndex)->follow()->readMeta();

    // search in protcols
    if (includeProtocols) {
        for (auto protocolIterator = this->getProtocolsIterator(); protocolIterator.hasNext(); protocolIterator.next()) {
            if (MemberMeta* method = protocolIterator.currentItem()->member(identifier, length, type, true)) {
                return method;
            }
        }
    }

    return nullptr;
}

std::vector<PropertyMeta*> BaseClassMeta::propertiesWithProtocols(std::vector<PropertyMeta*>& container) {
    this->properties(container);
    for (auto protocolIterator = this->getProtocolsIterator(); protocolIterator.hasNext(); protocolIterator.next()) {
        protocolIterator.currentItem()->propertiesWithProtocols(container);
    }
    return container;
}

vector<MethodMeta*> BaseClassMeta::initializers(vector<MethodMeta*>& container) const {
    // search in instance methods
    int16_t firstInitIndex = this->initializersStartIndex();
    if (firstInitIndex != -1) {
        auto methodIter = this->getInstanceMethodsIterator();
        methodIter.jumpTo(firstInitIndex);
        for (; methodIter.hasNext(); methodIter.next()) {
            MethodMeta* method = methodIter.currentItem();
            if (startsWith("init", method->jsName())) {
                container.push_back(method);
            }
            else {
                break;
            }
        }
    }

    return container;
}

vector<MethodMeta*> BaseClassMeta::initializersWithProtcols(vector<MethodMeta*>& container) const {
    this->initializers(container);
    for (auto protocolIterator = this->getProtocolsIterator(); protocolIterator.hasNext(); protocolIterator.next()) {
        protocolIterator.currentItem()->initializersWithProtcols(container);
    }

    return container;
}
}