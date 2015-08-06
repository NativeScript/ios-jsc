#include "ConsoleMethodOverrides.h"
#include "GlobalObject.h"
#include "inspector/GlobalObjectInspectorController.h"
#include "inspector/InspectorTimelineAgent.h"

using namespace JSC;

namespace NativeScript {

EncodedJSValue JSC_HOST_CALL consoleProfileTimeline(ExecState* execState) {
    NativeScript::GlobalObject* globalObject = jsCast<NativeScript::GlobalObject*>(execState->lexicalGlobalObject());
    Inspector::InspectorTimelineAgent* timelineAgent = globalObject->inspectorController().timelineAgent();
    if (timelineAgent) {
        Inspector::ErrorString unused;
        timelineAgent->start(unused, nullptr);
    }

    return JSValue::encode(jsUndefined());
}

EncodedJSValue JSC_HOST_CALL consoleProfileEndTimeline(ExecState* execState) {
    NativeScript::GlobalObject* globalObject = jsCast<NativeScript::GlobalObject*>(execState->lexicalGlobalObject());
    Inspector::InspectorTimelineAgent* timelineAgent = globalObject->inspectorController().timelineAgent();
    if (timelineAgent) {
        Inspector::ErrorString unused;
        timelineAgent->stop(unused);
    }

    return JSValue::encode(jsUndefined());
}
}
