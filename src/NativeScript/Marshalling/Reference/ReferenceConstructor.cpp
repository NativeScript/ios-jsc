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

const ClassInfo ReferenceConstructor::s_info = { "Reference", &Base::s_info, 0, CREATE_METHOD_TABLE(ReferenceConstructor) };

void ReferenceConstructor::finishCreation(VM& vm, ReferencePrototype* referencePrototype) {
    Base::finishCreation(vm, this->classInfo()->className);

    this->putDirectWithoutTransition(vm, vm.propertyNames->prototype, referencePrototype, DontEnum | DontDelete | ReadOnly);
    this->putDirectWithoutTransition(vm, vm.propertyNames->length, jsNumber(2), ReadOnly | DontEnum | DontDelete);
}

static EncodedJSValue JSC_HOST_CALL constructReference(ExecState* execState) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    ReferenceInstance* result;

    JSValue maybeType = execState->argument(0);
    const FFITypeMethodTable* ffiTypeMethodTable;
    if (tryGetFFITypeMethodTable(maybeType, &ffiTypeMethodTable)) {
        void* handle = nullptr;
        bool adopted = true;

        if (execState->argumentCount() == 2) {
            JSValue value = execState->uncheckedArgument(1);
            if (PointerInstance* pointer = jsDynamicCast<PointerInstance*>(value)) {
                handle = pointer->data();
                adopted = pointer->isAdopted();
            } else if (RecordInstance* record = jsDynamicCast<RecordInstance*>(value)) {
                handle = record->pointer()->data();
                adopted = record->pointer()->isAdopted();
            } else if (ReferenceInstance* reference = jsDynamicCast<ReferenceInstance*>(value)) {
                if (maybeType.inherits(ReferenceTypeInstance::info())) {
                    // do nothing, this is a reference to reference
                } else if (PointerInstance* pointer = reference->pointer()) {
                    handle = pointer->data();
                    adopted = pointer->isAdopted();
                } else {
                    value = reference->get(execState, execState->propertyNames().value);
                }
            }

            if (!handle) {
                handle = calloc(ffiTypeMethodTable->ffiType->size, 1);
                ffiTypeMethodTable->write(execState, value, handle, maybeType.asCell());
            }
        } else {
            handle = calloc(ffiTypeMethodTable->ffiType->size, 1);
        }

        PointerInstance* pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState->vm(), handle));
        pointer->setAdopted(adopted);
        result = ReferenceInstance::create(execState->vm(), globalObject, globalObject->interop()->referenceInstanceStructure(), maybeType.asCell(), pointer);
    } else if (execState->argumentCount() == 2) {
        return throwVMError(execState, createError(execState, WTF::ASCIILiteral("Not a valid type object is passed as parameter.")));
    } else {
        result = ReferenceInstance::create(execState->vm(), globalObject->interop()->referenceInstanceStructure(), maybeType);
    }

    return JSValue::encode(result);
}

ConstructType ReferenceConstructor::getConstructData(JSCell* cell, ConstructData& constructData) {
    constructData.native.function = &constructReference;
    return ConstructTypeHost;
}

CallType ReferenceConstructor::getCallData(JSCell* cell, CallData& callData) {
    callData.native.function = &constructReference;
    return CallTypeHost;
}
}
