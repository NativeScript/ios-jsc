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

namespace NativeScript {

void reportErrorIfAny(JSC::ExecState* execState, JSC::CatchScope& scope);
void reportFatalErrorBeforeShutdown(JSC::ExecState*, JSC::Exception*, bool callJsUncaughtErrorCallback = true, bool dontCrash = false);

} // namespace NativeScript

#endif /* defined(__NativeScript__JSErrors__) */
