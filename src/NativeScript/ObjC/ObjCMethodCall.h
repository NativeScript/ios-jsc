//
//  ObjCMethodCall.h
//  NativeScript
//
//  Created by Yavor Georgiev on 12.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCMethodCall__
#define __NativeScript__ObjCMethodCall__

#include "FFICall.h"

namespace Metadata {
struct MethodMeta;
}

namespace NativeScript {
class ObjCMethodCall : public FFICall {
public:
    typedef FFICall Base;

    static ObjCMethodCall* create(JSC::VM& vm, GlobalObject* globalObject, JSC::Structure* structure, const Metadata::MethodMeta* metadata, SEL aSelector = nil) {
        ObjCMethodCall* cell = new (NotNull, JSC::allocateCell<ObjCMethodCall>(vm.heap)) ObjCMethodCall(vm, structure);
        cell->finishCreation(vm, globalObject, metadata, aSelector);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    SEL selector() {
        return this->_selector;
    }

    void setSelector(SEL aSelector) {
        this->_selector = aSelector;
    }

    bool retainsReturnedCocoaObjects() {
        return this->_retainsReturnedCocoaObjects;
    }

private:
    ObjCMethodCall(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM&, GlobalObject*, const Metadata::MethodMeta*, SEL);

    FFI_DERIVED_MEMBERS;

    static JSC::CallType getCallData(JSC::JSCell*, JSC::CallData&);

    static void destroy(JSC::JSCell* cell) {
        JSC::jsCast<ObjCMethodCall*>(cell)->~ObjCMethodCall();
    }

    void* _msgSend;

    void* _msgSendSuper;

    bool _retainsReturnedCocoaObjects;

    SEL _selector;
};
}

#endif /* defined(__NativeScript__ObjCMethodCall__) */
