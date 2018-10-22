//
//  ObjCFastEnumerationIteratorPrototype.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 14.07.15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

#include "ObjCFastEnumerationIteratorPrototype.h"
#include "ObjCFastEnumerationIterator.h"
#include <JavaScriptCore/IteratorOperations.h>

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCFastEnumerationIteratorPrototype::s_info = { "NSFastEnumeration Iterator", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCFastEnumerationIteratorPrototype) };

EncodedJSValue JSC_HOST_CALL FastEnumerationIteratorPrototypeFuncNext(ExecState*);

void ObjCFastEnumerationIteratorPrototype::finishCreation(VM& vm, JSGlobalObject* globalObject) {
    Base::finishCreation(vm);
    didBecomePrototype();

    JSC_NATIVE_FUNCTION(vm.propertyNames->next, FastEnumerationIteratorPrototypeFuncNext, static_cast<unsigned>(PropertyAttribute::DontEnum), 0);
}

EncodedJSValue JSC_HOST_CALL FastEnumerationIteratorPrototypeFuncNext(ExecState* execState) {
    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);

    auto iterator = jsDynamicCast<ObjCFastEnumerationIterator*>(vm, execState->thisValue());
    if (!iterator)
        return JSValue::encode(throwTypeError(execState, scope, "Cannot call NSFastEnumerationIterator.next() on a non-NSFastEnumerationIterator object"_s));

    JSValue result;
    if (iterator->next(execState, result)) {
        return JSValue::encode(createIteratorResultObject(execState, result, false));
    }

    if (scope.exception()) {
        return JSValue::encode(jsUndefined());
    }

    return JSValue::encode(createIteratorResultObject(execState, jsUndefined(), true));
}
}
