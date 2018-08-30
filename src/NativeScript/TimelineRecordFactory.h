#pragma once

#include <JavaScriptCore/InspectorProtocolObjects.h>
#include <wtf/JSONValues.h>

namespace Inspector {

class TimelineRecordFactory {
public:
    static Ref<JSON::Object> createGenericRecord(JSC::ExecState*, double startTime, int maxCallStackDepth);
    static Ref<JSON::Object> createConsoleProfileData(const String& title);
};
} // namespace Inspector
