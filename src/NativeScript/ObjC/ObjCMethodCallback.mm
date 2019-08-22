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
#include "Interop.h"
#include "Metadata.h"
#include "ObjCConstructorNative.h"
#include "ObjCTypes.h"
#include "ObjCWrapperObject.h"
#include "ReferenceTypeInstance.h"
#include "TypeFactory.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

ObjCMethodCallback* createProtectedMethodCallback(ExecState* execState, JSCell* method, const MethodMeta* meta) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    const Metadata::TypeEncoding* typeEncodings = meta->encodings()->first();
    auto returnType = globalObject->typeFactory()->parseType(globalObject, typeEncodings, /*isStructMember*/ false);
    auto parameterTypes = globalObject->typeFactory()->parseTypes(globalObject, typeEncodings, meta->encodings()->count - 1, /*isStructMember*/ false);

    auto methodCallback = ObjCMethodCallback::create(execState->vm(),
                                                     globalObject,
                                                     globalObject->objCMethodCallbackStructure(),
                                                     method,
                                                     returnType.get(),
                                                     parameterTypes,
                                                     TriState(meta->hasErrorOutParameter()));
    gcProtect(methodCallback.get());
    return methodCallback.get();
}
void overrideObjcMethodCall(ExecState* execState, Class klass, JSCell* method, ObjCMethodCall* call) {
    ObjCMethodCallback* callback = createProtectedMethodCallback(execState, method, call->meta);

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    std::string compilerEncoding = getCompilerEncoding(globalObject, call->meta);
    IMP nativeImp = class_replaceMethod(klass, call->meta->selector(), reinterpret_cast<IMP>(callback->functionPointer()), compilerEncoding.c_str());
    if (nativeImp) {
        SEL nativeSelector = sel_registerName(WTF::String::format("__%s", call->meta->selectorAsString()).utf8().data());
        class_addMethod(klass, nativeSelector, nativeImp, compilerEncoding.c_str());
        call->setSelector(nativeSelector);
    }
}

void overrideObjcMethodCalls(ExecState* execState, JSObject* object, PropertyName propertyName, JSCell* method, const Metadata::BaseClassMeta* meta, Metadata::MemberType memberType, Class klass,
                             std::vector<const Metadata::ProtocolMeta*>* protocols) {
    JSValue methodValue = jsUndefined();
    PropertySlot slot(object, PropertySlot::InternalMethodType::Get);
    if (object->getPropertySlot(execState, propertyName, slot)) {
        if (slot.isAccessor()) {
            JSC::VM& vm = execState->vm();
            auto throwScope = DECLARE_THROW_SCOPE(vm);
            WTF::String message = WTF::String::format("Cannot override native property \"%s\" with a function, define it as a JS property instead.",
                                                      propertyName.publicName()->utf8().data());
            throwException(execState, throwScope, JSC::createError(execState, message));
            return;
        }

        methodValue = slot.getValue(execState, propertyName);
    }

    ObjCMethodWrapper* wrapper = jsDynamicCast<ObjCMethodWrapper*>(execState->vm(), methodValue);
    Strong<ObjCMethodWrapper> strongWrapper;
    if (!wrapper) {
        MembersCollection methodMetas;

        auto currentClass = meta;
        do {
            methodMetas = currentClass->members(propertyName.publicName(), memberType, /*includeProtocols*/ true, ProtocolMetas());
            if (currentClass->type() == Metadata::MetaType::Interface) {
                currentClass = static_cast<const Metadata::InterfaceMeta*>(currentClass)->baseMeta();
            } else {
                currentClass = nullptr;
            }

        } while (methodMetas.size() == 0 && currentClass);

        if (methodMetas.size() == 0 && protocols && !protocols->empty()) {
            for (auto aProtocol : *protocols) {
                if ((methodMetas = aProtocol->members(propertyName.publicName(), memberType, /*includeProtocols*/ true, ProtocolMetas())).size() > 0) {
                    break;
                }
            }
        }

        if (methodMetas.size() > 0) {
            strongWrapper = ObjCMethodWrapper::create(execState, methodMetas);
            wrapper = strongWrapper.get();
        }
    }

    if (wrapper) {
        overrideObjcMethodWrapperCalls(execState, klass, method, *wrapper);
    }
}

