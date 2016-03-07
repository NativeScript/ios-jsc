#include "CachedResource.h"
#include "MimeTypeHelper.h"

namespace Inspector {
WTF::HashMap<WTF::String, Inspector::CachedResource>& cachedResources(NativeScript::GlobalObject& globalObject) {
    static WTF::HashMap<WTF::String, Inspector::CachedResource> cachedResources;

    static std::once_flag flag;
    std::call_once(flag, [&globalObject]() {
        NSString* applicationPath = globalObject.applicationPath();
        NSString* bundlePath = [NSString stringWithFormat:@"%@/%@", applicationPath, @"app"];
        NSDirectoryEnumerator* directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL URLWithString:bundlePath] includingPropertiesForKeys:@[ NSURLIsDirectoryKey ] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];

        NSURL* file;
        NSError* error;
        for (file in directoryEnumerator) {
            NSNumber* isDirectory;
            [file getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error];
            if (![isDirectory boolValue]) {
                Inspector::CachedResource resource(bundlePath, [file path]);

                cachedResources.add(resource.displayName(), resource);
            }
        }
    });
    return cachedResources;
}

WTF::HashMap<WTF::String, Inspector::Protocol::Page::ResourceType> CachedResource::m_mimeTypeMap = {
    { "text/xml", Inspector::Protocol::Page::ResourceType::Document },
    { "text/plain", Inspector::Protocol::Page::ResourceType::Document },
    { "application/xml", Inspector::Protocol::Page::ResourceType::Document },
    { "application/xhtml+xml", Inspector::Protocol::Page::ResourceType::Document },
    { "text/css", Inspector::Protocol::Page::ResourceType::Stylesheet },
    { "text/javascript", Inspector::Protocol::Page::ResourceType::Script },
    { "text/ecmascript", Inspector::Protocol::Page::ResourceType::Script },
    { "application/javascript", Inspector::Protocol::Page::ResourceType::Script },
    { "application/ecmascript", Inspector::Protocol::Page::ResourceType::Script },
    { "application/x-javascript", Inspector::Protocol::Page::ResourceType::Script },
    { "application/json", Inspector::Protocol::Page::ResourceType::Script },
    { "application/x-json", Inspector::Protocol::Page::ResourceType::Script },
    { "text/x-javascript", Inspector::Protocol::Page::ResourceType::Script },
    { "text/x-json", Inspector::Protocol::Page::ResourceType::Script },
    { "text/typescript", Inspector::Protocol::Page::ResourceType::Script },
};

CachedResource::CachedResource() {}

CachedResource::CachedResource(WTF::String bundlePath, WTF::String filePath)
    : m_filePath([filePath stringByResolvingSymlinksInPath])
    , m_bundlePath([bundlePath stringByResolvingSymlinksInPath])
    , m_content(WTF::emptyString()) {
    m_mimeType = WTF::String(NativeScript::mimeTypeByExtension([filePath pathExtension]));
    Inspector::Protocol::Page::ResourceType resourceType = Inspector::Protocol::Page::ResourceType::Document;
    if (!m_mimeType.isEmpty()) {
        resourceType = resourceTypeByMimeType(m_mimeType);
    }

    m_type = resourceType;
}

bool CachedResource::hasTextContent() {
    return m_type == Inspector::Protocol::Page::ResourceType::Document || m_type == Inspector::Protocol::Page::ResourceType::Stylesheet || m_type == Inspector::Protocol::Page::ResourceType::Script || m_type == Inspector::Protocol::Page::ResourceType::XHR;
}

WTF::String CachedResource::displayName() {
    if (m_displayName.isEmpty()) {
        m_displayName = [NSString stringWithFormat:@"file:///app%@", [m_filePath substringFromIndex:[m_bundlePath length]]];
    }

    return m_displayName;
}

Inspector::Protocol::Page::ResourceType CachedResource::resourceTypeByMimeType(WTF::String mimeType) {
    WTF::HashMap<WTF::String, Protocol::Page::ResourceType>::const_iterator iterator = m_mimeTypeMap.find(mimeType);
    if (iterator != m_mimeTypeMap.end()) {
        return iterator->value;
    }

    if (mimeType.startsWith("image/")) {
        return Inspector::Protocol::Page::ResourceType::Image;
    }

    if (mimeType.startsWith("font/")) {
        return Inspector::Protocol::Page::ResourceType::Font;
    }

    return Inspector::Protocol::Page::ResourceType::Other;
}

WTF::String CachedResource::content(ErrorString& out_error) {
    if (m_content.isEmpty()) {
        NSURL* cachedResourceUrl = [NSURL fileURLWithPath:m_filePath];
        bool out_base64Encoded = !hasTextContent();
        if (out_base64Encoded) {
            NSData* data = [[NSFileManager defaultManager] contentsAtPath:[cachedResourceUrl path]];
            if (data == nil) {
                out_error = WTF::ASCIILiteral("An error occurred");

                return WTF::emptyString();
            } else {
                NSString* base64Encoded = [data base64EncodedStringWithOptions:0];
                m_content = WTF::String(base64Encoded);
            }
        } else {
            NSError* error;
            NSString* content = [NSString stringWithContentsOfURL:cachedResourceUrl encoding:NSUTF8StringEncoding error:&error];
            if (content == nil) {
                out_error = [error localizedDescription];

                return WTF::emptyString();
            } else {
                m_content = content;
            }
        }
    }

    return m_content;
}
}
