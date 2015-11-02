#ifndef DomainInspectorAgent_h
#define DomainInspectorAgent_h

#include <JavaScriptCore/InspectorAgentBase.h>
#include <JavaScriptCore/StrongInlines.h>
#include "DomainBackendDispatcher.h"

namespace NativeScript {
class DomainInspectorAgent : public Inspector::InspectorAgentBase {
    WTF_MAKE_NONCOPYABLE(DomainInspectorAgent);
    WTF_MAKE_FAST_ALLOCATED;

public:
    DomainInspectorAgent(GlobalObject&, WTF::String domainName, JSC::JSCell* constructorFunction);

    virtual void didCreateFrontendAndBackend(Inspector::FrontendChannel*, Inspector::BackendDispatcher*) override;
    virtual void willDestroyFrontendAndBackend(Inspector::DisconnectReason) override;

private:
    GlobalObject& m_globalObject;
    Inspector::BackendDispatcher* m_backendDispatcher;
    RefPtr<DomainBackendDispatcher> m_domainBackendDispatcher;
    JSC::Strong<JSC::JSCell> m_constructorFunction;
};
}
#endif /* DomainInspectorAgent_h */
