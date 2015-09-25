#include "SourceProviderManager.h"
#include <stdio.h>
#include <JavaScriptCore/inspector/ScriptDebugListener.h>
#include "inspector/CachedResource.h"

namespace NativeScript {
RefPtr<JSC::SourceProvider> ResourceManager::addSourceProvider(WTF::String url, WTF::String moduleBody) {
    WTF::String functionContent = constructFunctionContent(moduleBody);
    WTF::TextPosition startPosition;
    RefPtr<JSC::SourceProvider> sourceProvider = JSC::StringSourceProvider::create(functionContent, url, startPosition);

    m_sourceProviders.add(url, sourceProvider);

    return sourceProvider;
}

WTF::String ResourceManager::constructFunctionContent(WTF::String moduleBody) {
    StringBuilder builder;
    builder.append("{function anonymous(require, module, exports, __dirname, __filename) {");
    builder.append(moduleBody);
    builder.append("\n}}");

    return builder.toString();
}
}