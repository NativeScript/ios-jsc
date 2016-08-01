//
//  ObjCTypeScriptExtend.mm
//  NativeScript
//
//  Created by Jason Zhekov on 9/5/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCTypeScriptExtend.h"
#include "GlobalObjectInspectorController.h"
#include "JSErrors.h"
#include "ObjCClassBuilder.h"
#include "ObjCConstructorDerived.h"
#include <JavaScriptCore/CodeBlock.h>
#include <JavaScriptCore/ObjectConstructor.h>

namespace NativeScript {
using namespace JSC;

static EncodedJSValue callOriginalExtends(ExecState* execState) {
    JSFunction* extends = jsCast<GlobalObject*>(execState->lexicalGlobalObject())->typeScriptOriginalExtendsFunction();

    CallData callData;
    CallType callType = extends->getCallData(extends, callData);
    call(execState, extends, callType, callData, execState->thisValue(), ArgList(execState));
    return JSValue::encode(jsUndefined());
}

static bool isPlainTypeScriptConstructor(JSFunction* typeScriptConstructor) {
    WTF::CString sourceUTF8 = typeScriptConstructor->sourceCode()->toString().simplifyWhiteSpace().utf8();

    NSArray* regularExpressions = @[
        @"^\\(\\)\\s?\\{\\s?\\}$",
        @"^\\(\\)\\s?\\{\\s?\\w+\\.apply\\(this,\\s?arguments\\);?\\s?\\}$"
    ];

    NSUInteger index = [regularExpressions indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop) {
      NSRegularExpression* regularExpression = [NSRegularExpression regularExpressionWithPattern:obj
                                                                                         options:0
                                                                                           error:nil];
      return [regularExpression numberOfMatchesInString:@(sourceUTF8.data())
                                                options:0
                                                  range:NSMakeRange(0, sourceUTF8.length())]
             > 0;
    }];
    return index != NSNotFound;
}

EncodedJSValue ObjCTypeScriptExtendFunction(ExecState* execState) {
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

    if (!execState->argument(1).inherits(ObjCConstructorBase::info())) {
        return callOriginalExtends(execState);
    }

    JSFunction* typeScriptConstructor = jsCast<JSFunction*>(execState->argument(0));
    if (!isPlainTypeScriptConstructor(typeScriptConstructor)) {
        WTF::String message = WTF::String::format("The TypeScript constructor \"%s\" will not be executed.", typeScriptConstructor->name(execState).utf8().data());
        warn(execState, message);
    }

    WTF::String name = typeScriptConstructor->name(execState);

    JSValue baseConstructor = execState->argument(1);
    __block std::unique_ptr<ObjCClassBuilder> classBuilder = std::make_unique<ObjCClassBuilder>(execState, baseConstructor, constructEmptyObject(execState), name);
    if (execState->hadException()) {
        return JSValue::encode(jsUndefined());
    }

    ObjCConstructorDerived* derivedConstructor = classBuilder->build(execState);
    if (execState->hadException()) {
        return JSValue::encode(jsUndefined());
    }

    CallFrame* callFrame = execState->callerFrame();
    for (Register* r = callFrame->registers(); r > callFrame->topOfFrame(); r--) {
        if (r->unboxedCell() == typeScriptConstructor) {
            *r = derivedConstructor;
        }
    }

    JSScope* scope = callFrame->scope(callFrame->codeBlock()->scopeRegister().offset());
    Identifier constructorName = Identifier::fromString(execState, name);
    JSValue containingScope = JSScope::resolve(execState, scope, constructorName);
    if (containingScope.isObject()) {
        JSValue currentValue = containingScope.get(execState, constructorName);
        if (currentValue.isCell() && currentValue.asCell() == typeScriptConstructor) {
            PutPropertySlot slot(containingScope);
            containingScope.put(execState, constructorName, derivedConstructor, slot);
        }
    }

    // imp_implementationWithBlock calls block copy, class copy and initialize gets skipped
    __block Class derivedClass = derivedConstructor->klass();

    IMP newInitialize = imp_implementationWithBlock(^(id self) {
      if (self != [derivedClass self]) {
          return;
      }

      JSLockHolder lock(globalObject->vm());
      ExecState* globalExec = globalObject->globalExec();

      JSObject* instanceMethods = jsCast<JSObject*>(derivedConstructor->get(globalExec, globalExec->vm().propertyNames->prototype));
      JSValue implementedProtocols = derivedConstructor->get(globalExec, Identifier::fromString(globalExec, "ObjCProtocols"));
      JSValue exposedMethods = derivedConstructor->get(globalExec, Identifier::fromString(globalExec, "ObjCExposedMethods"));

      classBuilder->implementProtocols(globalExec, implementedProtocols);
      reportErrorIfAny(globalExec);

      classBuilder->addInstanceMembers(globalExec, instanceMethods, exposedMethods);
      reportErrorIfAny(globalExec);

      classBuilder.reset();
    });
    class_addMethod(object_getClass(derivedClass), @selector(initialize), newInitialize, "v@:");

    return JSValue::encode(jsUndefined());
}
}