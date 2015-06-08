#ifndef NativeScript_ConsoleMethodOverrides_h
#define NativeScript_ConsoleMethodOverrides_h

using namespace JSC;

namespace NativeScript {
EncodedJSValue JSC_HOST_CALL consoleProfileTimeline(ExecState* execState);

EncodedJSValue JSC_HOST_CALL consoleProfileEndTimeline(ExecState* execState);
}

#endif
