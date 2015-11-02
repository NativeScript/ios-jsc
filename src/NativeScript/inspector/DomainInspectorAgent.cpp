#include <JavaScriptCore/JSObject.h>
#include "DomainInspectorAgent.h"
#include "GlobalObjectInspectorController.h"

namespace NativeScript {
DomainInspectorAgent::DomainInspectorAgent(GlobalObject& globalObject, WTF::String domainName, JSC::JSCell* constructorFunction)
    : Inspector::InspectorAgentBase(domainName)
    , m_globalObject(globalObject)
    , m_constructorFunction(m_globalObject.vm(), constructorFunction) {}

void DomainInspectorAgent::didCreateFrontendAndBackend(Inspector::FrontendChannel*, Inspector::BackendDispatcher* backendDispatcher) {
    m_backendDispatcher = backendDispatcher;

    this->m_domainBackendDispatcher = DomainBackendDispatcher::create(this->domainName(), m_constructorFunction.get(), m_backendDispatcher, m_globalObject);
}

void DomainInspectorAgent::willDestroyFrontendAndBackend(Inspector::DisconnectReason) {
    m_domainBackendDispatcher = nullptr;
    m_constructorFunction.clear();
}
}