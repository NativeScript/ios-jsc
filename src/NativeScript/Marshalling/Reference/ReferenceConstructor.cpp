//
//  ReferenceConstructor.cpp
//  NativeScript
//
//  Created by Jason Zhekov on 10/17/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ReferenceConstructor.h"
#include "ReferencePrototype.h"
#include "ReferenceInstance.h"
#include "Interop.h"

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

    if (execState->argumentCount() == 2) {
        JSValue type = execState->uncheckedArgument(0);
        JSValue value = execState->uncheckedArgument(1);

        const FFITypeMethodTable* ffiTypeMethodTable;
        if (!tryGetFFITypeMethodTable(type, &ffiTypeMethodTable)) {
            return throwVMError(execState, createError(execState, WTF::ASCIILiteral("Not a valid type object is passed as parameter.")));
        }

        bool hasHandle;
        void* handle = tryHandleofValue(value, &hasHandle);
        PointerInstance* pointer;
        if (hasHandle) {
            pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState->vm(), handle));
        } else {
            handle = calloc(ffiTypeMethodTable->ffiType->size, 1);
            pointer = jsCast<PointerInstance*>(globalObject->interop()->pointerInstanceForPointer(execState->vm(), handle));
            pointer->setAdopted(true);

            ffiTypeMethodTable->write(execState, value, handle, type.asCell());
        }

        result = ReferenceInstance::create(execState->vm(), globalObject, globalObject->interop()->referenceInstanceStructure(), type.asCell(), pointer);
    } else {
        const JSValue value = execState->argument(0);
        result = ReferenceInstance::create(execState->vm(), globalObject->interop()->referenceInstanceStructure(), value);
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
