#pragma once

#include <JavaScriptCore/InspectorAgentBase.h>
#include <JavaScriptCore/inspector/InspectorBackendDispatchers.h>
#include <JavaScriptCore/inspector/InspectorFrontendDispatchers.h>

namespace Inspector {

class InspectorScriptProfilerAgent;

typedef String ErrorString;

enum class TimelineRecordType {
    EventDispatch,
    ScheduleStyleRecalculation,
    RecalculateStyles,
    InvalidateLayout,
    Layout,
    Paint,
    Composite,
    RenderingFrame,

    TimerInstall,
    TimerRemove,
    TimerFire,

    EvaluateScript,

    TimeStamp,
    Time,
    TimeEnd,

    FunctionCall,
    ProbeSample,
    ConsoleProfile,

    RequestAnimationFrame,
    CancelAnimationFrame,
    FireAnimationFrame,
};

class InspectorTimelineAgent final
    : public InspectorAgentBase,
      public TimelineBackendDispatcherHandler {
    WTF_MAKE_NONCOPYABLE(InspectorTimelineAgent);
    WTF_MAKE_FAST_ALLOCATED;

public:
    InspectorTimelineAgent(JSAgentContext&, Inspector::InspectorScriptProfilerAgent*);

    virtual void didCreateFrontendAndBackend(FrontendRouter*, BackendDispatcher*) override;
    virtual void willDestroyFrontendAndBackend(DisconnectReason) override;

    void startFromConsole(JSC::ExecState*, const String& title);
    void stopFromConsole(JSC::ExecState*, const String& title);

    void start(ErrorString&, const int* maxCallStackDepth = nullptr) final;
    void stop(ErrorString&) final;
    void setAutoCaptureEnabled(ErrorString&, bool) final;
    void setInstruments(ErrorString&, const JSON::Array&) final;

private:
    struct TimelineRecordEntry {
        TimelineRecordEntry()
            : type(TimelineRecordType::EventDispatch) {}
        TimelineRecordEntry(RefPtr<JSON::Object>&& record, RefPtr<JSON::Object>&& data, RefPtr<JSON::Array>&& children, TimelineRecordType type)
            : record(record)
            , data(data)
            , children(children)
            , type(type) {
        }

        RefPtr<JSON::Object> record;
        RefPtr<JSON::Object> data;
        RefPtr<JSON::Array> children;
        TimelineRecordType type;
    };

    void sendEvent(RefPtr<JSON::Object>&&);
    void startProgrammaticCapture();
    void stopProgrammaticCapture();
    void internalStart(const int* maxCallStackDepth = nullptr);
    void internalStop();

    enum class InstrumentState { Start,
                                 Stop };
    void toggleScriptProfilerInstrument(InstrumentState);
    void toggleTimelineInstrument(InstrumentState);
    void toggleInstruments(InstrumentState);

    TimelineRecordEntry createRecordEntry(RefPtr<JSON::Object>&& data, TimelineRecordType, bool captureCallStack);

    void didCompleteRecordEntry(const TimelineRecordEntry&);

    void addRecordToTimeline(RefPtr<JSON::Object>&&, TimelineRecordType);

    double timestamp();
    std::unique_ptr<TimelineFrontendDispatcher> m_frontendDispatcher;
    RefPtr<TimelineBackendDispatcher> m_backendDispatcher;
    Vector<TimelineRecordEntry> m_pendingConsoleProfileRecords;
    Vector<Inspector::Protocol::Timeline::Instrument> m_instruments;

    Inspector::InspectorScriptProfilerAgent* m_scriptProfilerAgent;
    NativeScript::GlobalObject& m_globalObject;
    TimelineRecordEntry m_consoleRecordEntry;
    int m_maxCallStackDepth;

    bool m_enabled;
    bool m_enabledFromFrontend;
    bool m_programmaticCaptureRestoreBreakpointActiveValue{ false };
};
} // namespace Inspector
