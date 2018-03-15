//
//  IndexedRefPrototype.cpp
//  NativeScript
//
//  Created by Deyan Ginev on 17.01.18.
//

#include "IndexedRefPrototype.h"
#include "IndexedRefInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo IndexedRefPrototype::s_info = { "IndexedRef", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(IndexedRefPrototype) };

static EncodedJSValue JSC_HOST_CALL indexedRefProtoFuncToString(ExecState* execState) {
    IndexedRefInstance* reference = jsCast<IndexedRefInstance*>(execState->thisValue());
    WTF::String toString = WTF::String::format("<%s: %p>", IndexedRefInstance::info()->className, reference->data());
    return JSValue::encode(jsString(execState, toString));
}

void IndexedRefPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->toString, 0, indexedRefProtoFuncToString, NoIntrinsic, DontEnum);
}
} // namespace NativeScript
