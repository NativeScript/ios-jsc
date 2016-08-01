#ifndef DomainInspectorAgent_h
#define DomainInspectorAgent_h

#include "DomainBackendDispatcher.h"
#include <JavaScriptCore/InspectorAgentBase.h>
#include <JavaScriptCore/StrongInlines.h>

namespace NativeScript {
class DomainInspectorAgent : public Inspector::InspectorAgentBase {
    WTF_MAKE_NONCOPYABLE(DomainInspectorAgent);
    WTF_MAKE_FAST_ALLOCATED;

public:
    DomainInspectorAgent(WTF::String domainName, JSC::JSCell* constructorFunction, Inspector::JSAgentContext&);

    virtual void didCreateFrontendAndBackend(Inspector::FrontendRouter*, Inspector::BackendDispatcher*) override;
    virtual void willDestroyFrontendAndBackend(Inspector::DisconnectReason) override;
    virtual void discardAgent() override;

private:
    Inspector::JSAgentContext& m_context;
    RefPtr<DomainBackendDispatcher> m_domainBackendDispatcher;
    JSC::Strong<JSC::JSCell> m_constructorFunction;
};
}
#endif /* DomainInspectorAgent_h */