void overrideObjcMethodWrapperCalls(ExecState* execState, Class klass, JSCell* method, ObjCMethodWrapper& wrapper) {
    WTF::StringBuilder metaNames;
    bool warnForMultipleOverrides = wrapper.functionsContainer().size() > 1;
    int i = 0;
    std::string jsName;
    for (const auto& f : wrapper.functionsContainer()) {
        auto call = static_cast<ObjCMethodCall*>(f.get());

        overrideObjcMethodCall(execState, klass, method, call);

        if (warnForMultipleOverrides) {
            if (i++ == 0) {
                jsName.assign(call->meta->jsName());
            } else {
                metaNames.append(", ");
            }
            metaNames.append("\"");
            metaNames.append((call->meta)->selectorAsString());
            metaNames.append("\"");
        }
    }

    if (warnForMultipleOverrides) {
        WTF::String message = WTF::String::format("More than one native methods overriden! Assigning to \"%s\" will override native methods with the following selectors: %s.",
                                                  jsName.c_str(),
                                                  metaNames.toString().utf8().data());
        warn(execState, message);
    }
}

static bool checkErrorOutParameter(ExecState* execState, const WTF::Vector<Strong<JSCell>>& parameterTypes) {
    if (!(parameterTypes.size() > 0)) {
        return false;
    }

    JSC::VM& vm = execState->vm();
    if (ReferenceTypeInstance* referenceInstance = jsDynamicCast<ReferenceTypeInstance*>(vm, parameterTypes.last().get())) {
        if (ObjCConstructorNative* constructor = jsDynamicCast<ObjCConstructorNative*>(vm, referenceInstance->innerType())) {
            if (constructor->klasses().known == [NSError class]) {
                return true;
            }
        }
    }

    return false;
}

const ClassInfo ObjCMethodCallback::s_info = { "ObjCMethodCallback", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCMethodCallback) };

void ObjCMethodCallback::finishCreation(VM& vm, JSGlobalObject* globalObject, JSCell* function, JSCell* returnType, WTF::Vector<Strong<JSCell>> parameterTypes, TriState hasErrorOutParameter) {
    Base::finishCreation(vm, globalObject, function, returnType, parameterTypes, 2);

    if (hasErrorOutParameter != TriState::MixedTriState) {
        this->_hasErrorOutParameter = hasErrorOutParameter;
    } else {
        this->_hasErrorOutParameter = checkErrorOutParameter(globalObject->globalExec(), parameterTypes);
    }
}

void ObjCMethodCallback::ffiClosureCallback(void* retValue, void** argValues, void* userData) {
    ObjCMethodCallback* methodCallback = reinterpret_cast<ObjCMethodCallback*>(userData);
    ExecState* execState = methodCallback->execState();

    id target = *static_cast<id*>(argValues[0]);
    SEL selector = *static_cast<SEL*>(argValues[1]);
#ifdef DEBUG_OBJC_INVOCATION
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

    // BUG: moved before the call because if the call throws a JS exception, length is reported as 0
    size_t methodCallbackLength = jsDynamicCast<JSObject*>(vm, methodCallback->function())->get(execState, vm.propertyNames->length).toUInt32(execState);

    JSValue thisValue = toValue(execState, target);
    methodCallback->callFunction(thisValue, arguments, retValue);

    if (sel_isEqual(selector, @selector(dealloc))) {
        // When `dealloc` is implemented in JS we were caching a wrapper to the
        // already deallocated instance. This doesn't do any harm until the same
        // memory address is reused for another Objective-C instance. When this happens
        // the new object will be returned to the JS world via the cached wrapper,
        // which however won't increment its retention count, leading to its premature
        // deallocation and a crash whenever it's attempted to be used afterwards.
        if (auto wrapperObject = jsCast<ObjCWrapperObject*>(thisValue)) {
            wrapperObject->removeFromCache();
        }
    }

    if (methodCallback->_hasErrorOutParameter) {
        //        size_t methodCallbackLength = jsDynamicCast<JSObject*>(vm, methodCallback->function())->get(execState, vm.propertyNames->length).toUInt32(execState);
        if (methodCallbackLength == methodCallback->parametersCount() - 1) {
            Exception* exception = scope.exception();
            if (exception) {
                scope.clearException();
                memset(retValue, 0, methodCallback->_returnType.ffiType->size);

                NSError**** outErrorPtr = reinterpret_cast<NSError****>(argValues + (methodCallback->parametersCount() + methodCallback->_initialArgumentIndex - 1));
                if (**outErrorPtr) {
                    NSError* nserror = [NSError errorWithDomain:@"TNSErrorDomain" code:164 userInfo:@{ @"TNSJavaScriptError": NativeScript::toObject(execState, exception->value()) }];

                    ***outErrorPtr = nserror;
                }
            } else if (methodCallback->_returnTypeCell.get() == static_cast<JSCell*>(jsCast<GlobalObject*>(execState->lexicalGlobalObject())->typeFactory()->boolType())) {
                memset(retValue, 1, methodCallback->_returnType.ffiType->size);
            }
        }
    }
}
}
