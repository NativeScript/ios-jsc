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
#include "FunctionWrapper.h"
#include "JavaScriptCore/IsoSubspace.h"

namespace Metadata {
struct MethodMeta;
}

namespace NativeScript {
class ObjCBlockType;

class ObjCBlockWrapper : public FunctionWrapper {
public:
    typedef FunctionWrapper Base;

    static JSC::Strong<ObjCBlockWrapper> create(JSC::VM& vm, JSC::Structure* structure, id block, ObjCBlockType* blockType) {
        JSC::Strong<ObjCBlockWrapper> cell(vm, new (NotNull, JSC::allocateCell<ObjCBlockWrapper>(vm.heap)) ObjCBlockWrapper(vm, structure));
        cell->finishCreation(vm, block, blockType);
        return cell;
    }

    DECLARE_INFO;

    template <typename CellType>
    static JSC::IsoSubspace* subspaceFor(JSC::VM& vm) {
        return &vm.tnsObjCBlockWrapperSpace;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

private:
    ObjCBlockWrapper(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    ~ObjCBlockWrapper();

    static void destroy(JSC::JSCell* cell) {
        static_cast<ObjCBlockWrapper*>(cell)->~ObjCBlockWrapper();
    }

    void finishCreation(JSC::VM&, id block, ObjCBlockType*);

    static void preInvocation(FFICall*, JSC::ExecState*, FFICall::Invocation&);
};

class ObjCBlockCall : public FFICall {

public:
    ObjCBlockCall(FunctionWrapper* owner)
        : FFICall(owner) {
    }

    id block() const {
        return this->_block.get();
    }

private:
    friend class ObjCBlockWrapper;
    WTF::RetainPtr<id> _block;
};

} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCBlockCall__) */
