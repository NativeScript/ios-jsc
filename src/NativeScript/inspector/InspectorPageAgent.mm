#include "InspectorPageAgent.h"
#include "CachedResource.h"
#include <JavaScriptCore/inspector/ContentSearchUtilities.h>
#include <JavaScriptCore/yarr/RegularExpression.h>
#include <map>
#include <vector>

namespace Inspector {
InspectorPageAgent::InspectorPageAgent()
    : Inspector::InspectorAgentBase(WTF::ASCIILiteral("Page"))
    , m_frameIdentifier("NativeScriptMainFrameIdentifier")
    , m_frameUrl("http://main.xml") {
}

void InspectorPageAgent::didCreateFrontendAndBackend(FrontendChannel* frontendChannel, BackendDispatcher* backendDispatcher) {
    m_frontendDispatcher = std::make_unique<PageFrontendDispatcher>(frontendChannel);
    m_backendDispatcher = PageBackendDispatcher::create(backendDispatcher, this);

    m_cachedResources = new WTF::HashMap<WTF::String, Inspector::CachedResource>();
}

void InspectorPageAgent::willDestroyFrontendAndBackend(DisconnectReason) {
    m_cachedResources = nullptr;
    m_frontendDispatcher = nullptr;
    m_backendDispatcher.clear();
}

void InspectorPageAgent::enable(ErrorString&) {
}

void InspectorPageAgent::disable(ErrorString&) {
}

void InspectorPageAgent::addScriptToEvaluateOnLoad(ErrorString&, const String& in_scriptSource, String* out_identifier) {
}

void InspectorPageAgent::removeScriptToEvaluateOnLoad(ErrorString&, const String& in_identifier) {
}

void InspectorPageAgent::reload(ErrorString&, const bool* in_ignoreCache, const String* in_scriptToEvaluateOnLoad) {
}

void InspectorPageAgent::navigate(ErrorString&, const String& in_url) {
}

void InspectorPageAgent::getCookies(ErrorString&, RefPtr<Inspector::Protocol::Array<Inspector::Protocol::Page::Cookie>>& out_cookies) {
}

void InspectorPageAgent::deleteCookie(ErrorString&, const String& in_cookieName, const String& in_url) {
}

void InspectorPageAgent::getResourceTree(ErrorString&, RefPtr<Inspector::Protocol::Page::FrameResourceTree>& out_frameTree) {

    Ref<Inspector::Protocol::Page::Frame> frameObject = Inspector::Protocol::Page::Frame::create()
                                                            .setId(m_frameIdentifier)
                                                            .setLoaderId("Loader Identifier")
                                                            .setUrl(m_frameUrl)
                                                            .setSecurityOrigin("")
                                                            .setMimeType("text/xml")
                                                            .release();

    RefPtr<Inspector::Protocol::Array<Inspector::Protocol::Page::FrameResource>> subresources = Inspector::Protocol::Array<Inspector::Protocol::Page::FrameResource>::create();
    out_frameTree = Inspector::Protocol::Page::FrameResourceTree::create()
                        .setFrame(frameObject.copyRef())
                        .setResources(subresources.copyRef())
                        .release();

    NSString* bundlePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"app"];
    NSDirectoryEnumerator* directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:[NSURL URLWithString:bundlePath] includingPropertiesForKeys:@[ NSURLIsDirectoryKey ] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];

    NSURL* file;
    NSError* error;
    while ((file = [directoryEnumerator nextObject])) {
        NSNumber* isDirectory;
        [file getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error];
        if (![isDirectory boolValue]) {
            WTF::String absoluteString = WTF::String([file absoluteString]);
            Inspector::CachedResource resource = Inspector::CachedResource(absoluteString);

            Ref<Inspector::Protocol::Page::FrameResource> frameResource = Inspector::Protocol::Page::FrameResource::create()
                                                                              .setUrl(resource.url())
                                                                              .setType(resource.type())
                                                                              .setMimeType(resource.mimeType())
                                                                              .release();

            m_cachedResources->add(absoluteString, resource);
            subresources->addItem(WTF::move(frameResource));
        }
    }
}

