#ifndef ConstructorHashKey_h
#define ConstructorHashKey_h

#include <Metadata/Metadata.h>

namespace NativeScript {

static bool operator<(Metadata::ProtocolMetaVector a, Metadata::ProtocolMetaVector b) {
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

struct ConstructorHashKey {
    Metadata::KnownUnknownClassPair klasses;
    Metadata::ProtocolMetaVector additionalProtocols;

    bool operator==(const ConstructorHashKey& other) const {
        return klasses == other.klasses && additionalProtocols == other.additionalProtocols;
    }

    bool operator<(const ConstructorHashKey& other) const {
        return klasses < other.klasses || (klasses == other.klasses && additionalProtocols < other.additionalProtocols);
    }

    static const NativeScript::ConstructorHashKey EmptyValue;
    static const NativeScript::ConstructorHashKey DeletedValue;
};

} // namespace NativeScript

namespace WTF {

struct ProtocolVectorHash {
    static unsigned hash(const Metadata::ProtocolMetaVector& v) {
        unsigned hash = DefaultHash<size_t>::Hash::hash(v.size());

        for (unsigned i = 0; i < v.size(); i++) {
            hash = pairIntHash(hash, DefaultHash<const Metadata::ProtocolMeta*>::Hash::hash(v[i]));
        }

        return hash;
    }
    static bool equal(const Metadata::ProtocolMetaVector& a, const Metadata::ProtocolMetaVector& b) {
        return hash(a) == hash(b);
    }
    static const bool safeToCompareToEmptyOrDeleted = true;
};

template <>
struct DefaultHash<Metadata::ProtocolMetaVector> { typedef ProtocolVectorHash Hash; };

struct ConstructorHashKeyHash {
    static unsigned hash(const NativeScript::ConstructorHashKey& k) {
        return pairIntHash(DefaultHash<Metadata::KnownUnknownClassPair>::Hash::hash(k.klasses),
                           DefaultHash<Metadata::ProtocolMetaVector>::Hash::hash(k.additionalProtocols));
    }
    static bool equal(const NativeScript::ConstructorHashKey& a, const NativeScript::ConstructorHashKey& b) {
        return hash(a) == hash(b);
    }
    static const bool safeToCompareToEmptyOrDeleted = true;
};

template <>
struct DefaultHash<NativeScript::ConstructorHashKey> { typedef ConstructorHashKeyHash Hash; };

template <>
struct HashTraits<NativeScript::ConstructorHashKey> : GenericHashTraits<NativeScript::ConstructorHashKey> {
    static const bool emptyValueIsZero = false;
    static const bool needsDestruction = true;
    static const bool safeToCompareToEmptyOrDeleted = true;

    static void constructDeletedValue(NativeScript::ConstructorHashKey& slot) {
        slot = NativeScript::ConstructorHashKey::DeletedValue;
    }
    static bool isDeletedValue(NativeScript::ConstructorHashKey value) {
        return value == NativeScript::ConstructorHashKey::DeletedValue;
    }
};

} // namespace WTF

#endif /* ConstructorHashKey_h */
