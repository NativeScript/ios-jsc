#include "TimelineRecordFactory.h"
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>

namespace Inspector {

Ref<InspectorObject> TimelineRecordFactory::createGenericRecord(JSC::ExecState* state, double startTime, int maxCallStackDepth) {
    Ref<InspectorObject> record = InspectorObject::create();
    record->setDouble("startTime", startTime);

    if (maxCallStackDepth) {
        RefPtr<ScriptCallStack> stackTrace = createScriptCallStack(state, maxCallStackDepth);
        if (stackTrace && stackTrace->size())
            record->setValue("stackTrace", stackTrace->buildInspectorArray());
    }
    return record;
}

Ref<InspectorObject> TimelineRecordFactory::createConsoleProfileData(const String& title) {
    Ref<InspectorObject> data = InspectorObject::create();
    data->setString("title", title);
    return WTFMove(data);
}

static Ref<Protocol::Timeline::CPUProfileNodeAggregateCallInfo> buildAggregateCallInfoInspectorObject(const JSC::ProfileNode* node) {
    double startTime = node->calls()[0].startTime();
    double endTime = node->calls().last().startTime() + node->calls().last().elapsedTime();

    double totalTime = 0;
    for (const JSC::ProfileNode::Call& call : node->calls())
        totalTime += call.elapsedTime();

    return Protocol::Timeline::CPUProfileNodeAggregateCallInfo::create()
        .setCallCount(node->calls().size())
        .setStartTime(startTime)
        .setEndTime(endTime)
        .setTotalTime(totalTime)
        .release();
}

static Ref<Protocol::Timeline::CPUProfileNode> buildInspectorObject(const JSC::ProfileNode* node) {
    auto result = Protocol::Timeline::CPUProfileNode::create()
                      .setId(node->id())
                      .setCallInfo(buildAggregateCallInfoInspectorObject(node))
                      .release();

    if (!node->functionName().isEmpty())
        result->setFunctionName(node->functionName());

    if (!node->url().isEmpty()) {
        result->setUrl(node->url());
        result->setLineNumber(node->lineNumber());
        result->setColumnNumber(node->columnNumber());
    }

    if (!node->children().isEmpty()) {
        auto children = Protocol::Array<Protocol::Timeline::CPUProfileNode>::create();
        for (RefPtr<JSC::ProfileNode> profileNode : node->children())
            children->addItem(buildInspectorObject(profileNode.get()));
        result->setChildren(WTF::move(children));
    }

    return WTFMove(result);
}

Ref<InspectorValue> TimelineRecordFactory::buildProfileInspectorObject(const JSC::Profile* profile) {
    auto rootNodes = Protocol::Array<Protocol::Timeline::CPUProfileNode>::create();
    for (RefPtr<JSC::ProfileNode> profileNode : profile->rootNode()->children())
        rootNodes->addItem(buildInspectorObject(profileNode.get()));

    return Protocol::Timeline::CPUProfile::create()
        .setRootNodes(WTF::move(rootNodes))
        .release();
}

void TimelineRecordFactory::appendProfile(InspectorObject* data, RefPtr<JSC::Profile>&& profile) {
    data->setValue(ASCIILiteral("profile"), buildProfileInspectorObject(profile.get()));
}
}