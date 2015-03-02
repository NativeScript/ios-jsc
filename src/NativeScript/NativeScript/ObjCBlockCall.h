//
//  ObjCBlockCall.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/6/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCBlockCall__
#define __NativeScript__ObjCBlockCall__

#include "FFICall.h"

namespace Metadata {
struct MethodMeta;
}

namespace NativeScript {
class ObjCBlockType;

class ObjCBlockCall : public FFICall {
public:
    typedef FFICall Base;

    static ObjCBlockCall* create(JSC::VM& vm, JSC::Structure* structure, id block, ObjCBlockType* blockType) {
        ObjCBlockCall* cell = new (NotNull, JSC::allocateCell<ObjCBlockCall>(vm.heap)) ObjCBlockCall(vm, structure);
        cell->finishCreation(vm, block, blockType);
        vm.heap.addFinalizer(cell, destroy);
        return cell;
    }

    DECLARE_INFO;

    static const bool needsDestruction = false;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    const id block() const {
        return this->_block.get();
    }

private:
    ObjCBlockCall(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~ObjCBlockCall();

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<ObjCBlockCall*>(cell)->~ObjCBlockCall();
    }

    void finishCreation(JSC::VM&, id block, ObjCBlockType*);

    static JSC::EncodedJSValue JSC_HOST_CALL executeCall(JSC::ExecState*);

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);

    WTF::RetainPtr<id> _block;
};
}

#endif /* defined(__NativeScript__ObjCBlockCall__) */
