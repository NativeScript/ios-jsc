//
//  JSErrors.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 2/26/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "JSErrors.h"

#include <JavaScriptCore/JSGlobalObjectInspectorController.h>
#include "TNSRuntime+Private.h"
#include "TNSRuntime+Diagnostics.h"

namespace NativeScript {

using namespace JSC;

void reportFatalErrorBeforeShutdown(ExecState* execState, JSValue error) {
    TNSRuntime* runtime = static_cast<TNSRuntime*>(WTF::wtfThreadData().m_apiData);
    static_cast<GlobalObject*>(execState->lexicalGlobalObject())->inspectorController().reportAPIException(execState, error);

    if (runtime->_globalObject->debugger()) {
        warn(execState, WTF::ASCIILiteral("Fatal exception - application has been terminated."));
        while (true) {
            CFRunLoopRunInMode(CFSTR("com.apple.JavaScriptCore.remote-inspector-runloop-mode"), 0.1, false);
        }
    } else {
        WTFCrash();
    }
}
}