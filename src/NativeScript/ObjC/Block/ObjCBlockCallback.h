//
//  ObjCBlockCallback.h
//  NativeScript
//
//  Created by Jason Zhekov on 10/15/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCBlockCallback__
#define __NativeScript__ObjCBlockCallback__

#include "FFICallback.h"

namespace NativeScript {
class ObjCBlockType;

class ObjCBlockCallback : public FFICallback<ObjCBlockCallback> {
public:
    typedef FFICallback Base;

    static ObjCBlockCallback* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, JSC::JSCell* function, ObjCBlockType* blockType) {
        ObjCBlockCallback* cell = new (NotNull, JSC::allocateCell<ObjCBlockCallback>(vm.heap)) ObjCBlockCallback(vm, structure);
        cell->finishCreation(vm, globalObject, function, blockType);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    static void ffiClosureCallback(void* retValue, void** argValues, void* userData);

private:
    ObjCBlockCallback(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, JSC::JSCell* function, ObjCBlockType*);
};
} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCBlockCallback__) */
