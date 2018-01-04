#include "InspectorTimelineAgent.h"
#include "GlobalObjectInspectorController.h"
#include "TimelineRecordFactory.h"
#include <JavaScriptCore/ConsoleMessage.h>
#include <JavaScriptCore/InspectorConsoleAgent.h>
#include <JavaScriptCore/InspectorDebuggerAgent.h>
#include <JavaScriptCore/InspectorEnvironment.h>
#include <JavaScriptCore/InspectorScriptProfilerAgent.h>
#include <JavaScriptCore/SamplingProfiler.h>

namespace Inspector {

InspectorTimelineAgent::InspectorTimelineAgent(JSAgentContext& context, Inspector::InspectorScriptProfilerAgent* scriptProfilerAgent)
    : Inspector::InspectorAgentBase(ASCIILiteral("Timeline"))
    , m_scriptProfilerAgent(scriptProfilerAgent)
    , m_globalObject(*JSC::jsCast<NativeScript::GlobalObject*>(&context.inspectedGlobalObject))
    , m_consoleRecordEntry()
    , m_maxCallStackDepth(5)
    , m_enabled(false) {

    this->m_frontendDispatcher = std::make_unique<TimelineFrontendDispatcher>(context.frontendRouter);
    this->m_backendDispatcher = TimelineBackendDispatcher::create(context.backendDispatcher, this);
}

void InspectorTimelineAgent::sendEvent(RefPtr<InspectorObject>&& event) {
    if (!m_frontendDispatcher)
        return;

    // FIXME: runtimeCast is a hack. We do it because we can't build TimelineEvent directly now.
    auto recordChecked = BindingTraits<Inspector::Protocol::Timeline::TimelineEvent>::runtimeCast(WTFMove(event));
    m_frontendDispatcher->eventRecorded(WTFMove(recordChecked));
}

void InspectorTimelineAgent::didCreateFrontendAndBackend(FrontendRouter* frontendRouter, BackendDispatcher* backendDispatcher) {
    this->m_globalObject.inspectorController().setTimelineAgent(this);
}

void InspectorTimelineAgent::willDestroyFrontendAndBackend(DisconnectReason) {

    ErrorString unused;
    stop(unused);

    this->m_globalObject.inspectorController().setTimelineAgent(nullptr);
    m_instruments.clear();
}

void InspectorTimelineAgent::start(ErrorString&, const int* maxCallStackDepth) {
    m_enabledFromFrontend = true;

    startFromConsole(this->m_globalObject.globalExec(), emptyString());
}

void InspectorTimelineAgent::stop(ErrorString&) {
    stopFromConsole(this->m_globalObject.globalExec(), emptyString());
    toggleTimelineInstrument(InstrumentState::Stop);

    m_enabledFromFrontend = false;
}

void InspectorTimelineAgent::setInstruments(ErrorString& errorString, const InspectorArray& instruments) {
    Vector<Protocol::Timeline::Instrument> newInstruments;
    newInstruments.reserveCapacity(instruments.length());

    for (auto instrumentValue : instruments) {
        String enumValueString;
        if (!instrumentValue->asString(enumValueString)) {
            errorString = ASCIILiteral("Unexpected type in instruments list, should be string");
            return;
        }

        Optional<Protocol::Timeline::Instrument> instrumentType = Protocol::InspectorHelpers::parseEnumValueFromString<Protocol::Timeline::Instrument>(enumValueString);
        if (!instrumentType) {
            errorString = makeString("Unexpected enum value: ", enumValueString);
            return;
        }

        newInstruments.uncheckedAppend(*instrumentType);
    }

    m_instruments.swap(newInstruments);
}

void InspectorTimelineAgent::setAutoCaptureEnabled(ErrorString&, bool enabled) {
}

void InspectorTimelineAgent::startFromConsole(JSC::ExecState* exec, const String& title) {
    if (!m_enabledFromFrontend) {
        m_scriptProfilerAgent->programmaticCaptureStarted();
    }
    // Allow duplicate unnamed profiles. Disallow duplicate named profiles.
    if (!title.isEmpty()) {
        for (const TimelineRecordEntry& record : m_pendingConsoleProfileRecords) {
            String recordTitle;
            record.data->getString(ASCIILiteral("title"), recordTitle);
            if (recordTitle == title) {
                if (InspectorConsoleAgent* consoleAgent = m_globalObject.inspectorController().consoleAgent()) {
                    // FIXME: Send an enum to the frontend for localization?
                    String warning = title.isEmpty() ? ASCIILiteral("Unnamed Profile already exists") : makeString("Profile \"", title, "\" already exists");
                    consoleAgent->addMessageToConsole(std::make_unique<ConsoleMessage>(MessageSource::ConsoleAPI, MessageType::Profile, MessageLevel::Warning, warning));
                }
                return;
            }
        }
    }

    if (!m_enabled && m_pendingConsoleProfileRecords.isEmpty())
        startProgrammaticCapture();

    m_pendingConsoleProfileRecords.append(createRecordEntry(TimelineRecordFactory::createConsoleProfileData(title), TimelineRecordType::ConsoleProfile, true));
}

void InspectorTimelineAgent::stopFromConsole(JSC::ExecState*, const String& title) {
    // Stop profiles in reverse order. If the title is empty, then stop the last profile.
    // Otherwise, match the title of the profile to stop.
    for (int i = m_pendingConsoleProfileRecords.size() - 1; i >= 0; --i) {
        const TimelineRecordEntry& record = m_pendingConsoleProfileRecords[i];

        String recordTitle;
        record.data->getString(ASCIILiteral("title"), recordTitle);
        if (title.isEmpty() || recordTitle == title) {
            didCompleteRecordEntry(record);
            m_pendingConsoleProfileRecords.remove(i);

            if (!m_enabledFromFrontend && m_pendingConsoleProfileRecords.isEmpty())
                stopProgrammaticCapture();

            return;
        }
    }

    if (InspectorConsoleAgent* consoleAgent = m_globalObject.inspectorController().consoleAgent()) {
        // FIXME: Send an enum to the frontend for localization?
        String warning = title.isEmpty() ? ASCIILiteral("No profiles exist") : makeString("Profile \"", title, "\" does not exist");
        consoleAgent->addMessageToConsole(std::make_unique<ConsoleMessage>(MessageSource::ConsoleAPI, MessageType::ProfileEnd, MessageLevel::Warning, warning));
    }

    if (!m_enabledFromFrontend) {
        m_scriptProfilerAgent->programmaticCaptureStopped();
    }
}

void InspectorTimelineAgent::startProgrammaticCapture() {
    ASSERT(!m_enabled);

    // Disable breakpoints during programmatic capture.
    if (InspectorDebuggerAgent* debuggerAgent = m_globalObject.inspectorController().debuggerAgent()) {
        m_programmaticCaptureRestoreBreakpointActiveValue = debuggerAgent->breakpointsActive();
        if (m_programmaticCaptureRestoreBreakpointActiveValue) {
            ErrorString unused;
            debuggerAgent->setBreakpointsActive(unused, false);
        }
    } else
        m_programmaticCaptureRestoreBreakpointActiveValue = false;

    if (!m_enabledFromFrontend) {
        m_frontendDispatcher->programmaticCaptureStarted();

        toggleScriptProfilerInstrument(InstrumentState::Start); // Ensure JavaScript samping data.
        toggleTimelineInstrument(InstrumentState::Start); // Ensure Console Profile event records.
        toggleInstruments(InstrumentState::Start); // Any other instruments the frontend wants us to record.
    }
}

void InspectorTimelineAgent::stopProgrammaticCapture() {
    ASSERT(m_enabled);

    toggleInstruments(InstrumentState::Stop);
    toggleTimelineInstrument(InstrumentState::Stop);
    toggleScriptProfilerInstrument(InstrumentState::Stop);

    // Re-enable breakpoints if they were enabled.
    if (m_programmaticCaptureRestoreBreakpointActiveValue) {
        if (InspectorDebuggerAgent* debuggerAgent = m_globalObject.inspectorController().debuggerAgent()) {
            ErrorString unused;
            debuggerAgent->setBreakpointsActive(unused, true);
        }
    }

    m_frontendDispatcher->programmaticCaptureStopped();
}

void InspectorTimelineAgent::toggleInstruments(InstrumentState state) {
    for (auto instrumentType : m_instruments) {
        switch (instrumentType) {
        case Inspector::Protocol::Timeline::Instrument::ScriptProfiler: {
            toggleScriptProfilerInstrument(state);
            break;
        }
        case Inspector::Protocol::Timeline::Instrument::Heap: {
            //                toggleHeapInstrument(state);
            break;
        }
        case Inspector::Protocol::Timeline::Instrument::Memory: {
            //                toggleMemoryInstrument(state);
            break;
        }
        case Inspector::Protocol::Timeline::Instrument::Timeline:
            toggleTimelineInstrument(state);
            break;
        }
    }
}

void InspectorTimelineAgent::toggleScriptProfilerInstrument(InstrumentState state) {
    if (m_scriptProfilerAgent) {
        ErrorString unused;
        if (state == InstrumentState::Start) {
            const bool includeSamples = true;
            m_scriptProfilerAgent->startTracking(unused, &includeSamples);
        } else
            m_scriptProfilerAgent->stopTracking(unused);
    }
}

void InspectorTimelineAgent::toggleTimelineInstrument(InstrumentState state) {
    if (state == InstrumentState::Start)
        internalStart();
    else
        internalStop();
}

void InspectorTimelineAgent::internalStart(const int* in_maxCallStackDepth) {
    if (m_enabled)
        return;

    if (in_maxCallStackDepth && *in_maxCallStackDepth > 0)
        m_maxCallStackDepth = *in_maxCallStackDepth;
    else
        m_maxCallStackDepth = 5;

    PassRefPtr<Stopwatch> stopwatch = m_globalObject.inspectorController().executionStopwatch();
    if (!stopwatch->isActive())
        stopwatch->start();

    m_enabled = true;

    if (m_frontendDispatcher)
        m_frontendDispatcher->recordingStarted(timestamp());
}

void InspectorTimelineAgent::internalStop() {
    if (!m_enabled)
        return;

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
    return TimelineRecordEntry(WTFMove(record), WTFMove(data), InspectorArray::create(), type);
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
    case TimelineRecordType::Composite:
        return Inspector::Protocol::Timeline::EventType::Composite;
    case TimelineRecordType::RenderingFrame:
        return Inspector::Protocol::Timeline::EventType::RenderingFrame;

    case TimelineRecordType::TimerInstall:
        return Inspector::Protocol::Timeline::EventType::TimerInstall;
    case TimelineRecordType::TimerRemove:
        return Inspector::Protocol::Timeline::EventType::TimerRemove;
    case TimelineRecordType::TimerFire:
        return Inspector::Protocol::Timeline::EventType::TimerFire;

    case TimelineRecordType::EvaluateScript:
        return Inspector::Protocol::Timeline::EventType::EvaluateScript;

    case TimelineRecordType::TimeStamp:
        return Inspector::Protocol::Timeline::EventType::TimeStamp;
    case TimelineRecordType::Time:
        return Inspector::Protocol::Timeline::EventType::Time;
    case TimelineRecordType::TimeEnd:
        return Inspector::Protocol::Timeline::EventType::TimeEnd;

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
    }

    return Inspector::Protocol::Timeline::EventType::TimeStamp;
}

void InspectorTimelineAgent::addRecordToTimeline(RefPtr<InspectorObject>&& record, TimelineRecordType type) {
    ASSERT_ARG(record, record);
    record->setString("type", Inspector::Protocol::InspectorHelpers::getEnumConstantValue(toProtocol(type)));

    auto recordObject = BindingTraits<Inspector::Protocol::Timeline::TimelineEvent>::runtimeCast(WTFMove(record));
    sendEvent(WTFMove(recordObject));
}
} // namespace Inspector
