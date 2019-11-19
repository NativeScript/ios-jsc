//
//  IndexedRefPrototype.cpp
//  NativeScript
//
//  Created by Deyan Ginev on 17.01.18.
//

#include "IndexedRefPrototype.h"
#include "IndexedRefInstance.h"
#include "WTF/HexNumber.h"

namespace NativeScript {
using namespace JSC;
using namespace WTF;

const ClassInfo IndexedRefPrototype::s_info = { "IndexedRef", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(IndexedRefPrototype) };

static EncodedJSValue JSC_HOST_CALL indexedRefProtoFuncToString(ExecState* execState) {
    IndexedRefInstance* reference = jsCast<IndexedRefInstance*>(execState->thisValue());
    WTF::String toString = makeString("<", IndexedRefInstance::info()->className, ": 0x", hex(reinterpret_cast<intptr_t>(reference->data()), HexConversionMode::Lowercase), ">");
    return JSValue::encode(jsString(execState, toString));
}

void IndexedRefPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->putDirectNativeFunction(vm, globalObject, vm.propertyNames->toString, 0, indexedRefProtoFuncToString, NoIntrinsic, static_cast<unsigned>(PropertyAttribute::DontEnum));
}
} // namespace NativeScript
