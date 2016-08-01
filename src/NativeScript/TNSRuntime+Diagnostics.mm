//
//  TNSRuntime+Diagnostics.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#import "TNSRuntime+Diagnostics.h"
#import "TNSRuntime+Private.h"
#include <JavaScriptCore/APICast.h>
#include <JavaScriptCore/ScriptCallStack.h>
#include <JavaScriptCore/ScriptCallStackFactory.h>
#include <iomanip>
#include <iostream>
#include <sstream>

using namespace JSC;
using namespace NativeScript;

@implementation TNSRuntime (Diagnostics)

+ (void)_printCurrentStack {
    NSLog(@"%s is deprecated - use [runtime getCurrentStack] instead.", __FUNCTION__);
}

- (NSString*)getCurrentStack {
    std::stringstream output;
    RefPtr<Inspector::ScriptCallStack> callStack = Inspector::createScriptCallStack(self->_vm->topCallFrame, Inspector::ScriptCallStack::maxCallStackSizeToCapture);
    for (size_t i = 0; i < callStack->size(); ++i) {
        Inspector::ScriptCallFrame frame = callStack->at(i);
        output << "\t" << std::setw(4) << std::setfill(' ') << std::left << i << frame.functionName().utf8().data() << "@" << frame.sourceURL().utf8().data();
        if (frame.lineNumber() && frame.columnNumber()) {
            output << ":" << frame.lineNumber() << ":" << frame.columnNumber();
        }
        if (i != callStack->size() - 1) {
            output << "\n";
        }
    }
    return [NSString stringWithUTF8String:output.str().c_str()];
}

@end
