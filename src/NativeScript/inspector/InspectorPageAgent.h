
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
    virtual void reload(ErrorString&, const bool* const opt_in_ignoreCache, const bool* const opt_in_revalidateAllResources, const String* const opt_in_scriptToEvaluateOnLoad) override;
    virtual void navigate(ErrorString&, const String& in_url) override;
    virtual void getCookies(ErrorString&, RefPtr<Inspector::Protocol::Array<Inspector::Protocol::Page::Cookie>>& out_cookies) override;
    virtual void deleteCookie(ErrorString&, const String& in_cookieName, const String& in_url) override;
    virtual void getResourceTree(ErrorString&, RefPtr<Inspector::Protocol::Page::FrameResourceTree>& out_frameTree) override;
    virtual void getResourceContent(ErrorString&, const String& in_frameId, const String& in_url, String* out_content, bool* out_base64Encoded) override;
    virtual void searchInResource(ErrorString&, const String& frameId, const String& url, const String& query, const bool* optionalCaseSensitive, const bool* optionalIsRegex, const String* optionalRequestId, RefPtr<Inspector::Protocol::Array<Inspector::Protocol::GenericTypes::SearchMatch>>&) override;
    virtual void searchInResources(ErrorString&, const String& in_text, const bool* in_caseSensitive, const bool* in_isRegex, RefPtr<Inspector::Protocol::Array<Inspector::Protocol::Page::SearchResult>>& out_result) override;
    virtual void setShowPaintRects(ErrorString&, bool in_result) override;

    virtual void setEmulatedMedia(ErrorString&, const String& in_media) override;
    virtual void getCompositingBordersVisible(ErrorString&, bool* out_result) override;
    virtual void setCompositingBordersVisible(ErrorString&, bool in_visible) override;
    virtual void snapshotNode(ErrorString&, int in_nodeId, String* out_dataURL) override;

    virtual void snapshotRect(ErrorString&, int in_x, int in_y, int in_width, int in_height, const String& in_coordinateSystem, String* out_dataURL) override;
    virtual void archive(ErrorString&, String* out_data) override;

private:
    const WTF::String m_frameIdentifier;
    const WTF::String m_frameUrl;
    NativeScript::GlobalObject& m_globalObject;
    std::unique_ptr<PageFrontendDispatcher> m_frontendDispatcher;
    RefPtr<PageBackendDispatcher> m_backendDispatcher;
};
} // namespace Inspector

#endif /* defined(__NativeScript__InspectorPageAgent__) */
