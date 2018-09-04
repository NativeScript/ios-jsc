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
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

    id block() const {
        return this->_block.get();
    }

private:
    ObjCBlockCall(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~ObjCBlockCall();

    static void destroy(JSC::JSCell* cell) {
        static_cast<ObjCBlockCall*>(cell)->~ObjCBlockCall();
    }

    void finishCreation(JSC::VM&, id block, ObjCBlockType*);

    static void preInvocation(FFICall*, JSC::ExecState*, FFICall::Invocation&);

    WTF::RetainPtr<id> _block;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCBlockCall__) */
