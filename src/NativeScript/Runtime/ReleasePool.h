//
//  ReleasePool.h
//  NativeScript
//
//  Created by Yavor Georgiev on 02.06.15.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__ReleasePool__
#define __NativeScript__ReleasePool__

#include <type_traits>
#include <typeindex>
#include <vector>
#include <map>
#include <wtf/Deque.h>
#include <string>
#include <WTF/ThreadSpecific.h>

namespace NativeScript {
class ReleasePoolBase {
public:
    typedef std::map<std::string, std::unique_ptr<ReleasePoolBase>> Item;

    virtual void drain() = 0;

    virtual ~ReleasePoolBase() = default;

protected:
    friend class ReleasePoolHolder;

    ReleasePoolBase() = default;

    static WTF::Deque<Item>& releasePools() {
        static auto pools = new WTF::ThreadSpecific<WTF::Deque<Item>>();
        return **pools;
    }
};

template <typename T>
class ReleasePool : ReleasePoolBase {
    static_assert(std::is_destructible<T>::value, "Type must be destructible");
    static_assert(!std::is_pointer<T>::value, "Type must not be a pointer");

public:
    static void releaseSoon(T&& item) {
        ASSERT(!releasePools().isEmpty());

        ReleasePool<T>* pool = nullptr;

        Item& poolsMap = releasePools().last();
        std::string key(__PRETTY_FUNCTION__);

        auto iter = poolsMap.find(key);
        if (iter != poolsMap.end()) {
            pool = static_cast<ReleasePool<T>*>(iter->second.get());
        } else {
            pool = new ReleasePool<T>();
            poolsMap.emplace(key, std::unique_ptr<ReleasePoolBase>(pool));
        }

        pool->_items.push_back(std::move(item));
    }

    virtual void drain() override {
        _items.clear();
    }

private:
    ReleasePool() = default;

    std::vector<T> _items;
};

class ReleasePoolHolder {
public:
    ReleasePoolHolder() {
        ReleasePoolBase::releasePools().append(ReleasePoolBase::Item());
    }

    ReleasePoolBase::Item relinquish() {
        auto& releasePools = ReleasePoolBase::releasePools();
        ASSERT(!_didRelinquish);
        ASSERT(!releasePools.isEmpty());

        _didRelinquish = true;
        return releasePools.takeLast();
    }

    void drain() {
        if (LIKELY(!_didRelinquish)) {
            ASSERT(!ReleasePoolBase::releasePools().isEmpty());
            auto& poolsMap = ReleasePoolBase::releasePools().last();
            for (auto& pair : poolsMap) {
                pair.second->drain();
            }
        }
    }

    ~ReleasePoolHolder() {
        if (LIKELY(!_didRelinquish)) {
            ASSERT(!ReleasePoolBase::releasePools().isEmpty());
            ReleasePoolBase::releasePools().removeLast();
        }
    }

private:
    bool _didRelinquish;
};
}

#endif /* defined(__NativeScript__ReleasePool__) */