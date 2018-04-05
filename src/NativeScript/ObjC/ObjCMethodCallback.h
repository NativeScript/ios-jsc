//
//  ObjCMethodCallback.h
//  NativeScript
//
//  Created by Yavor Ivanov on 6/26/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCMethodCallback__
#define __NativeScript__ObjCMethodCallback__

#include "FFICallback.h"

namespace Metadata {
struct MethodMeta;
}

namespace NativeScript {
class ObjCMethodCallback;

ObjCMethodCallback* createProtectedMethodCallback(JSC::ExecState*, JSC::JSValue, const Metadata::MethodMeta*);

class ObjCMethodCallback : public FFICallback<ObjCMethodCallback> {
public:
    typedef FFICallback Base;

    static ObjCMethodCallback* create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, JSC::JSCell* function, JSC::JSCell* returnType, WTF::Vector<JSC::JSCell*> parameterTypes, WTF::TriState hasErrorOutParameter = WTF::MixedTriState) {
        ObjCMethodCallback* cell = new (NotNull, JSC::allocateCell<ObjCMethodCallback>(vm.heap)) ObjCMethodCallback(vm, structure);
        cell->finishCreation(vm, globalObject, function, returnType, parameterTypes, hasErrorOutParameter);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    static void ffiClosureCallback(void* retValue, void** argValues, void* userData);

private:
    ObjCMethodCallback(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, JSC::JSCell* function, JSC::JSCell* returnType, WTF::Vector<JSC::JSCell*> parameterTypes, WTF::TriState hasErrorOutParameter);

    bool _hasErrorOutParameter;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCMethodCallback__) */
