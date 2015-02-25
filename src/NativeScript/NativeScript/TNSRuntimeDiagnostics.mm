//
//  TNSRuntime.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#import "TNSRuntimeDiagnostics.h"
#import "TNSRuntimeImpl.h"

using namespace JSC;
using namespace NativeScript;

@implementation TNSRuntime (Diagnostics)

struct StackTraceFunctor {
public:
    StackTraceFunctor(WTF::StringBuilder& trace)
        : _trace(trace) {
    }

    StackVisitor::Status operator()(StackVisitor& visitor) {
        this->_trace.append(WTF::String::format("    %zu   %s\n", visitor->index(), visitor->toString().utf8().data()));
        return StackVisitor::Continue;
    }

private:
    WTF::StringBuilder& _trace;
};

+ (void)_printCurrentStack {
    WTF::StringBuilder trace;
    trace.appendLiteral("--> JS Stack trace:\n");

    StackTraceFunctor functor(trace);
    static_cast<TNSRuntimeImpl*>(static_cast<TNSRuntime*>(WTF::wtfThreadData().m_apiData)->_impl)->vm->topCallFrame->iterate(functor);
    fprintf(stderr, "%s", trace.toString().utf8().data());
}

@end
