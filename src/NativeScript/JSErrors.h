//
//  JSErrors.h
//  NativeScript
//
//  Created by Jason Zhekov on 2/26/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#ifndef __NativeScript__JSErrors__
#define __NativeScript__JSErrors__

#include <JavaScriptCore/CatchScope.h>
#include <JavaScriptCore/Exception.h>
#include <JavaScriptCore/ScriptCallFrame.h>
#include <JavaScriptCore/ScriptCallStack.h>

#define NS_EXCEPTION_SCOPE_ZERO_RECURSION_KEY @"__nsExceptionScopeZeroRecursion"

namespace NativeScript {

void reportErrorIfAny(JSC::ExecState* execState, JSC::CatchScope& scope);
void reportFatalErrorBeforeShutdown(JSC::ExecState*, JSC::Exception*, bool callJsUncaughtErrorCallback = true, bool dontCrash = false);
void dumpExecJsCallStack(JSC::ExecState* execState);
std::string dumpJsCallStack(const Inspector::ScriptCallStack& frames);

} // namespace NativeScript

#endif /* defined(__NativeScript__JSErrors__) */
