#include "TimelineRecordFactory.h"
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>

namespace Inspector {

Ref<JSON::Object> TimelineRecordFactory::createGenericRecord(JSC::ExecState* state, double startTime, int maxCallStackDepth) {
    Ref<JSON::Object> record = JSON::Object::create();
    record->setDouble("startTime"_s, startTime);

    if (maxCallStackDepth) {
        RefPtr<ScriptCallStack> stackTrace = createScriptCallStack(state, maxCallStackDepth);
        if (stackTrace && stackTrace->size())
            record->setValue("stackTrace"_s, stackTrace->buildInspectorArray());
    }
    return record;
}

Ref<JSON::Object> TimelineRecordFactory::createConsoleProfileData(const String& title) {
    Ref<JSON::Object> data = JSON::Object::create();
    data->setString("title", title);
    return data;
}
} // namespace Inspector
