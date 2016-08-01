#include "UnmanagedPrototype.h"
#include "ObjCConstructorBase.h"
#include "ObjCTypes.h"
#include "UnmanagedInstance.h"

namespace NativeScript {
static char consumedUnmanagedCheck = 'k';

using namespace JSC;

const ClassInfo UnmanagedPrototype::s_info = { "Unmanaged", &Base::s_info, 0, CREATE_METHOD_TABLE(UnmanagedPrototype) };

static EncodedJSValue takeValue(ExecState* execState, bool retained) {
    UnmanagedInstance* instance = jsDynamicCast<UnmanagedInstance*>(execState->thisValue());
    if (instance->data() == &consumedUnmanagedCheck) {
        return throwVMTypeError(execState, WTF::ASCIILiteral("Unmanaged value has already been consumed."));
    }

    id result = static_cast<id>(instance->data());
    instance->setData(&consumedUnmanagedCheck);

    ObjCConstructorBase* returnType = jsCast<ObjCConstructorBase*>(instance->returnType());
    JSValue retainedValue = NativeScript::toValue(execState, result, returnType->klass());

    if (retained) {
        [result release];
    }

    return JSValue::encode(retainedValue);
}

static EncodedJSValue JSC_HOST_CALL takeRetainedValue(ExecState* execState) {
    return takeValue(execState, true);
}

static EncodedJSValue JSC_HOST_CALL takeUnretainedValue(ExecState* execState) {
    return takeValue(execState, false);
}

void UnmanagedPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);

    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, WTF::ASCIILiteral("takeRetainedValue")), 1, takeRetainedValue, NoIntrinsic, DontDelete | ReadOnly);
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, WTF::ASCIILiteral("takeUnretainedValue")), 1, takeUnretainedValue, NoIntrinsic, DontDelete | ReadOnly);
}
}
