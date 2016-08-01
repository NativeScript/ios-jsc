
#ifndef __NativeScript__InspectorPageAgent__
#define __NativeScript__InspectorPageAgent__

#include "CachedResource.h"
#include <JavaScriptCore/inspector/InspectorAgentBase.h>
#include <JavaScriptCore/inspector/InspectorBackendDispatchers.h>
#include <JavaScriptCore/inspector/InspectorFrontendDispatchers.h>
#include <map>

namespace Inspector {
class InspectorPageAgent
    : public InspectorAgentBase,
      public PageBackendDispatcherHandler {
    WTF_MAKE_NONCOPYABLE(InspectorPageAgent);
    WTF_MAKE_FAST_ALLOCATED;

public:
    InspectorPageAgent(JSAgentContext&);
    virtual void didCreateFrontendAndBackend(FrontendRouter*, BackendDispatcher*) override;
    virtual void willDestroyFrontendAndBackend(DisconnectReason) override;

    virtual void enable(ErrorString&) override;
    virtual void disable(ErrorString&) override;
    virtual void addScriptToEvaluateOnLoad(ErrorString&, const String& in_scriptSource, String* out_identifier) override;
    virtual void removeScriptToEvaluateOnLoad(ErrorString&, const String& in_identifier) override;
    virtual void reload(ErrorString&, const bool* in_ignoreCache, const String* in_scriptToEvaluateOnLoad) override;
    virtual void navigate(ErrorString&, const String& in_url) override;
    virtual void getCookies(ErrorString&, RefPtr<Inspector::Protocol::Array<Inspector::Protocol::Page::Cookie>>& out_cookies) override;
    virtual void deleteCookie(ErrorString&, const String& in_cookieName, const String& in_url) override;
    virtual void getResourceTree(ErrorString&, RefPtr<Inspector::Protocol::Page::FrameResourceTree>& out_frameTree) override;
    virtual void getResourceContent(ErrorString&, const String& in_frameId, const String& in_url, String* out_content, bool* out_base64Encoded) override;
    virtual void searchInResource(ErrorString&, const String& in_frameId, const String& in_url, const String& in_query, const bool* in_caseSensitive, const bool* in_isRegex, RefPtr<Inspector::Protocol::Array<Inspector::Protocol::GenericTypes::SearchMatch>>& out_result) override;
    virtual void searchInResources(ErrorString&, const String& in_text, const bool* in_caseSensitive, const bool* in_isRegex, RefPtr<Inspector::Protocol::Array<Inspector::Protocol::Page::SearchResult>>& out_result) override;
    virtual void setDocumentContent(ErrorString&, const String& in_frameId, const String& in_html) override;
    virtual void setShowPaintRects(ErrorString&, bool in_result) override;

    virtual void getScriptExecutionStatus(ErrorString&, PageBackendDispatcherHandler::Result* out_result) override;
    virtual void setScriptExecutionDisabled(ErrorString&, bool in_value) override;
    virtual void setTouchEmulationEnabled(ErrorString&, bool in_enabled) override;
    virtual void setEmulatedMedia(ErrorString&, const String& in_media) override;
    virtual void getCompositingBordersVisible(ErrorString&, bool* out_result) override;
    virtual void setCompositingBordersVisible(ErrorString&, bool in_visible) override;
    virtual void snapshotNode(ErrorString&, int in_nodeId, String* out_dataURL) override;

    virtual void snapshotRect(ErrorString&, int in_x, int in_y, int in_width, int in_height, const String& in_coordinateSystem, String* out_dataURL) override;
    virtual void handleJavaScriptDialog(ErrorString&, bool in_accept, const String* in_promptText) override;
    virtual void archive(ErrorString&, String* out_data) override;

private:
    const WTF::String m_frameIdentifier;
    const WTF::String m_frameUrl;
    NativeScript::GlobalObject& m_globalObject;
    std::unique_ptr<PageFrontendDispatcher> m_frontendDispatcher;
    RefPtr<PageBackendDispatcher> m_backendDispatcher;
};
}

#endif /* defined(__NativeScript__InspectorPageAgent__) */
