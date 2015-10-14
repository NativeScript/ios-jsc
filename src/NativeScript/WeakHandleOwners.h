//
//  WeakHandleOwners.h
//  NativeScript
//
//  Created by Ivan Buhov on 11/14/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__WeakHandleOwners__
#define __NativeScript__WeakHandleOwners__

namespace NativeScript {

struct WeakImplHashTraits {
    static unsigned hash(JSC::WeakImpl* key) {
        JSC::JSCell* cell = ((JSC::WeakImpl*)key)->jsValue().asCell();
        return WTF::DefaultHash<JSC::JSCell*>::Hash::hash(cell);
    }
    static bool equal(JSC::WeakImpl* a, JSC::WeakImpl* b) {
        JSC::JSCell* cell1 = ((JSC::WeakImpl*)a)->jsValue().asCell();
        JSC::JSCell* cell2 = ((JSC::WeakImpl*)b)->jsValue().asCell();
        return cell1 == cell2;
    }
    static const bool safeToCompareToEmptyOrDeleted = false;
};

struct WeakImplVectorHashTraits {
    static unsigned hash(WTF::Vector<JSC::WeakImpl*> key) {
        unsigned hash = 0;
        for (size_t i = 0; i < key.size(); i++) {
            hash ^= WeakImplHashTraits::hash(key[i]);
        }
        return hash;
    }
    static bool equal(WTF::Vector<JSC::WeakImpl*> a, WTF::Vector<JSC::WeakImpl*> b) {
        if (a.size() != b.size()) {
            return false;
        }

        for (size_t i = 0; i < a.size(); i++) {
            if (!WeakImplHashTraits::equal(a[i], b[i])) {
                return false;
            }
        }
        return true;
    }
    bool isDeletedValue(WTF::Vector<JSC::WeakImpl*>& value) {
        return false;
    }

    static const bool safeToCompareToEmptyOrDeleted = false;
};

struct WeakImplVectorKeyTraits {
    typedef typename WTF::Vector<JSC::WeakImpl*> TraitType;
    typedef typename WTF::Vector<JSC::WeakImpl*> EmptyValueType;
    static void constructDeletedValue(TraitType& slot) {
        slot = WTF::Vector<JSC::WeakImpl*>();
    }
    static bool isDeletedValue(const WTF::Vector<JSC::WeakImpl*>& key) {
        return false;
    }
    static bool isEmptyValue(const WTF::Vector<JSC::WeakImpl*>& value) {
        return false;
    }
    static WTF::Vector<JSC::WeakImpl*> emptyValue() {
        return WTF::Vector<JSC::WeakImpl*>();
    }

    static const bool emptyValueIsZero = false;
    static const bool hasIsEmptyValueFunction = false;
    static const int minimumTableSize = 8;
};

class ReferenceTypesWeakHandleOwner : public JSC::WeakHandleOwner {
public:
    ReferenceTypesWeakHandleOwner(WTF::HashMap<JSC::WeakImpl*, JSC::WeakImpl*, WeakImplHashTraits> referenceTypesMap)
        : m_map(referenceTypesMap) {
    }

    virtual void finalize(JSC::Handle<JSC::Unknown> handle, void* context) {
        JSC::WeakImpl* weakValue = JSC::WeakImpl::asWeakImpl(handle.slot());
        m_map.remove(weakValue);
        JSC::WeakSet::deallocate(weakValue);
    }

private:
    WTF::HashMap<JSC::WeakImpl*, JSC::WeakImpl*, WeakImplHashTraits> m_map;
};
}

#endif /* defined(__NativeScript__WeakHandleOwners__) */
