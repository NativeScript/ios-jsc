//
//  SymbolLoader.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 28.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include <dlfcn.h>
#include <string>
#include "SymbolLoader.h"

namespace NativeScript {
SymbolLoader::SymbolLoader() {
}

SymbolLoader& SymbolLoader::instance() {
    static std::once_flag once;
    static SymbolLoader* loader;
    std::call_once(once, []() { loader = new SymbolLoader(); });
    return *loader;
}

CFBundleRef getBundleFromName(std::map<const char*, WTF::RetainPtr<CFBundleRef>>& cache, const char* frameworkName) {
    auto it = cache.find(frameworkName);
    if (it != cache.end()) {
        return it->second.get();
    }

    NSString* frameworkPathStr = [NSString stringWithFormat:@"System/Library/Frameworks/%s.framework", frameworkName];
    NSURL* baseUrl = nil;

#if TARGET_IPHONE_SIMULATOR
    NSBundle* foundation = [NSBundle bundleForClass:[NSString class]];
    NSString* foundationPath = [foundation bundlePath];
    NSString* basePathStr = [foundationPath substringToIndex:[foundationPath rangeOfString:@"/System/Library/Frameworks/Foundation.framework"].location];
    baseUrl = [NSURL fileURLWithPath:basePathStr
                         isDirectory:YES];
#endif

    NSURL* bundleUrl = [NSURL URLWithString:frameworkPathStr
                              relativeToURL:baseUrl];
    WTF::RetainPtr<CFBundleRef> bundle = adoptCF(CFBundleCreate(kCFAllocatorDefault, (CFURLRef)bundleUrl));
    cache.insert(std::make_pair(frameworkName, bundle));
    return bundle.get();
}

void* SymbolLoader::loadFunctionSymbol(std::string libraryName, const char* symbolName) {
    CFBundleRef bundle = getBundleFromName(this->_cache, libraryName.c_str());
    if (bundle) {
        void* handle = CFBundleGetFunctionPointerForName(bundle, (CFStringRef) @(symbolName));
        if (handle) {
            return handle;
        }
    }

    return dlsym(RTLD_DEFAULT, symbolName);
}

void* SymbolLoader::loadDataSymbol(std::string libraryName, const char* symbolName) {
    CFBundleRef bundle = getBundleFromName(this->_cache, libraryName.c_str());
    if (bundle) {
        void* handle = CFBundleGetDataPointerForName(bundle, (CFStringRef) @(symbolName));
        if (handle) {
            return handle;
        }
    }

    return dlsym(RTLD_DEFAULT, symbolName);
}

bool SymbolLoader::ensureFramework(const char* frameworkName) {
    CFBundleRef bundle = getBundleFromName(this->_cache, frameworkName);
    if (!bundle) {
        return false;
    }

    return CFBundleLoadExecutableAndReturnError(bundle, nullptr);
}
}