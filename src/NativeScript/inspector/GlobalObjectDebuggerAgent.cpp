/*
 * Copyright (C) 2014 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "NativeScript-Prefix.h"
#include "GlobalObjectDebuggerAgent.h"
#include "SourceProviderManager.h"
#include <JavaScriptCore/config.h>
#include <JavaScriptCore/ConsoleMessage.h>
#include <JavaScriptCore/InjectedScriptManager.h>
#include <JavaScriptCore/inspector/agents/InspectorConsoleAgent.h>
#include <JavaScriptCore/JSGlobalObject.h>
#include <JavaScriptCore/ScriptArguments.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>
#include <JavaScriptCore/ModuleLoaderObject.h>
#include <JavaScriptCore/JSModuleRecord.h>
#include <JavaScriptCore/JSMapIterator.h>
#include <JavaScriptCore/MapDataInlines.h>

using namespace JSC;
using namespace Inspector;

namespace NativeScript {

GlobalObjectDebuggerAgent::GlobalObjectDebuggerAgent(JSAgentContext& context, InspectorConsoleAgent* consoleAgent)
    : InspectorDebuggerAgent(context)
    , m_consoleAgent(consoleAgent) {
    m_globalObject = jsCast<NativeScript::GlobalObject*>(&context.inspectedGlobalObject);
}

void GlobalObjectDebuggerAgent::enable(ErrorString& errorString) {
    InspectorDebuggerAgent::enable(errorString);

    JSValue registry = this->m_globalObject->moduleLoader()->get(this->m_globalObject->globalExec(), Identifier::fromString(&this->m_globalObject->vm(), "registry"));
    JSMapIterator* registryIterator = JSMapIterator::create(this->m_globalObject->vm(), this->m_globalObject->mapIteratorStructure(), jsCast<JSMap*>(registry), MapIterateKeyValue);

    JSValue moduleKey, moduleEntry;
    Identifier moduleIdentifier = Identifier::fromString(&this->m_globalObject->vm(), "module");
    while (registryIterator->nextKeyValue(moduleKey, moduleEntry)) {
        if (JSModuleRecord* record = jsDynamicCast<JSModuleRecord*>(moduleEntry.get(this->m_globalObject->globalExec(), moduleIdentifier))) {
            SourceProvider* sourceProvider = record->sourceCode().provider();
            if (JSFunction* moduleFunction = jsDynamicCast<JSFunction*>(record->getDirect(this->m_globalObject->vm(), m_globalObject->commonJSModuleFunctionIdentifier()))) {
                sourceProvider = moduleFunction->sourceCode()->provider();
            }
            this->m_globalObject->debugger()->sourceParsed(this->m_globalObject->globalExec(), sourceProvider, -1, WTF::emptyString());
        }
    }
}

InjectedScript GlobalObjectDebuggerAgent::injectedScriptForEval(ErrorString& error, const int* executionContextId) {
    if (executionContextId) {
        error = ASCIILiteral("Execution context id is not supported for JSContext inspection as there is only one execution context.");
        return InjectedScript();
    }

    ExecState* exec = static_cast<JSGlobalObjectScriptDebugServer&>(scriptDebugServer()).globalObject().globalExec();
    return injectedScriptManager().injectedScriptFor(exec);
}

void GlobalObjectDebuggerAgent::breakpointActionLog(JSC::ExecState* exec, const String& message) {
    m_consoleAgent->addMessageToConsole(std::make_unique<ConsoleMessage>(MessageSource::JS, MessageType::Log, MessageLevel::Log, message, createScriptCallStack(exec, ScriptCallStack::maxCallStackSizeToCapture), 0));
}

} // namespace Inspector
