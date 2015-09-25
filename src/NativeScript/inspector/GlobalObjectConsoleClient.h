
#ifndef GlobalObjectConsoleClient_hpp
#define GlobalObjectConsoleClient_hpp

#include <stdio.h>
#include <JavaScriptCore/runtime/ConsoleClient.h>
#include <JavaScriptCore/InspectorConsoleAgent.h>

namespace NativeScript {
class GlobalObjectConsoleClient : public JSC::ConsoleClient {
    WTF_MAKE_FAST_ALLOCATED;

public:
    explicit GlobalObjectConsoleClient(Inspector::InspectorConsoleAgent*);
    virtual ~GlobalObjectConsoleClient() {}

    static bool logToSystemConsole();
    static void setLogToSystemConsole(bool);

protected:
    virtual void messageWithTypeAndLevel(MessageType, MessageLevel, JSC::ExecState*, RefPtr<Inspector::ScriptArguments>&&) override;
    virtual void count(JSC::ExecState*, RefPtr<Inspector::ScriptArguments>&&) override;
    virtual void profile(JSC::ExecState*, const String& title) override;
    virtual void profileEnd(JSC::ExecState*, const String& title) override;
    virtual void time(JSC::ExecState*, const String& title) override;
    virtual void timeEnd(JSC::ExecState*, const String& title) override;
    virtual void timeStamp(JSC::ExecState*, RefPtr<Inspector::ScriptArguments>&&) override;

private:
    void warnUnimplemented(const String& method);
    void internalAddMessage(MessageType, MessageLevel, JSC::ExecState*, RefPtr<Inspector::ScriptArguments>&&);

    Inspector::InspectorConsoleAgent* m_consoleAgent;
};
}
#endif /* GlobalObjectConsoleClient_h */
