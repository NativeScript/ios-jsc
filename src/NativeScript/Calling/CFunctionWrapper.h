//
//  CFunctionWrapper.h
//  NativeScript
//
//  Created by Yavor Georgiev on 07.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__CFunctionWrapper__
#define __NativeScript__CFunctionWrapper__

#include "FFICall.h"
#include "FunctionWrapper.h"

namespace NativeScript {

class CFunctionCall : public FFICall {

public:
    CFunctionCall(FunctionWrapper* owner, void* functionPointer, bool retainsReturnedCocoaObjects)
        : FFICall(owner)
        , _functionPointer(functionPointer)
        , _retainsReturnedCocoaObjects(retainsReturnedCocoaObjects) {
    }

    DECLARE_INFO;

    template <typename CellType>
    static JSC::IsoSubspace* subspaceFor(JSC::VM& vm) {
        return &vm.tnsCFunctionWrapperSpace;
    }

    void* functionPointer() const {
        return this->_functionPointer;
    }
    bool retainsReturnedCocoaObjects() const {
        return this->_retainsReturnedCocoaObjects;
    }

private:
    void* _functionPointer;

    bool _retainsReturnedCocoaObjects;
};

class CFunctionWrapper : public FunctionWrapper {
public:
    typedef FunctionWrapper Base;

    static CFunctionWrapper* create(JSC::VM& vm, JSC::Structure* structure, void* functionPointer, const WTF::String& name, JSC::JSCell* returnType, const WTF::Vector<JSC::JSCell*>& parameterTypes, bool retainsReturnedCocoaObjects) {
        CFunctionWrapper* function = new (NotNull, JSC::allocateCell<CFunctionWrapper>(vm.heap)) CFunctionWrapper(vm, structure);
        function->finishCreation(vm, functionPointer, name, returnType, parameterTypes, retainsReturnedCocoaObjects);
        return function;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

    void* functionPointer() {
        return static_cast<CFunctionCall*>(this->onlyFuncInContainer())->functionPointer();
    }

private:
    CFunctionWrapper(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, void* functionPointer, const WTF::String& name, JSC::JSCell* returnType, const WTF::Vector<JSC::JSCell*>& parameterTypes, bool retainsReturnedCocoaObjects);

    static void destroy(JSC::JSCell* cell) {
        static_cast<CFunctionWrapper*>(cell)->~CFunctionWrapper();
    }

    static void preInvocation(FFICall*, JSC::ExecState*, FFICall::Invocation&);
    static void postInvocation(FFICall*, JSC::ExecState*, FFICall::Invocation&);
};
} // namespace NativeScript

#endif /* defined(__NativeScript__CFunctionWrapper__) */
