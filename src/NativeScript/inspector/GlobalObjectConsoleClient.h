
#ifndef GlobalObjectConsoleClient_hpp
#define GlobalObjectConsoleClient_hpp

#include "InspectorLogAgent.h"
#include <GlobalObject.h>
#include <JavaScriptCore/InspectorConsoleAgent.h>
#include <JavaScriptCore/runtime/ConsoleClient.h>
#include <stdio.h>

namespace NativeScript {
class GlobalObjectConsoleClient : public JSC::ConsoleClient {
    WTF_MAKE_FAST_ALLOCATED;

public:
    explicit GlobalObjectConsoleClient(Inspector::InspectorConsoleAgent*, Inspector::InspectorLogAgent*);
    virtual ~GlobalObjectConsoleClient() {}

    static bool logToSystemConsole();
    static void setLogToSystemConsole(bool);

protected:
    virtual void messageWithTypeAndLevel(MessageType, MessageLevel, JSC::ExecState*, Ref<Inspector::ScriptArguments>&&) override;
    virtual void count(JSC::ExecState*, Ref<Inspector::ScriptArguments>&&) override;
    virtual void profile(JSC::ExecState*, const String& title) override;
    virtual void profileEnd(JSC::ExecState*, const String& title) override;
    virtual void takeHeapSnapshot(JSC::ExecState*, const String& title) override;
    virtual void time(JSC::ExecState*, const String& title) override;
    virtual void timeEnd(JSC::ExecState*, const String& title) override;
    virtual void timeStamp(JSC::ExecState*, Ref<Inspector::ScriptArguments>&&) override;

private:
    void warnUnimplemented(const String& method);
    void internalAddMessage(MessageType, MessageLevel, JSC::ExecState*, RefPtr<Inspector::ScriptArguments>&&);
    WTF::String getDirMessage(JSC::ExecState*, JSC::JSValue);
    WTF::String createMessageFromArguments(MessageType, JSC::ExecState*, RefPtr<Inspector::ScriptArguments>&&);
    void addMessageToAgentsConsole(std::unique_ptr<Inspector::ConsoleMessage>&&);

    Inspector::InspectorConsoleAgent* m_consoleAgent;
    Inspector::InspectorLogAgent* m_logAgent;
};
} // namespace NativeScript
#endif /* GlobalObjectConsoleClient_h */
