#include "TimelineRecordFactory.h"
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>

namespace Inspector {

Ref<InspectorObject> TimelineRecordFactory::createGenericRecord(JSC::ExecState* state, double startTime, int maxCallStackDepth) {
    Ref<InspectorObject> record = InspectorObject::create();
    record->setDouble(ASCIILiteral("startTime"), startTime);

    if (maxCallStackDepth) {
        RefPtr<ScriptCallStack> stackTrace = createScriptCallStack(state, maxCallStackDepth);
        if (stackTrace && stackTrace->size())
            record->setValue(ASCIILiteral("stackTrace"), stackTrace->buildInspectorArray());
    }
    return record;
}

Ref<InspectorObject> TimelineRecordFactory::createConsoleProfileData(const String& title) {
    Ref<InspectorObject> data = InspectorObject::create();
    data->setString("title", title);
    return data;
}
} // namespace Inspector
