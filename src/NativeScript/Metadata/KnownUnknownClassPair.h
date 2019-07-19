//
//  KnownUnknownClassPair.h
//  NativeScript
//
//  Created by Martin Bekchiev on 8.07.19.
//

#ifndef KnownUnknownClassPair_h
#define KnownUnknownClassPair_h

#include <objc/objc.h>
#include <wtf/HashTraits.h>

namespace Metadata {

struct KnownUnknownClassPair {
    Class known;
    Class unknown;

    explicit KnownUnknownClassPair(Class known = nullptr, Class unknown = nullptr)
        : known(known)
        , unknown(unknown) {
    }

    Class realClass() const {
        return unknown ? unknown : known;
    }

    bool operator<(const KnownUnknownClassPair& other) const {
        return known < other.known || (known == other.known && unknown < other.unknown);
    }

    bool operator==(const KnownUnknownClassPair& other) const {
        return known == other.known && unknown == other.unknown;
    }

    static const KnownUnknownClassPair& EmptyValue();
    static const KnownUnknownClassPair& DeletedValue();
};

} // namespace Metadata

namespace WTF {
template <>
struct HashTraits<Metadata::KnownUnknownClassPair> : GenericHashTraits<Metadata::KnownUnknownClassPair> {
    static const bool emptyValueIsZero = true;
    static const bool needsDestruction = false;
    static const bool safeToCompareToEmptyOrDeleted = true;

    static void constructDeletedValue(Metadata::KnownUnknownClassPair& slot) {
        slot = Metadata::KnownUnknownClassPair::DeletedValue();
    }
    static bool isDeletedValue(Metadata::KnownUnknownClassPair value) {
        return value == Metadata::KnownUnknownClassPair::DeletedValue();
    }
};

struct KnownUnknownClassPairHash {
    static unsigned hash(const Metadata::KnownUnknownClassPair& p) {
        return pairIntHash(reinterpret_cast<intptr_t>(p.known), reinterpret_cast<intptr_t>(p.unknown));
    }
    static bool equal(const Metadata::KnownUnknownClassPair& a, const Metadata::KnownUnknownClassPair& b) {
        return a == b;
    }
    static const bool safeToCompareToEmptyOrDeleted = true;
};

template <>
struct DefaultHash<Metadata::KnownUnknownClassPair> { typedef KnownUnknownClassPairHash Hash; };

} // namespace WTF

#endif /* KnownUnknownClassPair_h */
