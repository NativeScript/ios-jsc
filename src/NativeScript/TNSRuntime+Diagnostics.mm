//
//  TNSRuntime+Diagnostics.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "NativeScript-Prefix.h"
#import "TNSRuntime+Diagnostics.h"
#import "TNSRuntime+Private.h"

#import <Foundation/NSString.h>

using namespace JSC;
using namespace NativeScript;

@implementation TNSRuntime (Diagnostics)

struct StackTraceFunctor {
public:
    StackTraceFunctor(WTF::StringBuilder& trace)
        : _trace(trace)
        , line(0) {
    }

    StackVisitor::Status operator()(StackVisitor& visitor) {
        if (line++) {
            _trace.append("\n");
        }
        this->_trace.append(visitor->toString().utf8().data());
        return StackVisitor::Continue;
    }

private:
    WTF::StringBuilder& _trace;
    int line;
};

+ (void)_printCurrentStack {
    NSLog(@"--> JavaScript Stack trace:\n%@", [self _getCurrentStack]);
}

+ (NSString*)_getCurrentStack {
    WTF::StringBuilder trace;
    StackTraceFunctor functor(trace);
    static_cast<TNSRuntime*>(WTF::wtfThreadData().m_apiData)->_vm->topCallFrame->iterate(functor);
    return (NSString*)trace.toString().createCFString().autorelease();
}

@end
