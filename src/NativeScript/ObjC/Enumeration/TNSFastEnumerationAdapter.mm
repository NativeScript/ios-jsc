//
//  TNSFastEnumerationAdapter.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 15.07.15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "TNSFastEnumerationAdapter.h"
#include "Interop.h"
#include "JSErrors.h"
#include "ObjCTypes.h"
#include "TNSRuntime+Private.h"
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
        JSObject* wrapper = [TNSRuntime runtimeForVM:&globalObject->vm()]->_objectMap.get()->get(self);
        RELEASE_ASSERT(wrapper);

        JSC::VM& vm = execState->vm();
        JSLockHolder lock(execState);

        auto scope = DECLARE_CATCH_SCOPE(vm);

        JSValue iteratorFunction = wrapper->get(execState, execState->propertyNames().iteratorSymbol);
        reportErrorIfAny(execState, scope);

        CallData iteratorFunctionCallData;
        CallType iteratorFunctionCallType = getCallData(iteratorFunction, iteratorFunctionCallData);
        if (iteratorFunctionCallType == CallType::None) {
            reportFatalErrorBeforeShutdown(execState, Exception::create(execState->vm(), createTypeError(execState)));
        }

        ArgList iteratorFunctionArguments;
        JSValue iterator = call(execState, iteratorFunction, iteratorFunctionCallType, iteratorFunctionCallData, wrapper, iteratorFunctionArguments);
        reportErrorIfAny(execState, scope);

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
    JSC::VM& vm = execState->vm();
    JSLockHolder lock(vm);
    auto scope = DECLARE_CATCH_SCOPE(vm);

    if (state->state == State::Done) {
        return 0;
    }

    NSUInteger count = 0;
    state->itemsPtr = buffer;

    while (count < length) {
        JSValue next = iteratorStep(execState, iterator);
        reportErrorIfAny(execState, scope);

        if (next.isFalse()) {
            iteratorClose(execState, iterator);
            reportErrorIfAny(execState, scope);
            gcUnprotect(iterator);

            state->state = State::Done;
            break;
        }

        JSValue value = iteratorValue(execState, next);
        reportErrorIfAny(execState, scope);

        *buffer++ = toObject(execState, value);
        reportErrorIfAny(execState, scope);

        count++;
    }

    return count;
}
}
