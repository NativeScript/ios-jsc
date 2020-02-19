//
//  SymbolLoader.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 28.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "SymbolLoader.h"
#include "ManualInstrumentation.h"
#include "Metadata/Metadata.h"
#include <dlfcn.h>
#include <wtf/NeverDestroyed.h>

namespace NativeScript {
class SymbolResolver {
public:
    virtual void* loadFunctionSymbol(const char* symbolName) = 0;
    virtual void* loadDataSymbol(const char* symbolName) = 0;
    virtual bool load() = 0;
    virtual ~SymbolResolver() {}
};

class CFBundleSymbolResolver : public SymbolResolver {
public:
    CFBundleSymbolResolver(WTF::RetainPtr<CFBundleRef> bundle)
        : _bundle(bundle)
        , _loaded(false) {
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
        if (this->_loaded) {
            return true;
        }

        // Use NSBundle for loading because of the following statement in the docs:
        // For most of its methods, NSBundle simply calls the appropriate CFBundle routine to do its work,
        // but loading code is different. Because CFBundle does not handle Objective-C symbols, NSBundle has
        // to use a different mechanism for loading code. NSBundle interacts with the Objective-C runtime
        // system to correctly load and register all Cocoa classes and other executable code in the bundle
        // executable file.
        // See https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/LoadingCode/Concepts/CFNSBundle.html

        NSURL* url = (__bridge NSURL*)CFBundleCopyBundleURL(this->_bundle.get());
        NSBundle* bundle = [NSBundle bundleWithURL:url];
        [url release];

        bool wasLoaded = bundle.loaded;
        NSError* error = nullptr;
        bool loaded = [bundle loadAndReturnError:&error];

        if (loaded) {
            this->_loaded = true;
            if (!wasLoaded) {
                // Unload the bundle if it was not previously loaded. Sometimes framework bundles use
                // resource bundles of the same name and keeping the framework loaded as a bundle
                // breaks them. OTH, loading and unloading a framework bundle is sufficient for its
                // executable code to be registered with the Objective-C runtime.
                [bundle unload];
            }
        }

        if (error) {
            dataLogF("%s\n", [[error localizedDescription] UTF8String]);
        }

        return loaded;
    }

private:
    WTF::RetainPtr<CFBundleRef> _bundle;
    bool _loaded;
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

    tns::instrumentation::Frame frame;

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
            //            WTF::dataLogF("NativeScript loaded bundle %s\n", bundleUrl.absoluteString.UTF8String);
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

    if (frame.check()) {
        frame.log([@"resolveModule: " stringByAppendingString:[NSString stringWithUTF8String:module->getName()]].UTF8String);
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
