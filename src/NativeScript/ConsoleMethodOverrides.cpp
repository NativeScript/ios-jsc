#include "ConsoleMethodOverrides.h"
#include "GlobalObject.h"
#include "InspectorTimelineAgent.h"
#include "InstrumentingAgents.h"

using namespace JSC;

namespace NativeScript {

EncodedJSValue JSC_HOST_CALL consoleProfileTimeline(ExecState* execState) {
    NativeScript::GlobalObject* globalObject = jsCast<NativeScript::GlobalObject*>(execState->lexicalGlobalObject());
    Inspector::InspectorTimelineAgent* timelineAgent = globalObject->instrumentingAgents().inspectorTimelineAgent();
    if (timelineAgent) {
        Inspector::ErrorString unused;
        timelineAgent->start(unused, nullptr);
    }

    return JSValue::encode(jsUndefined());
}

EncodedJSValue JSC_HOST_CALL consoleProfileEndTimeline(ExecState* execState) {
    NativeScript::GlobalObject* globalObject = jsCast<NativeScript::GlobalObject*>(execState->lexicalGlobalObject());
    Inspector::InspectorTimelineAgent* timelineAgent = globalObject->instrumentingAgents().inspectorTimelineAgent();
    if (timelineAgent) {
        Inspector::ErrorString unused;
        timelineAgent->stop(unused);
    }

    return JSValue::encode(jsUndefined());
}
}
