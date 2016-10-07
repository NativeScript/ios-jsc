#pragma once
#include "TextualDifferencesHelper.h"
#include <JavaScriptCore/Nodes.h>

namespace NativeScript {
class ClearChangedCellsFunctor : public JSC::MarkedBlock::VoidFunctor {
public:
    ClearChangedCellsFunctor(WTF::String url, WTF::Vector<DiffChunk>);
    JSC::IterationStatus operator()(JSC::HeapCell* cell, JSC::HeapCell::Kind) const;

private:
    WTF::String m_url;
    WTF::Vector<DiffChunk> m_diff;
    void visit(JSC::HeapCell*) const;
};
}
