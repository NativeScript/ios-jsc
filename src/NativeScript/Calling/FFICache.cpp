//
//  FFICache.cpp
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 02/10/2017.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "FFICache.h"

#define CLEANUP_THROTTLE_SEC 10

namespace NativeScript {

FFICache* FFICache::global() {

    static FFICache* instance;

    if (!instance)
        instance = new FFICache;
    return instance;
}

void FFICache::cleanup() {
    auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(std::chrono::steady_clock::now() - this->_lastCleanup);
    if (elapsed.count() >= CLEANUP_THROTTLE_SEC) {
        // Cleanup mostly takes less than 2 ms depending on how full the cache is.
        // When executed on an iPhone 6 device after all ApiTests have run
        // of a debug build of TestRunner takes ~0.7-1.5 ms (cache contains 1723 cifs)
        WTF::LockHolder lock(this->_cacheLock);
        for (auto it = this->_cifCache.begin(); it != this->_cifCache.end();) {
            if (it->second.use_count() == 1) {
                it = this->_cifCache.erase(it);
            } else {
                ++it;
            }
        }

        this->_lastCleanup = std::chrono::steady_clock::now();
    }
}

} // namespace NativeScript
