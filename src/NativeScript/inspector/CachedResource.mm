#include "CachedResource.h"
#include "MimeTypeHelper.h"

namespace Inspector {
static Inspector::CachedResource createCacheResource(NSString* basePath, NSString* filePath, NSString* prefix) {
    NSString* symLinksResolvedFilePath = [filePath stringByResolvingSymlinksInPath];
    NSString* relativePath = [symLinksResolvedFilePath substringFromIndex:[[basePath stringByResolvingSymlinksInPath] length]];
    NSString* displayName = [NSURL fileURLWithPath:[NSString pathWithComponents:@[ prefix, relativePath ]]].absoluteString;

    return Inspector::CachedResource(displayName, symLinksResolvedFilePath);
}

static void createCachedResourcesOfDirectory(WTF::HashMap<WTF::String, Inspector::CachedResource>& cachedResources, NSString* bundlePath, NSString* prefix) {
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath isDirectory:&isDirectory]) {
        if (isDirectory) {
            NSDirectoryEnumerator* directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL fileURLWithPath:bundlePath] includingPropertiesForKeys:@[ NSURLIsDirectoryKey, NSURLIsSymbolicLinkKey ] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];

            NSURL* file;
            NSError* error;
            for (file in directoryEnumerator) {
                NSNumber* isDirectory;
                NSNumber* isSymbolicLink;
                [file getResourceValue:&isSymbolicLink forKey:NSURLIsSymbolicLinkKey error:&error];
                [file getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error];

                if ([isSymbolicLink boolValue]) {
                    NSString* originalPath = [[NSFileManager defaultManager] destinationOfSymbolicLinkAtPath:[file path] error:&error];
                    createCachedResourcesOfDirectory(cachedResources, originalPath, [NSString pathWithComponents:@[ prefix, [file lastPathComponent] ]]);
                } else if (![isDirectory boolValue]) {
                    Inspector::CachedResource resource = createCacheResource(bundlePath, [file path], prefix);
                    cachedResources.add(resource.displayName(), resource);
                }
            }
        } else {
            Inspector::CachedResource resource = createCacheResource(bundlePath, bundlePath, prefix);
            cachedResources.add(resource.displayName(), resource);
        }
    }
}

WTF::HashMap<WTF::String, Inspector::CachedResource>& cachedResources(NativeScript::GlobalObject& globalObject) {
    static WTF::HashMap<WTF::String, Inspector::CachedResource> cachedResources;

    static std::once_flag flag;
    std::call_once(flag, [&globalObject]() {
        NSString* bundlePath = [NSString pathWithComponents:@[ globalObject.applicationPath(), @"app" ]];

        createCachedResourcesOfDirectory(cachedResources, bundlePath, @"app");
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

CachedResource::CachedResource(WTF::String displayName, WTF::String filePath)
    : m_filePath(filePath)
    , m_displayName(displayName)
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
