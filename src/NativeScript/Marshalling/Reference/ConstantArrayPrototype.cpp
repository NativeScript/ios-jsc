//
//  ConstantArrayPrototype.cpp
//  NativeScript
//
//  Created by Deyan Ginev on 17.01.18.
//

#include "ConstantArrayPrototype.h"
#include "ConstantArrayInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ConstantArrayPrototype::s_info = { "ConstantArray", &Base::s_info, 0, CREATE_METHOD_TABLE(ConstantArrayPrototype) };

//    static EncodedJSValue JSC_HOST_CALL constantArrayProtoFuncGetValue(ExecState* execState) {
//        ConstantArrayInstance* reference = jsCast<ConstantArrayInstance*>(execState->thisValue());
//        if (!reference->data()) {
//            return JSValue::encode(jsUndefined());
//        }
//
//        JSValue result = reference->ffiTypeMethodTable().read(execState, reference->data(), reference->innerType());
//        return JSValue::encode(result);
//    }
//
//    static EncodedJSValue JSC_HOST_CALL constantArrayProtoFuncSetValue(ExecState* execState) {
//        ConstantArrayInstance* reference = jsCast<ConstantArrayInstance*>(execState->thisValue());
//        reference->ffiTypeMethodTable().write(execState, execState->argument(0), reference->data(), reference->innerType());
//        return JSValue::encode(jsUndefined());
//    }

static EncodedJSValue JSC_HOST_CALL constantArrayProtoFuncToString(ExecState* execState) {
    ConstantArrayInstance* reference = jsCast<ConstantArrayInstance*>(execState->thisValue());
    WTF::String toString = WTF::String::format("<%s: %p>", ConstantArrayInstance::info()->className, reference->data());
    return JSValue::encode(jsString(execState, toString));
}

void ConstantArrayPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->toString, 0, constantArrayProtoFuncToString, NoIntrinsic, DontEnum);

    //        PropertyDescriptor descriptor;
    //        descriptor.setEnumerable(true);
    //
    //        descriptor.setGetter(JSFunction::create(vm, globalObject, 0, WTF::emptyString(), &constantArrayProtoFuncGetValue));
    //        descriptor.setSetter(JSFunction::create(vm, globalObject, 1, WTF::emptyString(), &constantArrayProtoFuncSetValue));
    //
    //        Base::defineOwnProperty(this, globalObject->globalExec(), vm.propertyNames->value, descriptor, false);
}
} // namespace NativeScript
