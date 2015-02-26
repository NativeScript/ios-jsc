//
//  JSErrors.h
//  NativeScript
//
//  Created by Jason Zhekov on 2/26/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#ifndef __NativeScript__JSErrors__
#define __NativeScript__JSErrors__

namespace NativeScript {
void reportFatalErrorBeforeShutdown(JSC::ExecState* execState, JSC::JSValue error);
}

#endif /* defined(__NativeScript__JSErrors__) */
