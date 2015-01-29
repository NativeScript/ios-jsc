//
//  ObjCTypeScriptExtend.mm
//  NativeScript
//
//  Created by Jason Zhekov on 9/5/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCTypeScriptExtend.h"
#include <JavaScriptCore/JSGlobalObjectInspectorController.h>
#include <JavaScriptCore/ObjectConstructor.h>
#include "ObjCConstructorDerived.h"
#include "ObjCClassBuilder.h"

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
        @"^\\{\\s?\\}$",
        @"^\\{\\s?\\w+\\.apply\\(this,\\s?arguments\\);\\s?\\}$"
    ];

    NSUInteger index = [regularExpressions indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL* stop) {
        NSRegularExpression* regularExpression = [NSRegularExpression regularExpressionWithPattern:obj
                                                                                           options:0
                                                                                             error:nil];
        return [regularExpression numberOfMatchesInString:@(sourceUTF8.data())
                                                  options:0
                                                    range:NSMakeRange(0, sourceUTF8.length())] > 0;
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
        return JSValue::encode(execState->exception());
    }

    ObjCConstructorDerived* derivedConstructor = classBuilder->build(execState);
    if (execState->hadException()) {
        return JSValue::encode(execState->exception());
    }

    CallFrame* callFrame = execState->callerFrame();
    // Replace the TypeScript constructor with ours - see Interpreter::dumpRegisters
    callFrame->r(-3) = derivedConstructor;

    // imp_implementationWithBlock calls block copy, class copy and initialize gets skipped
    __block Class derivedClass = derivedConstructor->klass();

    IMP newInitialize = imp_implementationWithBlock (^(id self) {
        if (self != [derivedClass self]) {
            return;
        }

        ExecState* globalExec = globalObject->globalExec();

        JSObject* instanceMethods = jsCast<JSObject*>(derivedConstructor->get(globalExec, globalExec->vm().propertyNames->prototype));
        JSValue implementedProtocols = derivedConstructor->get(globalExec, Identifier(globalExec, WTF::ASCIILiteral("ObjCProtocols")));
        JSValue exposedMethods = derivedConstructor->get(globalExec, Identifier(globalExec, WTF::ASCIILiteral("ObjCExposedMethods")));

        classBuilder->implementProtocols(globalExec, implementedProtocols);
        if (globalExec->hadException()) {
            JSValue exception = globalExec->exception();
            globalExec->clearException();
            jsCast<GlobalObject*>(globalExec->lexicalGlobalObject())->inspectorController().reportAPIException(globalExec, exception);
            WTFCrash();
        }

        classBuilder->addInstanceMembers(globalExec, instanceMethods, exposedMethods);
        if (globalExec->hadException()) {
            JSValue exception = globalExec->exception();
            globalExec->clearException();
            jsCast<GlobalObject*>(globalExec->lexicalGlobalObject())->inspectorController().reportAPIException(globalExec, exception);
            WTFCrash();
        }

        classBuilder.reset();
    });
    class_addMethod(object_getClass(derivedClass), @selector(initialize), newInitialize, "v@:");

    return JSValue::encode(jsUndefined());
}
}