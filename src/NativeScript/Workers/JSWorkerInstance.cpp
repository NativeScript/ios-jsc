//
//  JSWorkerInstance.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 7/5/16.
//
//

#include "JSWorkerInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo JSWorkerInstance::s_info = { "Worker", &Base::s_info, 0, CREATE_METHOD_TABLE(JSWorkerInstance) };

void JSWorkerInstance::finishCreation(JSC::VM& vm, const WTF::String& moduleName) {
    Base::finishCreation(vm);
    this->moduleName = moduleName;

    // WorkerThreadStartMode startMode = DontPauseWorkerGlobalScopeOnStart;
    /* TODO: Check whether should stop on the first line on the Worker thread
     if (InspectorInstrumentation::shouldPauseDedicatedWorkerOnStart(scriptExecutionContext()))
     startMode = PauseWorkerGlobalScopeOnStart;
     */

    // TOD: Instead of starting the execution with a sythetic module which requires the real one, resolve and load the content of the real module
    //contextProxy->startWorkerGlobalScope(WTF::String("worker-synthetic-module"), WTF::makeString("require(", moduleName, ");"), startMode);

    /* TDOO: Notify the inspector that a script is imported
     InspectorInstrumentation::scriptImported(scriptExecutionContext(), m_scriptLoader->identifier(), m_scriptLoader->script());
     */
}
}