#pragma once
#include "TextualDifferencesHelper.h"
#include <JavaScriptCore/parser/Nodes.h>

namespace NativeScript {
class ClearChangedCellsFunctor : public JSC::MarkedBlock::VoidFunctor {
public:
    ClearChangedCellsFunctor(JSC::VM& vm, WTF::String url, WTF::Vector<DiffChunk>);
    JSC::IterationStatus operator()(JSC::HeapCell* cell, JSC::HeapCell::Kind) const;

private:
    JSC::VM& m_vm;
    WTF::String m_url;
    WTF::Vector<DiffChunk> m_diff;
    void visit(JSC::HeapCell*) const;
};
} // namespace NativeScript
