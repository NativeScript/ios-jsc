//
//  ObjCMethodCallback.mm
//  NativeScript
//
//  Created by Yavor Ivanov on 6/26/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCMethodCallback.h"
#include "FFICallbackInlines.h"
#include "FFISimpleType.h"
#include "Metadata.h"
#include "ObjCConstructorNative.h"
#include "ObjCTypes.h"
#include "ReferenceTypeInstance.h"
#include "TypeFactory.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

ObjCMethodCallback* createProtectedMethodCallback(ExecState* execState, JSValue value, const MethodMeta* meta) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    const Metadata::TypeEncoding* typeEncodings = meta->encodings()->first();
    JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, typeEncodings);
    Vector<JSCell*> parameterTypes = globalObject->typeFactory()->parseTypes(globalObject, typeEncodings, meta->encodings()->count - 1);

    ObjCMethodCallback* methodCallback = ObjCMethodCallback::create(execState->vm(), globalObject, globalObject->objCMethodCallbackStructure(), value.asCell(), returnType, parameterTypes, TriState(meta->hasErrorOutParameter()));
    gcProtect(methodCallback);
    return methodCallback;
}

static bool checkErrorOutParameter(ExecState* execState, const WTF::Vector<JSCell*>& parameterTypes) {
    if (!(parameterTypes.size() > 0)) {
        return false;
    }

    JSC::VM& vm = execState->vm();
    if (ReferenceTypeInstance* referenceInstance = jsDynamicCast<ReferenceTypeInstance*>(vm, parameterTypes.last())) {
        if (ObjCConstructorNative* constructor = jsDynamicCast<ObjCConstructorNative*>(vm, referenceInstance->innerType())) {
            if (constructor->klass() == [NSError class]) {
                return true;
            }
        }
    }

    return false;
}

const ClassInfo ObjCMethodCallback::s_info = { "ObjCMethodCallback", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCMethodCallback) };

void ObjCMethodCallback::finishCreation(VM& vm, JSGlobalObject* globalObject, JSCell* function, JSCell* returnType, WTF::Vector<JSCell*> parameterTypes, TriState hasErrorOutParameter) {
    Base::finishCreation(vm, globalObject, function, returnType, parameterTypes, 2);

    if (hasErrorOutParameter != TriState::MixedTriState) {
        this->_hasErrorOutParameter = hasErrorOutParameter;
    } else {
        this->_hasErrorOutParameter = checkErrorOutParameter(globalObject->globalExec(), parameterTypes);
    }
}

void ObjCMethodCallback::ffiClosureCallback(void* retValue, void** argValues, void* userData) {
    ObjCMethodCallback* methodCallback = reinterpret_cast<ObjCMethodCallback*>(userData);
    ExecState* execState = methodCallback->_globalExecState;

    id target = *static_cast<id*>(argValues[0]);
#ifdef DEBUG_OBJC_INVOCATION
    SEL selector = *static_cast<SEL*>(argValues[1]);
    bool isInstance = !class_isMetaClass(object_getClass(target));
    NSLog(@"< %@[%@ %@]", isInstance ? @"-" : @"+", NSStringFromClass(object_getClass(target)), NSStringFromSelector(selector));
#endif

    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_CATCH_SCOPE(vm);

    MarkedArgumentBuffer arguments;
    methodCallback->marshallArguments(argValues, arguments, methodCallback);
    if (scope.exception()) {
        return;
    }

    JSValue thisValue = toValue(execState, target);
    methodCallback->callFunction(thisValue, arguments, retValue);

    if (methodCallback->_hasErrorOutParameter) {
        size_t methodCallbackLength = jsDynamicCast<JSObject*>(vm, methodCallback->function())->get(execState, vm.propertyNames->length).toUInt32(execState);
        if (methodCallbackLength == methodCallback->parametersCount() - 1) {
            Exception* exception = scope.exception();
            if (exception) {
                scope.clearException();
                memset(retValue, 0, methodCallback->_returnType.ffiType->size);
                NSError* nserror = [NSError errorWithDomain:@"TNSErrorDomain" code:164 userInfo:@{ @"TNSJavaScriptError" : NativeScript::toObject(execState, exception->value()) }];

                NSError**** outErrorPtr = reinterpret_cast<NSError****>(argValues + (methodCallback->parametersCount() + methodCallback->_initialArgumentIndex - 1));
                if (**outErrorPtr) {
                    ***outErrorPtr = nserror;
                }
            } else if (methodCallback->_returnTypeCell.get() == static_cast<JSCell*>(jsCast<GlobalObject*>(execState->lexicalGlobalObject())->typeFactory()->boolType())) {
                memset(retValue, 1, methodCallback->_returnType.ffiType->size);
            }
        }
    }
}
}
