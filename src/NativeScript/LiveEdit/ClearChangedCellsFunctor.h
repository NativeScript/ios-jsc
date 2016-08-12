#pragma once
#include "TextualDifferencesHelper.h"
#include <JavaScriptCore/Nodes.h>

namespace NativeScript {
class ClearChangedCellsFunctor : public JSC::MarkedBlock::VoidFunctor {
public:
    ClearChangedCellsFunctor(WTF::String url, WTF::Vector<DiffChunk>);
    JSC::IterationStatus operator()(JSC::JSCell*);

private:
    WTF::String m_url;
    WTF::Vector<DiffChunk> m_diff;
    void visit(JSC::JSCell*);
};
}