void InspectorPageAgent::searchInResource(ErrorString&, const String& in_frameId, const String& in_url, const String& in_query, const bool* in_caseSensitive, const bool* in_isRegex, RefPtr<Inspector::Protocol::Array<Inspector::Protocol::GenericTypes::SearchMatch>>& out_result) {

    out_result = Inspector::Protocol::Array<Inspector::Protocol::GenericTypes::SearchMatch>::create();

    bool isRegex = in_isRegex ? *in_isRegex : false;
    bool caseSensitive = in_caseSensitive ? *in_caseSensitive : false;

    auto iterator = m_cachedResources->find(in_url);
    if (iterator != m_cachedResources->end()) {
        WTF::String* content = new WTF::String;
        ErrorString out_error;
        CachedResource& resource = iterator->value;
        resource.content(content, out_error);
        if (out_error.isEmpty()) {
            out_result = ContentSearchUtilities::searchInTextByLines(*content, in_query, caseSensitive, isRegex);
        }
    }
}

static Ref<Inspector::Protocol::Page::SearchResult> buildObjectForSearchResult(const String& frameId, const String& url, int matchesCount) {
    return Inspector::Protocol::Page::SearchResult::create()
        .setUrl(url)
        .setFrameId(frameId)
        .setMatchesCount(matchesCount)
        .release();
}

void InspectorPageAgent::searchInResources(ErrorString&, const String& in_text, const bool* in_caseSensitive, const bool* in_isRegex, RefPtr<Inspector::Protocol::Array<Inspector::Protocol::Page::SearchResult>>& out_result) {
    out_result = Inspector::Protocol::Array<Inspector::Protocol::Page::SearchResult>::create();

    bool isRegex = in_isRegex ? *in_isRegex : false;
    bool caseSensitive = in_caseSensitive ? *in_caseSensitive : false;
    JSC::Yarr::RegularExpression regex = ContentSearchUtilities::createSearchRegex(in_text, caseSensitive, isRegex);

    for (CachedResource& cachedResource : m_cachedResources->values()) {
        WTF::String* out_content = new WTF::String;
        ErrorString out_error;
        cachedResource.content(out_content, out_error);
        if (out_error.isEmpty()) {
            int matchesCount = ContentSearchUtilities::countRegularExpressionMatches(regex, *out_content);
            if (matchesCount) {
                out_result->addItem(buildObjectForSearchResult(m_frameIdentifier, cachedResource.url(), matchesCount));
            }
        }
    }
}

void InspectorPageAgent::setDocumentContent(ErrorString&, const String& in_frameId, const String& in_html) {
}

void InspectorPageAgent::setShowPaintRects(ErrorString&, bool in_result) {
}

void InspectorPageAgent::getScriptExecutionStatus(ErrorString&, PageBackendDispatcherHandler::Result* out_result) {
}

void InspectorPageAgent::setScriptExecutionDisabled(ErrorString&, bool in_value) {
}

void InspectorPageAgent::setTouchEmulationEnabled(ErrorString&, bool in_enabled) {
}

void InspectorPageAgent::setEmulatedMedia(ErrorString&, const String& in_media) {
}

void InspectorPageAgent::getCompositingBordersVisible(ErrorString&, bool* out_result) {
}

void InspectorPageAgent::setCompositingBordersVisible(ErrorString&, bool in_visible) {
}

void InspectorPageAgent::snapshotNode(ErrorString&, int in_nodeId, String* out_dataURL) {
}

void InspectorPageAgent::snapshotRect(ErrorString&, int in_x, int in_y, int in_width, int in_height, const String& in_coordinateSystem, String* out_dataURL) {
}

void InspectorPageAgent::handleJavaScriptDialog(ErrorString&, bool in_accept, const String* in_promptText) {
}

void InspectorPageAgent::archive(ErrorString&, String* out_data) {
}

void InspectorPageAgent::getResourceContent(ErrorString& errorString, const String& in_frameId, const String& in_url, String* out_content, bool* out_base64Encoded) {
    if(in_url == m_frameUrl) {
        *out_base64Encoded = false;
        *out_content = WTF::emptyString();
        
        return;
    }
    
    auto iterator = m_cachedResources->find(in_url);
    if (iterator == m_cachedResources->end()) {
        errorString = WTF::ASCIILiteral("No such item");

        return;
    }

    CachedResource& resource = iterator->value;

    *out_base64Encoded = !resource.hasTextContent();
    resource.content(out_content, errorString);
}
}
