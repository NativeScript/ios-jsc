//
//  ReferenceConstructor.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/17/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ReferenceConstructor.h"
#include "Interop.h"
#include "RecordInstance.h"
#include "ReferenceInstance.h"
#include "ReferencePrototype.h"
#include "ReferenceTypeInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo ReferenceConstructor::s_info = { "Reference", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ReferenceConstructor) };

void ReferenceConstructor::finishCreation(VM& vm, ReferencePrototype* referencePrototype) {
    Base::finishCreation(vm, this->classInfo()->className);

    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, referencePrototype, PropertyAttribute::DontEnum | PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
    this->putDirectWithoutTransition(vm, vm.propertyNames->length, jsNumber(2), PropertyAttribute::ReadOnly | PropertyAttribute::DontEnum | PropertyAttribute::DontDelete);
}

EncodedJSValue JSC_HOST_CALL ReferenceConstructor::constructReference(ExecState* execState) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    ReferenceInstance* result;

    JSValue maybeType = execState->argument(0);
    JSC::VM& vm = execState->vm();
    const FFITypeMethodTable* ffiTypeMethodTable;
    if (tryGetFFITypeMethodTable(vm, maybeType, &ffiTypeMethodTable)) {
        void* handle = nullptr;
        bool adopted = true;

        if (execState->argumentCount() == 2) {
            JSValue value = execState->uncheckedArgument(1);
            if (PointerInstance* pointer = jsDynamicCast<PointerInstance*>(vm, value)) {
                handle = pointer->data();
                adopted = pointer->isAdopted();
            } else if (RecordInstance* record = jsDynamicCast<RecordInstance*>(vm, value)) {
                handle = record->pointer()->data();
                adopted = record->pointer()->isAdopted();
            } else if (ReferenceInstance* reference = jsDynamicCast<ReferenceInstance*>(vm, value)) {
                if (maybeType.inherits(vm, ReferenceTypeInstance::info())) {
                    // do nothing, this is a reference to reference
                } else if (PointerInstance* pointer = reference->pointer()) {
                    handle = pointer->data();
                    adopted = pointer->isAdopted();
                } else {
                    value = reference->get(execState, execState->vm().propertyNames->value);
                }
            }

            if (!handle) {
                handle = calloc(ffiTypeMethodTable->ffiType->size, 1);
                ffiTypeMethodTable->write(execState, value, handle, maybeType.asCell());
            }
        } else {
            handle = calloc(ffiTypeMethodTable->ffiType->size, 1);
        }

        PointerInstance* pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState, handle));
        pointer->setAdopted(adopted);
        result = ReferenceInstance::create(vm, globalObject, globalObject->interop()->referenceInstanceStructure(), maybeType.asCell(), pointer);
    } else if (execState->argumentCount() == 2) {
        auto scope = DECLARE_THROW_SCOPE(vm);

        return throwVMError(execState, scope, createError(execState, "Not a valid type object is passed as parameter."_s));
    } else {
        result = ReferenceInstance::create(vm, globalObject->interop()->referenceInstanceStructure(), maybeType);
    }

    return JSValue::encode(result);
}

} // namespace NativeScript
