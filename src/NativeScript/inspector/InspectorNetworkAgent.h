#pragma once

#include <JavaScriptCore/inspector/InspectorAgentBase.h>
#include <JavaScriptCore/inspector/InspectorBackendDispatchers.h>
#include <JavaScriptCore/inspector/InspectorFrontendDispatchers.h>

namespace Inspector {
class InspectorNetworkAgent final : public InspectorAgentBase, public Inspector::NetworkBackendDispatcherHandler {
public:
    InspectorNetworkAgent(JSAgentContext&);

    virtual void didCreateFrontendAndBackend(Inspector::FrontendRouter*, Inspector::BackendDispatcher*) override;
    virtual void willDestroyFrontendAndBackend(Inspector::DisconnectReason) override;

    virtual void enable(ErrorString&) override;
    virtual void disable(ErrorString&) override;
    virtual void setExtraHTTPHeaders(ErrorString&, const JSON::Object& headers) override;
    virtual void getResponseBody(ErrorString&, const String& requestId, String* content, bool* base64Encoded) override;
    virtual void setResourceCachingDisabled(ErrorString&, bool in_disabled) override;
    virtual void loadResource(ErrorString&, const String& frameId, const String& url, Ref<LoadResourceCallback>&&) override;
    virtual void resolveWebSocket(ErrorString&, const String& in_requestId, const String* const opt_in_objectGroup, RefPtr<Inspector::Protocol::Runtime::RemoteObject>& out_object) override;

private:
    NativeScript::GlobalObject& m_globalObject;
    std::unique_ptr<NetworkFrontendDispatcher> m_frontendDispatcher;
    RefPtr<NetworkBackendDispatcher> m_backendDispatcher;
};
} // namespace Inspector
