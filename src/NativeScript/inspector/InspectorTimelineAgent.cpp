#include "InspectorTimelineAgent.h"
#include "TimelineRecordFactory.h"
#include <JavaScriptCore/InspectorEnvironment.h>
#include <JavaScriptCore/profiler/LegacyProfiler.h>
#include "GlobalObjectInspectorController.h"

namespace Inspector {

InspectorTimelineAgent::InspectorTimelineAgent(JSAgentContext& context)
    : Inspector::InspectorAgentBase(ASCIILiteral("Timeline"))
    , m_globalObject(*JSC::jsCast<NativeScript::GlobalObject*>(&context.inspectedGlobalObject))
    , m_consoleRecordEntry()
    , m_maxCallStackDepth(5)
    , m_enabled(false) {
}

void InspectorTimelineAgent::sendEvent(RefPtr<InspectorObject>&& event) {
    if (!m_frontendDispatcher)
        return;

    // FIXME: runtimeCast is a hack. We do it because we can't build TimelineEvent directly now.
    auto recordChecked = BindingTraits<Inspector::Protocol::Timeline::TimelineEvent>::runtimeCast(WTF::move(event));
    m_frontendDispatcher->eventRecorded(WTF::move(recordChecked));
}

void InspectorTimelineAgent::didCreateFrontendAndBackend(FrontendRouter* frontendRouter, BackendDispatcher* backendDispatcher) {
    m_frontendDispatcher = std::make_unique<TimelineFrontendDispatcher>(*frontendRouter);
    m_backendDispatcher = TimelineBackendDispatcher::create(*backendDispatcher, this);
}

void InspectorTimelineAgent::willDestroyFrontendAndBackend(DisconnectReason) {
    m_frontendDispatcher = nullptr;
    m_backendDispatcher = nullptr;

    ErrorString unused;
    stop(unused);
}

static inline void startProfiling(JSC::ExecState* exec, const String& title, PassRefPtr<Stopwatch> stopwatch) {
    JSC::LegacyProfiler::profiler()->startProfiling(exec, title, stopwatch);
}

static inline PassRefPtr<JSC::Profile> stopProfiling(JSC::ExecState* exec, const String& title) {
    return JSC::LegacyProfiler::profiler()->stopProfiling(exec, title);
}

void InspectorTimelineAgent::start(ErrorString&, const int* in_maxCallStackDepth) {
    if (m_enabled)
        return;

    if (in_maxCallStackDepth && *in_maxCallStackDepth > 0)
        m_maxCallStackDepth = *in_maxCallStackDepth;
    else
        m_maxCallStackDepth = 5;

    PassRefPtr<Stopwatch> stopwatch = m_globalObject.inspectorController().executionStopwatch();
    if (!stopwatch->isActive())
        stopwatch->start();

    if (m_frontendDispatcher)
        m_frontendDispatcher->recordingStarted(timestamp());

    startProfiling(m_globalObject.globalExec(), WTF::emptyString(), stopwatch);

    m_enabled = true;

    m_consoleRecordEntry = createRecordEntry(TimelineRecordFactory::createConsoleProfileData(WTF::emptyString()), TimelineRecordType::ConsoleProfile, true);
}

void InspectorTimelineAgent::stop(ErrorString&) {
    if (!m_enabled)
        return;

    RefPtr<JSC::Profile> profile = stopProfiling(m_globalObject.globalExec(), WTF::emptyString());
    if (profile)
        TimelineRecordFactory::appendProfile(m_consoleRecordEntry.data.get(), profile.copyRef());

    didCompleteRecordEntry(m_consoleRecordEntry);

    auto stopwatch = m_globalObject.inspectorController().executionStopwatch();
    if (stopwatch->isActive())
        stopwatch->stop();

    m_enabled = false;

    if (m_frontendDispatcher)
        m_frontendDispatcher->recordingStopped(timestamp());
}

void InspectorTimelineAgent::didCompleteRecordEntry(const TimelineRecordEntry& entry) {
    entry.record->setObject(ASCIILiteral("data"), entry.data);
    entry.record->setArray(ASCIILiteral("children"), entry.children);
    entry.record->setDouble(ASCIILiteral("endTime"), timestamp());
    addRecordToTimeline(entry.record.copyRef(), entry.type);
}

double InspectorTimelineAgent::timestamp() {
    return m_globalObject.inspectorController().executionStopwatch()->elapsedTime();
}

InspectorTimelineAgent::TimelineRecordEntry InspectorTimelineAgent::createRecordEntry(RefPtr<InspectorObject>&& data, TimelineRecordType type, bool captureCallStack) {
    Ref<InspectorObject> record = TimelineRecordFactory::createGenericRecord(m_globalObject.globalExec(), timestamp(), captureCallStack ? m_maxCallStackDepth : 0);
    return TimelineRecordEntry(WTF::move(record), WTF::move(data), InspectorArray::create(), type);
}

static Inspector::Protocol::Timeline::EventType toProtocol(TimelineRecordType type) {
    switch (type) {
    case TimelineRecordType::EventDispatch:
        return Inspector::Protocol::Timeline::EventType::EventDispatch;
    case TimelineRecordType::ScheduleStyleRecalculation:
        return Inspector::Protocol::Timeline::EventType::ScheduleStyleRecalculation;
    case TimelineRecordType::RecalculateStyles:
        return Inspector::Protocol::Timeline::EventType::RecalculateStyles;
    case TimelineRecordType::InvalidateLayout:
        return Inspector::Protocol::Timeline::EventType::InvalidateLayout;
    case TimelineRecordType::Layout:
        return Inspector::Protocol::Timeline::EventType::Layout;
    case TimelineRecordType::Paint:
        return Inspector::Protocol::Timeline::EventType::Paint;
    case TimelineRecordType::RenderingFrame:
        return Inspector::Protocol::Timeline::EventType::RenderingFrame;
    case TimelineRecordType::ScrollLayer:
        return Inspector::Protocol::Timeline::EventType::ScrollLayer;

    case TimelineRecordType::ParseHTML:
        return Inspector::Protocol::Timeline::EventType::ParseHTML;

    case TimelineRecordType::TimerInstall:
        return Inspector::Protocol::Timeline::EventType::TimerInstall;
    case TimelineRecordType::TimerRemove:
        return Inspector::Protocol::Timeline::EventType::TimerRemove;
    case TimelineRecordType::TimerFire:
        return Inspector::Protocol::Timeline::EventType::TimerFire;

    case TimelineRecordType::EvaluateScript:
        return Inspector::Protocol::Timeline::EventType::EvaluateScript;

    case TimelineRecordType::MarkLoad:
        return Inspector::Protocol::Timeline::EventType::MarkLoad;
    case TimelineRecordType::MarkDOMContent:
        return Inspector::Protocol::Timeline::EventType::MarkDOMContent;

    case TimelineRecordType::TimeStamp:
        return Inspector::Protocol::Timeline::EventType::TimeStamp;
    case TimelineRecordType::Time:
        return Inspector::Protocol::Timeline::EventType::Time;
    case TimelineRecordType::TimeEnd:
        return Inspector::Protocol::Timeline::EventType::TimeEnd;

    case TimelineRecordType::XHRReadyStateChange:
        return Inspector::Protocol::Timeline::EventType::XHRReadyStateChange;
    case TimelineRecordType::XHRLoad:
        return Inspector::Protocol::Timeline::EventType::XHRLoad;

    case TimelineRecordType::FunctionCall:
        return Inspector::Protocol::Timeline::EventType::FunctionCall;
    case TimelineRecordType::ProbeSample:
        return Inspector::Protocol::Timeline::EventType::ProbeSample;
    case TimelineRecordType::ConsoleProfile:
        return Inspector::Protocol::Timeline::EventType::ConsoleProfile;

    case TimelineRecordType::RequestAnimationFrame:
        return Inspector::Protocol::Timeline::EventType::RequestAnimationFrame;
    case TimelineRecordType::CancelAnimationFrame:
        return Inspector::Protocol::Timeline::EventType::CancelAnimationFrame;
    case TimelineRecordType::FireAnimationFrame:
        return Inspector::Protocol::Timeline::EventType::FireAnimationFrame;

    case TimelineRecordType::WebSocketCreate:
        return Inspector::Protocol::Timeline::EventType::WebSocketCreate;
    case TimelineRecordType::WebSocketSendHandshakeRequest:
        return Inspector::Protocol::Timeline::EventType::WebSocketSendHandshakeRequest;
    case TimelineRecordType::WebSocketReceiveHandshakeResponse:
        return Inspector::Protocol::Timeline::EventType::WebSocketReceiveHandshakeResponse;
    case TimelineRecordType::WebSocketDestroy:
        return Inspector::Protocol::Timeline::EventType::WebSocketDestroy;
    }

    return Inspector::Protocol::Timeline::EventType::TimeStamp;
}

void InspectorTimelineAgent::addRecordToTimeline(RefPtr<InspectorObject>&& record, TimelineRecordType type) {
    ASSERT_ARG(record, record);
    record->setString("type", Inspector::Protocol::getEnumConstantValue(toProtocol(type)));

    auto recordObject = BindingTraits<Inspector::Protocol::Timeline::TimelineEvent>::runtimeCast(WTF::move(record));
    sendEvent(WTF::move(recordObject));
}
}