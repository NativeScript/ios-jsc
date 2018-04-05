#include "SuppressAllPauses.h"
#include <JavaScriptCore/Debugger.h>

namespace NativeScript {

static bool suppressAllPauses() {
    static std::once_flag initializeEnvVariableOnceFlag;
    static bool dontSupressAllPauses;

    std::call_once(initializeEnvVariableOnceFlag, []() {
        dontSupressAllPauses = getenv("ТNS_dontSuppressAllPauses");
    });

    return !dontSupressAllPauses;
}

SuppressAllPauses::SuppressAllPauses(JSC::JSGlobalObject& globalObject)
    : m_globalObject(globalObject) {
    if (suppressAllPauses()) {
        if (JSC::Debugger* debugger = this->m_globalObject.debugger())
            debugger->setSuppressAllPauses(true);
    }
}

SuppressAllPauses::~SuppressAllPauses() {
    if (suppressAllPauses()) {
        if (JSC::Debugger* debugger = this->m_globalObject.debugger()) {
            debugger->setSuppressAllPauses(false);
        }
    }
}
}; // namespace NativeScript
