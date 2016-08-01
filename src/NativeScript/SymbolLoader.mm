//
//  SymbolLoader.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 28.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "SymbolLoader.h"
#include "Metadata/Metadata.h"
#include <dlfcn.h>
#include <wtf/NeverDestroyed.h>

namespace NativeScript {
class SymbolResolver {
public:
    virtual void* loadFunctionSymbol(const char* symbolName) = 0;
    virtual void* loadDataSymbol(const char* symbolName) = 0;
    virtual bool load() = 0;
};

class CFBundleSymbolResolver : public SymbolResolver {
public:
    CFBundleSymbolResolver(WTF::RetainPtr<CFBundleRef> bundle)
        : _bundle(bundle) {
    }

    virtual void* loadFunctionSymbol(const char* symbolName) override {
        WTF::RetainPtr<CFStringRef> cfName = WTF::adoptCF(CFStringCreateWithCStringNoCopy(kCFAllocatorDefault, symbolName, kCFStringEncodingUTF8, kCFAllocatorNull));
        return CFBundleGetFunctionPointerForName(this->_bundle.get(), cfName.get());
    }

    virtual void* loadDataSymbol(const char* symbolName) override {
        WTF::RetainPtr<CFStringRef> cfName = WTF::adoptCF(CFStringCreateWithCStringNoCopy(kCFAllocatorDefault, symbolName, kCFStringEncodingUTF8, kCFAllocatorNull));
        return CFBundleGetDataPointerForName(this->_bundle.get(), cfName.get());
    }

    virtual bool load() override {
        CFErrorRef error = nullptr;
        bool loaded = CFBundleLoadExecutableAndReturnError(this->_bundle.get(), &error);
        if (error) {
            dataLogF("%s\n", [[(NSError*)error localizedDescription] UTF8String]);
        }

        return loaded;
    }

private:
    WTF::RetainPtr<CFBundleRef> _bundle;
};

class DlSymbolResolver : public SymbolResolver {
public:
    DlSymbolResolver(void* libraryHandle)
        : _libraryHandle(libraryHandle) {
    }

    virtual void* loadFunctionSymbol(const char* symbolName) override {
        return dlsym(this->_libraryHandle, symbolName);
    }

    virtual void* loadDataSymbol(const char* symbolName) override {
        return dlsym(this->_libraryHandle, symbolName);
    }

    virtual bool load() override {
        return !!this->_libraryHandle;
    }

private:
    void* _libraryHandle;
};

SymbolLoader& SymbolLoader::instance() {
    static WTF::NeverDestroyed<SymbolLoader> loader;
    return loader;
}

SymbolResolver* SymbolLoader::resolveModule(const Metadata::ModuleMeta* module) {
    if (!module) {
        return nullptr;
    }

    auto it = this->_cache.find(module);
    if (it != this->_cache.end()) {
        return it->second.get();
    }

    std::unique_ptr<SymbolResolver> resolver;
    if (module->isFramework()) {
        NSString* frameworkPathStr = [NSString stringWithFormat:@"%s.framework", module->getName()];
        NSURL* baseUrl = nil;
        if (module->isSystem()) {
#if TARGET_IPHONE_SIMULATOR
            NSBundle* foundation = [NSBundle bundleForClass:[NSString class]];
            NSString* foundationPath = [foundation bundlePath];
            NSString* basePathStr = [foundationPath substringToIndex:[foundationPath rangeOfString:@"Foundation.framework"].location];
            baseUrl = [NSURL fileURLWithPath:basePathStr isDirectory:YES];
#else
            baseUrl = [NSURL fileURLWithPath:@"/System/Library/Frameworks" isDirectory:YES];
#endif
        } else {
            baseUrl = [[NSBundle mainBundle] privateFrameworksURL];
        }

        NSURL* bundleUrl = [NSURL URLWithString:frameworkPathStr relativeToURL:baseUrl];
        if (WTF::RetainPtr<CFBundleRef> bundle = adoptCF(CFBundleCreate(kCFAllocatorDefault, (CFURLRef)bundleUrl))) {
            WTF::dataLogF("NativeScript loaded bundle %s\n", bundleUrl.absoluteString.UTF8String);
            resolver = std::make_unique<CFBundleSymbolResolver>(bundle);
        } else {
            WTF::dataLogF("NativeScript could not load bundle %s\n", bundleUrl.absoluteString.UTF8String);
        }
    } else if (module->libraries->count == 1) {
        if (module->isSystem()) {
            // NSObject is in /usr/lib/libobjc.dylib, so we get that
            NSString* libsPath = [[NSBundle bundleForClass:[NSObject class]] bundlePath];
            NSString* libraryPath = [NSString stringWithFormat:@"%@/lib%s.dylib", libsPath, module->libraries->first()->value().getName()];

            if (void* library = dlopen(libraryPath.UTF8String, RTLD_LAZY | RTLD_LOCAL)) {
                WTF::dataLogF("NativeScript loaded library %s\n", libraryPath.UTF8String);
                resolver = std::make_unique<DlSymbolResolver>(library);
            } else if (const char* libraryError = dlerror()) {
                WTF::dataLogF("NativeScript could not load library %s, error: %s\n", libraryPath.UTF8String, libraryError);
            }
        }
    }

    return this->_cache.emplace(module, std::move(resolver)).first->second.get();
}

void* SymbolLoader::loadFunctionSymbol(const Metadata::ModuleMeta* module, const char* symbolName) {
    if (auto resolver = this->resolveModule(module)) {
        return resolver->loadFunctionSymbol(symbolName);
    }

    return dlsym(RTLD_DEFAULT, symbolName);
}

void* SymbolLoader::loadDataSymbol(const Metadata::ModuleMeta* module, const char* symbolName) {
    if (auto resolver = this->resolveModule(module)) {
        return resolver->loadDataSymbol(symbolName);
    }

    return dlsym(RTLD_DEFAULT, symbolName);
}

bool SymbolLoader::ensureModule(const Metadata::ModuleMeta* module) {
    if (auto resolver = this->resolveModule(module)) {
        return resolver->load();
    }

    return false;
}
}