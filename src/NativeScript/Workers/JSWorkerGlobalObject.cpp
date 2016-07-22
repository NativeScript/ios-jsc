#include "JSWorkerGlobalObject.h"
#include "Error.h"

using namespace JSC;

namespace NativeScript {

static EncodedJSValue JSC_HOST_CALL jsWorkerGlobalObjectClose(ExecState* execState) {
    if (!execState->thisValue().isCell()) {
        return throwVMError(execState, createTypeError(execState, makeString("The close function can only be called on worker global object.")));
    }
    JSWorkerGlobalObject* castedThis = jsDynamicCast<JSWorkerGlobalObject*>(execState->thisValue().asCell());
    if (UNLIKELY(!castedThis))
        return throwVMError(execState, createTypeError(execState, makeString("The close function can only be called on worker global object.")));
    ASSERT_GC_OBJECT_INHERITS(castedThis, JSWorkerGlobalObject::info());
    castedThis->close();
    return JSValue::encode(jsUndefined());
}

EncodedJSValue JSC_HOST_CALL jsWorkerGlobalObjectPostMessage(ExecState* state) {
    //TODO: call this->postMessage with resolved arguments
    return JSValue::encode(jsNull());
}

JSWorkerGlobalObject* JSWorkerGlobalObject::create(WTF::String applicationPath, VM& vm, Structure* structure) {
    JSWorkerGlobalObject* object = new (NotNull, allocateCell<JSWorkerGlobalObject>(vm.heap)) JSWorkerGlobalObject(vm, structure);
    object->finishCreation(applicationPath, vm);
    vm.heap.addFinalizer(object, destroy);
    return object;
}

const ClassInfo JSWorkerGlobalObject::s_info = { "NativeScriptWorkerGlobal", &Base::s_info, 0, CREATE_METHOD_TABLE(JSWorkerGlobalObject) };

const unsigned JSWorkerGlobalObject::StructureFlags = Base::StructureFlags;

Structure* JSWorkerGlobalObject::createStructure(VM& vm, JSValue prototype) {
    return Structure::create(vm, 0, prototype, TypeInfo(GlobalObjectType, JSWorkerGlobalObject::StructureFlags), JSWorkerGlobalObject::info());
}

JSWorkerGlobalObject::JSWorkerGlobalObject(VM& vm, Structure* structure)
    : GlobalObject(vm, structure) {
}

JSWorkerGlobalObject::~JSWorkerGlobalObject() {
}

void JSWorkerGlobalObject::finishCreation(WTF::String applicationPath, VM& vm) {
    Base::finishCreation(applicationPath, vm);

    ExecState* globalExec = this->globalExec();

    // TODO: importScripts can recieve more than one argument
    this->putDirectNativeFunction(vm, this, Identifier::fromString(&vm, "importScripts"), 1, commonJSRequire, NoIntrinsic, DontEnum | DontDelete | ReadOnly);
    this->putDirect(vm, Identifier::fromString(&vm, "self"), JSValue(globalExec->globalThisValue()), DontEnum | ReadOnly | DontDelete);
    this->putDirectNativeFunction(vm, this, vm.propertyNames->close, 0, jsWorkerGlobalObjectClose, NoIntrinsic, DontEnum | DontDelete | ReadOnly);
}

void JSWorkerGlobalObject::close() {
    // TODO: Provide implementation
}
}