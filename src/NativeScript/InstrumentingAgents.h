#ifndef __NativeScript__InspectorInstruments__
#define __NativeScript__InspectorInstruments__

#include <stdio.h>
#include "InspectorTimelineAgent.h"

namespace Inspector {
class InstrumentingAgents {
public:
    InspectorTimelineAgent* inspectorTimelineAgent() const { return m_inspectorTimelineAgent; }
    void setInspectorTimelineAgent(InspectorTimelineAgent* agent) { m_inspectorTimelineAgent = agent; }

private:
    InspectorTimelineAgent* m_inspectorTimelineAgent;
};
}

#endif /* defined(__NativeScript__InspectorInstruments__) */
