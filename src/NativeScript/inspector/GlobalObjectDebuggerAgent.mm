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

#include "GlobalObjectDebuggerAgent.h"
#include "JSErrors.h"
#include "LiveEdit/ClearChangedCellsFunctor.h"
#include "LiveEdit/EditableSourceProvider.h"
#include <JavaScriptCore/ConsoleMessage.h>
#include <JavaScriptCore/HeapIterationScope.h>
#include <JavaScriptCore/InjectedScriptManager.h>
#include <JavaScriptCore/JSGlobalObject.h>
#include <JavaScriptCore/JSMapIterator.h>
#include <JavaScriptCore/JSModuleLoader.h>
#include <JavaScriptCore/JSModuleRecord.h>
#include <JavaScriptCore/Parser.h>
#include <JavaScriptCore/ScriptArguments.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>
#include <JavaScriptCore/config.h>
#include <JavaScriptCore/heap/MarkedSpaceInlines.h>
#include <JavaScriptCore/inspector/agents/InspectorConsoleAgent.h>
#include <wtf/text/StringBuilder.h>

using namespace JSC;
using namespace Inspector;

namespace NativeScript {

GlobalObjectDebuggerAgent::GlobalObjectDebuggerAgent(JSAgentContext& context, InspectorConsoleAgent* consoleAgent)
    : InspectorDebuggerAgent(context)
    , m_consoleAgent(consoleAgent) {
    m_globalObject = jsCast<NativeScript::GlobalObject*>(&context.inspectedGlobalObject);
}

void GlobalObjectDebuggerAgent::enable() {
    InspectorDebuggerAgent::enable();

    JSValue registry = this->m_globalObject->moduleLoader()->get(this->m_globalObject->globalExec(), Identifier::fromString(&this->m_globalObject->vm(), "registry"));
    JSMapIterator* registryIterator = JSMapIterator::create(this->m_globalObject->vm(), this->m_globalObject->mapIteratorStructure(), jsCast<JSMap*>(registry), IterateKeyValue);

    JSValue moduleKey, moduleEntry;
    Identifier moduleIdentifier = Identifier::fromString(&this->m_globalObject->vm(), "module");
    while (registryIterator->nextKeyValue(this->m_globalObject->globalExec(), moduleKey, moduleEntry)) {
        if (JSModuleRecord* record = jsDynamicCast<JSModuleRecord*>(moduleEntry.get(this->m_globalObject->globalExec(), moduleIdentifier))) {
            SourceProvider* sourceProvider = record->sourceCode().provider();
            JSValue function = record->getDirect(this->m_globalObject->vm(), m_globalObject->commonJSModuleFunctionIdentifier());
            if (!function.isEmpty() && !function.isUndefinedOrNull()) {
                if (JSFunction* moduleFunction = jsDynamicCast<JSFunction*>(record->getDirect(this->m_globalObject->vm(), m_globalObject->commonJSModuleFunctionIdentifier()))) {
                    sourceProvider = moduleFunction->sourceCode()->provider();
                }
            }
            this->m_globalObject->debugger()->sourceParsed(this->m_globalObject->globalExec(), sourceProvider, -1, WTF::emptyString());
        }
    }
}

void GlobalObjectDebuggerAgent::setScriptSource(Inspector::ErrorString& error, const String& scriptIdStr, const String& scriptSource) {

    JSValue registry = this->m_globalObject->moduleLoader()->get(this->m_globalObject->globalExec(), Identifier::fromString(&this->m_globalObject->vm(), "registry"));
    JSMap* map = jsCast<JSMap*>(registry);
    WTF::String scriptAbsolutePath = [NSString pathWithComponents:@[ this->m_globalObject->applicationPath(), @"app", scriptIdStr ]];
    JSValue value = map->get(this->m_globalObject->globalExec(), JSC::jsString(&this->m_globalObject->vm(), scriptAbsolutePath));
    Identifier moduleIdentifier = Identifier::fromString(&this->m_globalObject->vm(), "module");

    if (value.isUndefined()) {
        error = String::format("Could not find module at path: '%s'", scriptAbsolutePath.utf8().data());

        return;
    }

    if (JSModuleRecord* moduleRecord = jsDynamicCast<JSModuleRecord*>(value.get(this->m_globalObject->globalExec(), moduleIdentifier))) {
        SourceCode& sourceCode = const_cast<SourceCode&>(moduleRecord->sourceCode());
        EditableSourceProvider* sourceProvider = static_cast<EditableSourceProvider*>(sourceCode.provider());

        WTF::String moduleSource;
        ParserError parseError;
        std::unique_ptr<ScopeNode> program;

        JSValue value = moduleRecord->getDirect(this->m_globalObject->vm(), m_globalObject->commonJSModuleFunctionIdentifier());
        if (!value.isEmpty()) {
            if (JSFunction* moduleFunction = jsDynamicCast<JSFunction*>(value)) {
                sourceProvider = static_cast<EditableSourceProvider*>(moduleFunction->sourceCode()->provider());
                sourceCode = *moduleFunction->sourceCode();

                WTF::StringBuilder moduleFunctionSource;
                moduleFunctionSource.append("{function anonymous(require, module, exports, __dirname, __filename) {");
                moduleFunctionSource.append(scriptSource);
                moduleFunctionSource.append("\n}}");

                moduleSource = moduleFunctionSource.toString();

                SourceCode updatedSourceCode = makeSource(moduleSource).subExpression(sourceCode.startOffset(), moduleSource.length() - 2, 1, sourceCode.startColumn() - 1);
                program = parse<FunctionNode>(&m_globalObject->vm(), updatedSourceCode, Identifier(), JSParserBuiltinMode::NotBuiltin, JSParserStrictMode::NotStrict, JSParserScriptMode::Classic, SourceParseMode::MethodMode, SuperBinding::NotNeeded, parseError);
            }
        } else {
            moduleSource = scriptSource;
            program = parse<JSC::ProgramNode>(&m_globalObject->vm(), sourceCode, Identifier(), JSParserBuiltinMode::NotBuiltin, JSParserStrictMode::NotStrict, JSParserScriptMode::Module, SourceParseMode::ModuleEvaluateMode, SuperBinding::NotNeeded, parseError);
        }

        WTF::Vector<DiffChunk> diff = TextualDifferencesHelper::CompareStrings(moduleSource, sourceCode.provider()->source().toString());
        sourceProvider->setSource(moduleSource);
        sourceCode.setEndOffset(sourceProvider->source().length());

        if (!program) {
            JSObject* errorObject = parseError.toErrorObject(this->m_globalObject, sourceCode);
            Exception* exception = Exception::create(this->m_globalObject->vm(), errorObject);

            reportFatalErrorBeforeShutdown(this->m_globalObject->globalExec(), exception);
        }

        m_globalObject->vm().clearSourceProviderCaches();
        const ClearChangedCellsFunctor functor(moduleRecord->sourceCode().provider()->url(), diff);
        {
            HeapIterationScope iterationScope(m_globalObject->vm().heap);
            m_globalObject->vm().heap.objectSpace().forEachLiveCell(iterationScope, functor);
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

void GlobalObjectDebuggerAgent::breakpointActionLog(JSC::ExecState& exec, const String& message) {
    m_consoleAgent->addMessageToConsole(std::make_unique<ConsoleMessage>(MessageSource::JS, MessageType::Log, MessageLevel::Log, message, createScriptCallStack(&exec, ScriptCallStack::maxCallStackSizeToCapture), 0));
}

} // namespace Inspector
