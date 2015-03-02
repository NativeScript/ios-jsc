//
//  FFIFunctionCall.h
//  NativeScript
//
//  Created by Yavor Georgiev on 07.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__FFIFunctionCall__
#define __NativeScript__FFIFunctionCall__

#include "FFICall.h"

namespace Metadata {
struct FunctionMeta;
}

namespace NativeScript {
class FFIFunctionCall : public FFICall {
public:
    typedef FFICall Base;

    static FFIFunctionCall* create(JSC::VM& vm, JSC::Structure* structure, const void* functionPointer, const WTF::String& name, JSC::JSCell* returnType, const WTF::Vector<JSC::JSCell*>& parameterTypes, bool retainsReturnedCocoaObjects) {
        FFIFunctionCall* function = new (NotNull, JSC::allocateCell<FFIFunctionCall>(vm.heap)) FFIFunctionCall(vm, structure);
        function->finishCreation(vm, functionPointer, name, returnType, parameterTypes, retainsReturnedCocoaObjects);
        vm.heap.addFinalizer(function, destroy);
        return function;
    }

    DECLARE_INFO;

    static const bool needsDestruction = false;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    const void* functionPointer() const {
        return this->_functionPointer;
    }

    bool retainsReturnedCocoaObjects() {
        return this->_retainsReturnedCocoaObjects;
    }

private:
    FFIFunctionCall(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, const void* functionPointer, const WTF::String& name, JSC::JSCell* returnType, const WTF::Vector<JSC::JSCell*>& parameterTypes, bool retainsReturnedCocoaObjects);

    static JSC::EncodedJSValue JSC_HOST_CALL executeCall(JSC::ExecState*);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<FFIFunctionCall*>(cell)->~FFIFunctionCall();
    }

    const void* _functionPointer;

    bool _retainsReturnedCocoaObjects;
};
}

#endif /* defined(__NativeScript__FFIFunctionCall__) */
