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
#include <cstdlib>
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
    JSMapIterator* registryIterator = JSMapIterator::create(this->m_globalObject->vm(), this->m_globalObject->vm().mapIteratorStructure.get(), jsCast<JSMap*>(registry), IterateKeyValue);

    JSValue moduleKey, moduleEntry;
    VM& vm = this->m_globalObject->vm();
    Identifier moduleIdentifier = Identifier::fromString(&vm, "module");
    while (registryIterator->nextKeyValue(this->m_globalObject->globalExec(), moduleKey, moduleEntry)) {
        if (JSModuleRecord* record = jsDynamicCast<JSModuleRecord*>(vm, moduleEntry.get(this->m_globalObject->globalExec(), moduleIdentifier))) {
            SourceProvider* sourceProvider = record->sourceCode().provider();
            JSValue function = record->getDirect(this->m_globalObject->vm(), m_globalObject->commonJSModuleFunctionIdentifier());
            if (!function.isEmpty() && !function.isUndefinedOrNull()) {
                if (JSFunction* moduleFunction = jsDynamicCast<JSFunction*>(vm, record->getDirect(this->m_globalObject->vm(), m_globalObject->commonJSModuleFunctionIdentifier()))) {
                    sourceProvider = moduleFunction->sourceCode()->provider();
                }
            }
            this->m_globalObject->debugger()->sourceParsed(this->m_globalObject->globalExec(), sourceProvider, -1, WTF::emptyString());
        }
    }

    this->m_globalObject->debugger()->activateBreakpoints();
}
void GlobalObjectDebuggerAgent::setScriptSource(Inspector::ErrorString& error, const String& scriptIdStr, const String& scriptSource) {
    intptr_t scriptId = static_cast<intptr_t>(atol(scriptIdStr.utf8().data()));

    VM& vm = this->m_globalObject->vm();
    ExecState* exec = this->m_globalObject->globalExec();

    JSValue registry = this->m_globalObject->moduleLoader()->get(exec, Identifier::fromString(&this->m_globalObject->vm(), "registry"));
    JSMapIterator* registryIterator = JSMapIterator::create(this->m_globalObject->vm(), this->m_globalObject->mapIteratorStructure(), jsCast<JSMap*>(registry), IterateKeyValue);
    JSValue moduleKey, moduleEntry;
    Identifier moduleIdentifier = Identifier::fromString(&vm, "module");

    // Search for the module having an ID equal to scriptId
    while (registryIterator->nextKeyValue(this->m_globalObject->globalExec(), moduleKey, moduleEntry)) {
        if (JSModuleRecord* moduleRecord = jsDynamicCast<JSModuleRecord*>(vm, moduleEntry.get(this->m_globalObject->globalExec(), moduleIdentifier))) {
            SourceCode& sourceCode = const_cast<SourceCode&>(moduleRecord->sourceCode());
            EditableSourceProvider* sourceProvider = static_cast<EditableSourceProvider*>(sourceCode.provider());
            if (sourceProvider->asID() == scriptId) {

                WTF::String moduleSource;
                ParserError parseError;
                std::unique_ptr<ScopeNode> program;

                JSValue value = moduleRecord->getDirect(this->m_globalObject->vm(), m_globalObject->commonJSModuleFunctionIdentifier());
                if (value.isEmpty()) {
                    // No need to wrap the new source in a CommonJS function
                    moduleSource = scriptSource;
                    program = parse<JSC::ProgramNode>(&m_globalObject->vm(), sourceCode, Identifier(), JSParserBuiltinMode::NotBuiltin, JSParserStrictMode::NotStrict, JSParserScriptMode::Module, SourceParseMode::ModuleEvaluateMode, SuperBinding::NotNeeded, parseError);
                } else {
                    if (JSFunction* moduleFunction = jsDynamicCast<JSFunction*>(vm, value)) {
                        // No need to wrap the new source in a CommonJS function
                        sourceProvider = static_cast<EditableSourceProvider*>(moduleFunction->sourceCode()->provider());
                        sourceCode = *moduleFunction->sourceCode();

                        WTF::StringBuilder moduleFunctionSource;
                        moduleFunctionSource.append("{function anonymous(require, module, exports, __dirname, __filename) {");
                        moduleFunctionSource.append(scriptSource);
                        moduleFunctionSource.append("\n}}");

                        moduleSource = moduleFunctionSource.toString();

                        SourceCode updatedSourceCode = makeSource(moduleSource, SourceOrigin()).subExpression(sourceCode.startOffset(), moduleSource.length() - 2, 1, sourceCode.startColumn().zeroBasedInt() - 1);
                        program = parse<FunctionNode>(&m_globalObject->vm(), updatedSourceCode, Identifier(), JSParserBuiltinMode::NotBuiltin, JSParserStrictMode::NotStrict, JSParserScriptMode::Classic, SourceParseMode::MethodMode, SuperBinding::NotNeeded, parseError);
                    }
                    error = String::format("Inconsistent script id %s (%s). Property %s is not a JSFunction",
                                           scriptIdStr.utf8().data(),
                                           sourceProvider->sourceOrigin().string().utf8().data(),
                                           m_globalObject->commonJSModuleFunctionIdentifier().utf8().data());
                    return;
                }

                if (!program) {
                    error = parseError.message();
                    return;
                }

                WTF::Vector<DiffChunk> diff = TextualDifferencesHelper::CompareStrings(moduleSource, sourceCode.provider()->source().toString());
                sourceProvider->setSource(moduleSource);
                sourceCode.setEndOffset(sourceProvider->source().length());

                m_globalObject->vm().clearSourceProviderCaches();
                const ClearChangedCellsFunctor functor(vm, moduleRecord->sourceCode().provider()->url(), diff);
                {
                    HeapIterationScope iterationScope(m_globalObject->vm().heap);
                    vm.heap.objectSpace().forEachLiveCell(iterationScope, functor);
                }
                return;
            }
        }
    }

    error = String::format("Could not find script with ID: '%s'", scriptIdStr.utf8().data());
}

InjectedScript GlobalObjectDebuggerAgent::injectedScriptForEval(ErrorString& error, const int* executionContextId) {
    ASSERT_UNUSED(executionContextId, (!executionContextId || *executionContextId == 1));

    ExecState* exec = static_cast<JSGlobalObjectScriptDebugServer&>(scriptDebugServer()).globalObject().globalExec();
    return injectedScriptManager().injectedScriptFor(exec);
}

void GlobalObjectDebuggerAgent::breakpointActionLog(JSC::ExecState& exec, const String& message) {
    m_consoleAgent->addMessageToConsole(std::make_unique<ConsoleMessage>(MessageSource::JS, MessageType::Log, MessageLevel::Log, message, createScriptCallStack(&exec, ScriptCallStack::maxCallStackSizeToCapture), 0));
}

} // namespace Inspector
