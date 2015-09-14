#ifndef DomainBackendDispatcher_h
#define DomainBackendDispatcher_h

#include <inspector/InspectorBackendDispatcher.h>
#include <JavaScriptCore/StrongInlines.h>

namespace NativeScript {
class JS_EXPORT_PRIVATE DomainBackendDispatcher final : public Inspector::SupplementalBackendDispatcher {
public:
    static Ref<DomainBackendDispatcher> create(WTF::String domain, JSC::JSCell* constructorFunction, Inspector::BackendDispatcher*, NativeScript::GlobalObject&);
    virtual void dispatch(long callId, const String& method, Ref<Inspector::InspectorObject>&& message) override;

private:
    DomainBackendDispatcher(WTF::String domain, JSC::JSCell* constructorFunction, Inspector::BackendDispatcher&, NativeScript::GlobalObject&);

    NativeScript::GlobalObject& m_globalObject;
    JSC::Strong<JSC::JSObject> m_domainDispatcher;
};
}
#endif /* DomainBackendDispatcher_h */
