//
//  ReleasePool.h
//  NativeScript
//
//  Created by Yavor Georgiev on 02.06.15.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__ReleasePool__
#define __NativeScript__ReleasePool__

#include <map>
#include <string>
#include <vector>
#include <wtf/Deque.h>

namespace NativeScript {
class ReleasePoolBase {
public:
    typedef std::map<std::string, std::unique_ptr<ReleasePoolBase>> Item;

    virtual void drain() = 0;

    virtual ~ReleasePoolBase() = default;

protected:
    ReleasePoolBase() = default;
};

template <typename T>
class ReleasePool : ReleasePoolBase {
    static_assert(std::is_destructible<T>::value, "Type must be destructible");
    static_assert(!std::is_pointer<T>::value, "Type must not be a pointer");

private:
    template <typename U>
    friend void releaseSoon(GlobalObject*, U&&);

    static void releaseSoon(GlobalObject* globalObject, T&& item) {
        ASSERT(!globalObject->releasePools().isEmpty());

        ReleasePool<T>* pool = nullptr;

        Item& poolsMap = globalObject->releasePools().last();
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

    ReleasePool() = default;

    std::vector<T> _items;
};

class ReleasePoolHolder {
public:
    ReleasePoolHolder(JSC::ExecState* execState) {
        init(JSC::jsCast<GlobalObject*>(execState->lexicalGlobalObject()));
    }

    ReleasePoolHolder(GlobalObject* globalObject) {
        init(globalObject);
    }

    ReleasePoolBase::Item relinquish() {
        auto& releasePools = _globalObject->releasePools();
        ASSERT(!_didRelinquish);
        ASSERT(!releasePools.isEmpty());

        _didRelinquish = true;
        return releasePools.takeLast();
    }

    void drain() {
        if (LIKELY(!_didRelinquish)) {
            ASSERT(!_globalObject->releasePools().isEmpty());
            auto& poolsMap = _globalObject->releasePools().last();
            for (auto& pair : poolsMap) {
                pair.second->drain();
            }
        }
    }

    ~ReleasePoolHolder() {
        if (LIKELY(!_didRelinquish)) {
            ASSERT(!_globalObject->releasePools().isEmpty());
            _globalObject->releasePools().removeLast();
        }
    }

private:
    void init(GlobalObject* globalObject) {
        _globalObject = globalObject;
        _globalObject->releasePools().append(ReleasePoolBase::Item());
    }

    GlobalObject* _globalObject;
    bool _didRelinquish = false;
};

template <typename T>
void releaseSoon(GlobalObject* globalObject, T&& item) {
    ReleasePool<T>::releaseSoon(globalObject, std::move(item));
}

template <typename T>
void releaseSoon(JSC::ExecState* execState, T&& item) {
    releaseSoon(JSC::jsCast<GlobalObject*>(execState->lexicalGlobalObject()), std::move(item));
}
}

#endif /* defined(__NativeScript__ReleasePool__) */