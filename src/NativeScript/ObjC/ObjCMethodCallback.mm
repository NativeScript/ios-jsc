//
//  ObjCMethodCallback.mm
//  NativeScript
//
//  Created by Yavor Ivanov on 6/26/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCMethodCallback.h"
#include "FFICallbackInlines.h"
#include "Metadata.h"
#include "TypeFactory.h"
#include "ObjCTypes.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

ObjCMethodCallback* createProtectedMethodCallback(ExecState* execState, JSValue value, const MethodMeta* meta) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    const Metadata::TypeEncoding* typeEncodings = meta->encodings()->first();
    JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, typeEncodings);
    Vector<JSCell*> parameterTypes = globalObject->typeFactory()->parseTypes(globalObject, typeEncodings, meta->encodings()->count - 1);

    ObjCMethodCallback* methodCallback = ObjCMethodCallback::create(execState->vm(), globalObject, globalObject->objCMethodCallbackStructure(), value.asCell(), returnType, parameterTypes);
    gcProtect(methodCallback);
    return methodCallback;
}

const ClassInfo ObjCMethodCallback::s_info = { "ObjCMethodCallback", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCMethodCallback) };

void ObjCMethodCallback::finishCreation(VM& vm, JSGlobalObject* globalObject, JSCell* function, JSCell* returnType, WTF::Vector<JSCell*> parameterTypes) {
    Base::finishCreation(vm, globalObject, function, returnType, parameterTypes, 2);
}

void ObjCMethodCallback::ffiClosureCallback(void* retValue, void** argValues, void* userData) {
    ObjCMethodCallback* methodCallback = reinterpret_cast<ObjCMethodCallback*>(userData);

    id target = *static_cast<id*>(argValues[0]);
#ifdef DEBUG_OBJC_INVOCATION
    SEL selector = *static_cast<SEL*>(argValues[1]);
    bool isInstance = !class_isMetaClass(object_getClass(target));
    NSLog(@"< %@[%@ %@]", isInstance ? @"-" : @"+", NSStringFromClass(object_getClass(target)), NSStringFromSelector(selector));
#endif

    MarkedArgumentBuffer arguments;
    methodCallback->marshallArguments(argValues, arguments, methodCallback);
    if (methodCallback->_globalExecState->hadException()) {
        return;
    }

    JSValue thisValue = toValue(methodCallback->_globalExecState, target);
    methodCallback->callFunction(thisValue, arguments, retValue);
}
}
