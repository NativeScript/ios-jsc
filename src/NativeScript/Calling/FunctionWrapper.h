//
//  FunctionWrapper.h
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__FFICall__
#define __NativeScript__FFICall__

#include "FFICall.h"
#include "FFIType.h"
#include "FunctionWrapper.h"
#include "ReleasePool.h"
#include <JavaScriptCore/Exception.h>
#include <vector>

namespace NativeScript {

class FunctionWrapper : public JSC::InternalFunction {
public:
    typedef JSC::InternalFunction Base;

    DECLARE_INFO;

    std::vector<std::unique_ptr<FFICall>>& functionsContainer() {
        return this->_functionsContainer;
    }

    FFICall* onlyFuncInContainer() const {
        ASSERT(this->_functionsContainer.size() == 1);
        return this->_functionsContainer[0].get();
    }

    JSC::JSObject* async(JSC::ExecState*, JSC::JSValue thisValue, const JSC::ArgList&);

protected:
    FunctionWrapper(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure, &call, nullptr) {
    }

    ~FunctionWrapper();

    void initializeFunctionWrapper(JSC::VM& vm, size_t maxParametersCount);

    static void visitChildren(JSC::JSCell*, JSC::SlotVisitor&);

    static JSC::EncodedJSValue JSC_HOST_CALL call(JSC::ExecState* execState);

    std::vector<std::unique_ptr<FFICall>> _functionsContainer;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__FunctionWrapper__) */
