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
#include "Metadata.h"
#include "ObjCMethodCall.h"

namespace NativeScript {

class ObjCMethodCallback;

ObjCMethodCallback* createProtectedMethodCallback(JSC::ExecState*, JSC::JSCell*, const Metadata::MethodMeta*);

void overrideObjcMethodWrapperCalls(JSC::ExecState* execState, Class klass, JSC::JSCell* method, ObjCMethodWrapper& wrapper);

class ObjCMethodCallback : public FFICallback<ObjCMethodCallback> {
public:
    typedef FFICallback Base;

    static JSC::Strong<ObjCMethodCallback> create(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::Structure* structure, JSC::JSCell* function, JSC::JSCell* returnType, WTF::Vector<Strong<JSC::JSCell>> parameterTypes, WTF::TriState hasErrorOutParameter = WTF::MixedTriState) {
        JSC::Strong<ObjCMethodCallback> cell(vm, new (NotNull, JSC::allocateCell<ObjCMethodCallback>(vm.heap)) ObjCMethodCallback(vm, structure));
        cell->finishCreation(vm, globalObject, function, returnType, parameterTypes, hasErrorOutParameter);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

    static void ffiClosureCallback(void* retValue, void** argValues, void* userData);

private:
    ObjCMethodCallback(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, JSC::JSGlobalObject*, JSC::JSCell* function, JSC::JSCell* returnType, WTF::Vector<JSC::Strong<JSC::JSCell>> parameterTypes, WTF::TriState hasErrorOutParameter);

    bool _hasErrorOutParameter;
};

void overrideObjcMethodCalls(ExecState* execState, JSObject* object, PropertyName propertyName, JSCell* method, const Metadata::BaseClassMeta* meta, Metadata::MemberType memberType, Class klass,
                             const Metadata::ProtocolMetas& protocols);

} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCMethodCallback__) */
