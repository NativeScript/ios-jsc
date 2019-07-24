#ifndef ConstructorHashKey_h
#define ConstructorHashKey_h

#include <Metadata/Metadata.h>

namespace NativeScript {

static bool operator<(Metadata::ProtocolMetas a, Metadata::ProtocolMetas b) {
    if (a.size() < b.size()) {
        return true;
    } else if (a.size() == b.size()) {
        for (size_t i = 0; i < a.size(); i++) {
            if (a[i] < b[i]) {
                return true;
            } else if (a[i] > b[i]) {
                return false;
            }
        }
    }

    return false;
}

struct ConstructorKey {
    static const NativeScript::ConstructorKey& EmptyValue();
    static const NativeScript::ConstructorKey& DeletedValue();

    ConstructorKey() {
    }

    explicit ConstructorKey(Class knownClass, Metadata::ProtocolMetas additionalProtocols = Metadata::ProtocolMetas())
        : klasses(knownClass)
        , additionalProtocols(additionalProtocols) {
    }

    explicit ConstructorKey(Class knownClass, Class unknownClass, Metadata::ProtocolMetas additionalProtocols = Metadata::ProtocolMetas())
        : klasses(knownClass, unknownClass)
        , additionalProtocols(additionalProtocols) {
    }

    explicit ConstructorKey(Metadata::KnownUnknownClassPair klasses, Metadata::ProtocolMetas additionalProtocols = Metadata::ProtocolMetas())
        : klasses(klasses)
        , additionalProtocols(additionalProtocols) {
    }

    bool operator==(const ConstructorKey& other) const {
        return klasses == other.klasses && additionalProtocols == other.additionalProtocols;
    }

    bool operator<(const ConstructorKey& other) const {
        return klasses < other.klasses || (klasses == other.klasses && additionalProtocols < other.additionalProtocols);
    }

    Metadata::KnownUnknownClassPair klasses;
    Metadata::ProtocolMetas additionalProtocols;
};

} // namespace NativeScript

namespace WTF {

struct ProtocolVectorHash {
    static unsigned hash(const Metadata::ProtocolMetas& v) {
        unsigned hash = DefaultHash<size_t>::Hash::hash(v.size());

        for (unsigned i = 0; i < v.size(); i++) {
            hash = pairIntHash(hash, DefaultHash<const Metadata::ProtocolMeta*>::Hash::hash(v[i]));
        }

        return hash;
    }
    static bool equal(const Metadata::ProtocolMetas& a, const Metadata::ProtocolMetas& b) {
        return hash(a) == hash(b);
    }
    static const bool safeToCompareToEmptyOrDeleted = true;
};

template <>
struct DefaultHash<Metadata::ProtocolMetas> { typedef ProtocolVectorHash Hash; };

struct ConstructorHashKeyHash {
    static unsigned hash(const NativeScript::ConstructorKey& k) {
        return pairIntHash(DefaultHash<Metadata::KnownUnknownClassPair>::Hash::hash(k.klasses),
                           DefaultHash<Metadata::ProtocolMetas>::Hash::hash(k.additionalProtocols));
    }
    static bool equal(const NativeScript::ConstructorKey& a, const NativeScript::ConstructorKey& b) {
        return hash(a) == hash(b);
    }
    static const bool safeToCompareToEmptyOrDeleted = true;
};

template <>
struct DefaultHash<NativeScript::ConstructorKey> { typedef ConstructorHashKeyHash Hash; };

template <>
struct HashTraits<NativeScript::ConstructorKey> : GenericHashTraits<NativeScript::ConstructorKey> {
    static const bool emptyValueIsZero = false;
    static const bool needsDestruction = true;
    static const bool safeToCompareToEmptyOrDeleted = true;

    static void constructDeletedValue(NativeScript::ConstructorKey& slot) {
        slot = NativeScript::ConstructorKey::DeletedValue();
    }
    static bool isDeletedValue(NativeScript::ConstructorKey value) {
        return value == NativeScript::ConstructorKey::DeletedValue();
    }
};

} // namespace WTF

#endif /* ConstructorHashKey_h */
