//
//  TNSFastEnumerationAdapter.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 15.07.15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "TNSFastEnumerationAdapter.h"
#include "JSErrors.h"
#include "ObjCTypes.h"
#include "Interop.h"
#include <JavaScriptCore/IteratorOperations.h>

namespace NativeScript {
using namespace JSC;

NSUInteger TNSFastEnumerationAdapter(id self, NSFastEnumerationState* state, id buffer[], NSUInteger length, GlobalObject* globalObject) {
    enum State : decltype(state->state) {
        Uninitialized = 0,
        Iterating,
        Done
    };

    if (state->state == State::Uninitialized) {
        ExecState* execState = globalObject->globalExec();
        JSObject* wrapper = globalObject->interop()->objectMap().get(self);
        RELEASE_ASSERT(wrapper);

        JSLockHolder lock(execState);

        JSValue iteratorFunction = wrapper->get(execState, execState->propertyNames().iteratorSymbol);
        reportErrorIfAny(execState);

        CallData iteratorFunctionCallData;
        CallType iteratorFunctionCallType = getCallData(iteratorFunction, iteratorFunctionCallData);
        if (iteratorFunctionCallType == CallTypeNone) {
            reportFatalErrorBeforeShutdown(execState, Exception::create(execState->vm(), createTypeError(execState)));
        }

        ArgList iteratorFunctionArguments;
        JSValue iterator = call(execState, iteratorFunction, iteratorFunctionCallType, iteratorFunctionCallData, wrapper, iteratorFunctionArguments);
        reportErrorIfAny(execState);

        if (!iterator.isObject()) {
            reportFatalErrorBeforeShutdown(execState, Exception::create(execState->vm(), createTypeError(execState)));
        }

        state->mutationsPtr = reinterpret_cast<unsigned long*>(self);
        state->extra[0] = reinterpret_cast<unsigned long>(execState);
        state->extra[1] = reinterpret_cast<unsigned long>(iterator.asCell());
        gcProtect(iterator);

        state->state = State::Iterating;
    }

    ExecState* execState = reinterpret_cast<ExecState*>(state->extra[0]);
    JSValue iterator(reinterpret_cast<JSCell*>(state->extra[1]));
    JSLockHolder lock(execState);

    if (state->state == State::Done) {
        return 0;
    }

    NSUInteger count = 0;
    state->itemsPtr = buffer;

    while (count < length) {
        JSValue next = iteratorStep(execState, iterator);
        reportErrorIfAny(execState);

        if (next.isFalse()) {
            iteratorClose(execState, iterator);
            reportErrorIfAny(execState);
            gcUnprotect(iterator);

            state->state = State::Done;
            break;
        }

        JSValue value = iteratorValue(execState, next);
        reportErrorIfAny(execState);

        *buffer++ = toObject(execState, value);
        reportErrorIfAny(execState);

        count++;
    }

    return count;
}
}