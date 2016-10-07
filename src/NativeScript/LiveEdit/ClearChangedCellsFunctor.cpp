#include "ClearChangedCellsFunctor.h"
#include <JavaScriptCore/CodeBlock.h>
#include <JavaScriptCore/Executable.h>
#include <JavaScriptCore/HeapInlines.h>
#include <JavaScriptCore/JSModuleEnvironment.h>
#include <JavaScriptCore/JSModuleRecord.h>

namespace NativeScript {

ClearChangedCellsFunctor::ClearChangedCellsFunctor(WTF::String url, WTF::Vector<DiffChunk> diff)
    : m_url(url)
    , m_diff(diff) {
}

JSC::IterationStatus ClearChangedCellsFunctor::operator()(JSC::HeapCell* cell, JSC::HeapCell::Kind kind) const {
    if (kind == JSC::HeapCell::JSCell) {
        visit(cell);
    }
    return JSC::IterationStatus::Continue;
}

void ClearChangedCellsFunctor::visit(JSC::HeapCell* heapCell) const {
    JSC::JSCell* cell = static_cast<JSC::JSCell*>(heapCell);
    if (!cell->inherits(JSC::JSFunction::info()))
        return;

    JSC::JSFunction* function = JSC::jsCast<JSC::JSFunction*>(cell);
    if (function->executable()->isHostFunction() || function->isBuiltinFunction())
        return;

    JSC::SourceCode* sourceCode = const_cast<JSC::SourceCode*>(function->sourceCode());
    if (sourceCode->provider()->url() == m_url) {
        bool changed{ false };
        for (DiffChunk diff : m_diff) {
            if (diff.pos1 + diff.len1 <= sourceCode->startOffset()) {
                changed = true;
                sourceCode->setStartOffset(sourceCode->startOffset() + diff.len1);
                sourceCode->setStartOffset(sourceCode->startOffset() - diff.len2);

                sourceCode->setEndOffset(sourceCode->endOffset() + diff.len1);
                sourceCode->setEndOffset(sourceCode->endOffset() - diff.len2);
            } else if (diff.pos1 >= sourceCode->startOffset() && diff.pos1 <= sourceCode->endOffset()) {
                changed = true;
                sourceCode->setEndOffset(sourceCode->endOffset() + diff.len1);
                sourceCode->setEndOffset(sourceCode->endOffset() - diff.len2);
            }
        }

        if (changed) {
            JSC::FunctionExecutable* executable = function->jsExecutable();
            if (JSC::FunctionCodeBlock* functionCodeBlock = executable->codeBlockForCall()) {
                functionCodeBlock->unlinkIncomingCalls();
            }
            executable->clearNumParametersForCall();
            executable->clearCode();
            executable->unlinkedExecutable()->clearCode();
        }
    }
}
}