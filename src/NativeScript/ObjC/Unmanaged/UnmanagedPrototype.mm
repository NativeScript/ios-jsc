#include "UnmanagedPrototype.h"
#include "ObjCConstructorBase.h"
#include "ObjCTypes.h"
#include "UnmanagedInstance.h"

namespace NativeScript {
static char consumedUnmanagedCheck = 'k';

using namespace JSC;

const ClassInfo UnmanagedPrototype::s_info = { "Unmanaged", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(UnmanagedPrototype) };

static EncodedJSValue takeValue(ExecState* execState, bool retained) {
    VM& vm = execState->vm();
    UnmanagedInstance* instance = jsDynamicCast<UnmanagedInstance*>(vm, execState->thisValue());
    if (instance->data() == &consumedUnmanagedCheck) {
        auto scope = DECLARE_THROW_SCOPE(vm);
        return throwVMTypeError(execState, scope, "Unmanaged value has already been consumed."_s);
    }

    id result = static_cast<id>(instance->data());
    instance->setData(&consumedUnmanagedCheck);

    ObjCConstructorBase* returnType = jsCast<ObjCConstructorBase*>(instance->returnType());
    JSValue retainedValue = NativeScript::toValue(execState, result, returnType->klasses().known);

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

    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, "takeRetainedValue"_s), 1, takeRetainedValue, NoIntrinsic, PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
    this->putDirectNativeFunction(vm, globalObject, Identifier::fromString(&vm, "takeUnretainedValue"_s), 1, takeUnretainedValue, NoIntrinsic, PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
}
}
