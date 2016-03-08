#include "InspectorNetworkAgent.h"
#include "CachedResource.h"

namespace Inspector {
InspectorNetworkAgent::InspectorNetworkAgent(JSAgentContext& context)
    : Inspector::InspectorAgentBase(ASCIILiteral("Network"))
    , m_globalObject(*JSC::jsCast<NativeScript::GlobalObject*>(&context.inspectedGlobalObject)) {
}

void InspectorNetworkAgent::didCreateFrontendAndBackend(Inspector::FrontendRouter* frontendRouter, Inspector::BackendDispatcher* backendDispatcher) {
    m_frontendDispatcher = std::make_unique<NetworkFrontendDispatcher>(*frontendRouter);
    m_backendDispatcher = NetworkBackendDispatcher::create(*backendDispatcher, this);
}

void InspectorNetworkAgent::willDestroyFrontendAndBackend(Inspector::DisconnectReason) {
}

void InspectorNetworkAgent::enable(ErrorString&) {
}

void InspectorNetworkAgent::disable(ErrorString&) {
}

void InspectorNetworkAgent::setExtraHTTPHeaders(ErrorString&, const Inspector::InspectorObject& headers) {
}

void InspectorNetworkAgent::getResponseBody(ErrorString&, const String& requestId, String* content, bool* base64Encoded) {
}

void InspectorNetworkAgent::setCacheDisabled(ErrorString&, bool cacheDisabled) {
}

void InspectorNetworkAgent::loadResource(ErrorString& errorString, const String& frameId, const String& urlString, Ref<LoadResourceCallback>&& callback) {
    WTF::HashMap<WTF::String, Inspector::CachedResource>& cachedResources = Inspector::cachedResources(this->m_globalObject);
    auto iterator = cachedResources.find(urlString);
    if (iterator != cachedResources.end()) {
        CachedResource& resource = iterator->value;
        ErrorString out_error;
        WTF::String content = resource.content(out_error);
        callback->sendSuccess(content, resource.mimeType(), 200);
    }
}
}