#pragma once

#include <JavaScriptCore/InspectorProtocolObjects.h>
#include <inspector/InspectorValues.h>

namespace Inspector {

class TimelineRecordFactory {
public:
    static Ref<InspectorObject> createGenericRecord(JSC::ExecState*, double startTime, int maxCallStackDepth);
    static Ref<InspectorObject> createConsoleProfileData(const String& title);
};
}

