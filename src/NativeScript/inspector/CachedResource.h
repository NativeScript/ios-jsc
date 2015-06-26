#ifndef NativeScript_CachedResource_h
#define NativeScript_CachedResource_h

#include "JavaScriptCore/inspector/InspectorProtocolObjects.h"
#include <JavaScriptCore/inspector/InspectorBackendDispatchers.h>

namespace Inspector {
    class CachedResource {
    public:
        CachedResource();
        CachedResource(WTF::String url);
        WTF::String url() { return m_url; };
        WTF::String mimeType() { return m_mimeType; }
        void content(WTF::String* out_content, ErrorString& out_error);
        bool hasTextContent();
        Inspector::Protocol::Page::ResourceType type() { return m_type; }
    private:
        WTF::String m_url;
        WTF::String m_mimeType;
        WTF::String m_content;
        Inspector::Protocol::Page::ResourceType m_type;
        
        static WTF::HashMap<WTF::String, Inspector::Protocol::Page::ResourceType> m_mimeTypeMap;
        
        Inspector::Protocol::Page::ResourceType resourceTypeByMimeType(WTF::String mimeType);
    };
}

#endif
