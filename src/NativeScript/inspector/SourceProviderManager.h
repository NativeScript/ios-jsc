
#ifndef __NativeScript__CachedResourceManager__
#define __NativeScript__CachedResourceManager__

#include <stdio.h>
#include <JavaScriptCore/inspector/ScriptDebugListener.h>
#include "inspector/CachedResource.h"

namespace NativeScript {
class ResourceManager {
public:
    static ResourceManager& getInstance() {
        static ResourceManager instance; // Guaranteed to be destroyed.
        // Instantiated on first use.
        return instance;
    }
    WTF::HashMap<WTF::String, RefPtr<JSC::SourceProvider>>& sourceProviders() { return m_sourceProviders; }
    RefPtr<JSC::SourceProvider> addSourceProvider(WTF::String url, WTF::String moduleBody);

private:
    ResourceManager() {}
    ResourceManager(ResourceManager const&) = delete;
    void operator=(ResourceManager const&) = delete;

    WTF::HashMap<WTF::String, RefPtr<JSC::SourceProvider>> m_sourceProviders;

    WTF::String constructFunctionContent(WTF::String moduleBody);
};

WTF::HashMap<WTF::String, Inspector::CachedResource>& cachedResources();
}

#endif /* defined(__NativeScript__CachedResourceManager__) */
