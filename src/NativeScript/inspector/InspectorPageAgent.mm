
#include "InspectorPageAgent.h"
#include <MobileCoreServices/UTType.h>
#include "MimeTypeHelper.h"
#include <map>
#include <vector>

namespace Inspector {
    InspectorPageAgent::InspectorPageAgent()
    : Inspector::InspectorAgentBase(WTF::ASCIILiteral("Page")) {
        m_mimeTypeMap = std::make_unique<WTF::HashMap<WTF::String, Inspector::Protocol::Page::ResourceType>>();
        m_mimeTypeMap->add("text/html", Inspector::Protocol::Page::ResourceType::Document);
        m_mimeTypeMap->add("text/xml", Inspector::Protocol::Page::ResourceType::Document);
        m_mimeTypeMap->add("text/plain", Inspector::Protocol::Page::ResourceType::Document);
        m_mimeTypeMap->add("application/xhtml+xml", Inspector::Protocol::Page::ResourceType::Document);
        m_mimeTypeMap->add("text/css", Inspector::Protocol::Page::ResourceType::Stylesheet);
        m_mimeTypeMap->add("text/xsl", Inspector::Protocol::Page::ResourceType::Stylesheet);
        m_mimeTypeMap->add("text/x-less", Inspector::Protocol::Page::ResourceType::Stylesheet);
        m_mimeTypeMap->add("text/x-sass", Inspector::Protocol::Page::ResourceType::Stylesheet);
        m_mimeTypeMap->add("text/x-scss", Inspector::Protocol::Page::ResourceType::Stylesheet);
        m_mimeTypeMap->add("application/pdf", Inspector::Protocol::Page::ResourceType::Image);
        m_mimeTypeMap->add("application/x-font-type1", Inspector::Protocol::Page::ResourceType::Font);
        m_mimeTypeMap->add("application/x-font-ttf", Inspector::Protocol::Page::ResourceType::Font);
        m_mimeTypeMap->add("application/x-font-woff", Inspector::Protocol::Page::ResourceType::Font);
        m_mimeTypeMap->add("application/x-truetype-font", Inspector::Protocol::Page::ResourceType::Font);
        m_mimeTypeMap->add("text/javascript", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/ecmascript", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("application/javascript", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("application/ecmascript", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("application/x-javascript", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("application/json", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("application/x-json", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/x-javascript", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/x-json", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/javascript1.1", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/javascript1.2", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/javascript1.3", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/jscript", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/livescript", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/x-livescript", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/typescript", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/x-clojure", Inspector::Protocol::Page::ResourceType::Script);
        m_mimeTypeMap->add("text/x-coffeescript", Inspector::Protocol::Page::ResourceType::Script);
    }
    
    void InspectorPageAgent::didCreateFrontendAndBackend(FrontendChannel* frontendChannel, BackendDispatcher* backendDispatcher) {
        m_frontendDispatcher = std::make_unique<PageFrontendDispatcher>(frontendChannel);
        m_backendDispatcher = PageBackendDispatcher::create(backendDispatcher, this);
        
        m_cachedResources = new WTF::HashMap<WTF::String, Inspector::Protocol::Page::ResourceType>();

    }

    void InspectorPageAgent::willDestroyFrontendAndBackend(DisconnectReason) {
        m_cachedResources= nullptr;
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
            .setId("Identifier")
            .setLoaderId("Loader Identifier")
            .setUrl("http://main.xml")
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
        NSError *error;
        while((file = [directoryEnumerator nextObject])) {
            NSNumber* isDirectory;
            [file getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error];
            if(![isDirectory boolValue]) {
                String mimeType = NativeScript::mimeTypeByExtension([file pathExtension]);
                Inspector::Protocol::Page::ResourceType resourceType = Inspector::Protocol::Page::ResourceType::Other;
                if(!mimeType.isEmpty()) {
                    resourceType = resourceTypeByMimeType(mimeType);
                } 
                
                WTF::String absoluteString = WTF::String([file absoluteString]);
                Ref<Inspector::Protocol::Page::FrameResource> frameResource = Inspector::Protocol::Page::FrameResource::create()
                .setUrl(absoluteString)
                .setType(resourceType)
                .setMimeType(mimeType)
                .release();
                
                m_cachedResources->add(absoluteString, resourceType);
                subresources->addItem(WTF::move(frameResource));
            }
        }
    }
    
    void InspectorPageAgent::searchInResource(ErrorString&, const String& in_frameId, const String& in_url, const String& in_query, const bool* in_caseSensitive, const bool* in_isRegex, RefPtr<Inspector::Protocol::Array<Inspector::Protocol::GenericTypes::SearchMatch>>& out_result) {
    
    }
    
    void InspectorPageAgent::searchInResources(ErrorString&, const String& in_text, const bool* in_caseSensitive, const bool* in_isRegex, RefPtr<Inspector::Protocol::Array<Inspector::Protocol::Page::SearchResult>>& out_result) {
    
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
    
    Inspector::Protocol::Page::ResourceType InspectorPageAgent::resourceTypeByMimeType(WTF::String mimeType) {
        WTF::HashMap<WTF::String, Protocol::Page::ResourceType>::const_iterator iterator = m_mimeTypeMap->find(mimeType);
        if(iterator != m_mimeTypeMap->end()) {
            return iterator->value;
        }
        
        if(mimeType.startsWith("image/")) {
            return Inspector::Protocol::Page::ResourceType::Image;
        }
        
        if(mimeType.startsWith("font/")) {
            return Inspector::Protocol::Page::ResourceType::Font;
        }
        
        return Inspector::Protocol::Page::ResourceType::Other;
    }
    
    static bool hasTextContent(Inspector::Protocol::Page::ResourceType type)
    {
        return type == Inspector::Protocol::Page::ResourceType::Document || type == Inspector::Protocol::Page::ResourceType::Stylesheet || type == Inspector::Protocol::Page::ResourceType::Script || type == Inspector::Protocol::Page::ResourceType::XHR;
    }
    
    void InspectorPageAgent::getResourceContent(ErrorString& errorString, const String& in_frameId, const String& in_url, String* out_content, bool* out_base64Encoded) {
        
        Inspector::Protocol::Page::ResourceType resourceType = Inspector::Protocol::Page::ResourceType::Other;
        auto iterator = m_cachedResources->find(in_url);
        if(iterator != m_cachedResources->end()) {
            resourceType = iterator->value;
        }
        
        NSURL* url = [NSURL URLWithString:(NSString*)in_url];
        *out_base64Encoded = !hasTextContent(resourceType);
        if(*out_base64Encoded) {
            NSData* data = [[NSFileManager defaultManager] contentsAtPath:[url path]];
            if(data == nil) {
                errorString = WTF::ASCIILiteral("An error occurred");
            } else {
                NSString* base64Encoded = [data base64EncodedStringWithOptions:0];
                *out_content = WTF::String(base64Encoded);
            }
        } else {
            NSError* error;
            NSString* content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
            if(content == nil) {
                errorString = [error localizedDescription];
            } else {
                *out_content = WTF::String(content);
            }
        }
    }

}
