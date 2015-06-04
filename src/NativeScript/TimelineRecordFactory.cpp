#include "TimelineRecordFactory.h"
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>


namespace Inspector {
    
    Ref<InspectorObject> TimelineRecordFactory::createGenericRecord(JSC::ExecState* state, double startTime, int maxCallStackDepth)
    {
        Ref<InspectorObject> record = InspectorObject::create();
        record->setDouble("startTime", startTime);
        
        if (maxCallStackDepth) {
            RefPtr<ScriptCallStack> stackTrace = createScriptCallStack(state, maxCallStackDepth);
            if (stackTrace && stackTrace->size())
                record->setValue("stackTrace", stackTrace->buildInspectorArray());
        }
        return WTF::move(record);
    }
    
    Ref<InspectorObject> TimelineRecordFactory::createConsoleProfileData(const String& title)
    {
        Ref<InspectorObject> data = InspectorObject::create();
        data->setString("title", title);
        return WTF::move(data);
    }
    
    static Ref<Protocol::Timeline::CPUProfileNodeCall> buildInspectorObject(const JSC::ProfileNode::Call& call)
    {
        return Protocol::Timeline::CPUProfileNodeCall::create()
        .setStartTime(call.startTime())
        .setTotalTime(call.elapsedTime())
        .release();
    }
    
    static Ref<Protocol::Timeline::CPUProfileNode> buildInspectorObject(const JSC::ProfileNode* node)
    {
        auto calls = Protocol::Array<Protocol::Timeline::CPUProfileNodeCall>::create();
        for (const JSC::ProfileNode::Call& call : node->calls())
            calls->addItem(buildInspectorObject(call));
        
        auto result = Protocol::Timeline::CPUProfileNode::create()
        .setId(node->id())
        .setCalls(WTF::move(calls))
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
        
        return WTF::move(result);
    }
    
    static Ref<Protocol::Timeline::CPUProfile> buildProfileInspectorObject(const JSC::Profile* profile)
    {
        auto rootNodes = Protocol::Array<Protocol::Timeline::CPUProfileNode>::create();
        for (RefPtr<JSC::ProfileNode> profileNode : profile->rootNode()->children())
            rootNodes->addItem(buildInspectorObject(profileNode.get()));
        
        return Protocol::Timeline::CPUProfile::create()
        .setRootNodes(WTF::move(rootNodes))
        .release();
    }
    
    void TimelineRecordFactory::appendProfile(InspectorObject* data, RefPtr<JSC::Profile>&& profile)
    {
        data->setValue(ASCIILiteral("profile"), buildProfileInspectorObject(profile.get()));
    }
}