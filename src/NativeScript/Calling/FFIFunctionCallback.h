//
//  FFIFunctionCallback.h
//  NativeScript
//
//  Created by Yavor Georgiev on 15.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__FFIFunctionCallback__
#define __NativeScript__FFIFunctionCallback__

#include "NativeScript-Prefix.h"
#include "FFICallback.h"

namespace NativeScript {
class FunctionReferenceTypeInstance;

class FFIFunctionCallback : public FFICallback<FFIFunctionCallback> {
public:
    typedef FFICallback Base;

    static FFIFunctionCallback* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, JSC::JSCell* function, FunctionReferenceTypeInstance* functionReferenceType) {
        FFIFunctionCallback* cell = new (NotNull, JSC::allocateCell<FFIFunctionCallback>(vm.heap)) FFIFunctionCallback(vm, structure);
        cell->finishCreation(vm, globalObject, function, functionReferenceType);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    static void ffiClosureCallback(void* retValue, void** argValues, void* userData);

private:
    FFIFunctionCallback(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, JSC::JSCell* function, FunctionReferenceTypeInstance*);
};
}

#endif /* defined(__NativeScript__FFIFunctionCallback__) */
