//
//  GlobalObject.moduleLoader.mm
//  NativeScript
//
//  Created by Yavor Georgiev on 02.11.15.
//  Copyright (c) 2015 г. Telerik. All rights reserved.
//

#include "GlobalObject.h"
#include "Interop.h"
#include "LiveEdit/EditableSourceProvider.h"
#include "ObjCTypes.h"
#include <JavaScriptCore/BuiltinNames.h>
#include <JavaScriptCore/Exception.h>
#include <JavaScriptCore/FunctionConstructor.h>
#include <JavaScriptCore/JSArrayBuffer.h>
#include <JavaScriptCore/JSInternalPromise.h>
#include <JavaScriptCore/JSInternalPromiseDeferred.h>
#include <JavaScriptCore/JSModuleEnvironment.h>
#include <JavaScriptCore/JSModuleRecord.h>
#include <JavaScriptCore/JSNativeStdFunction.h>
#include <JavaScriptCore/LiteralParser.h>
#include <JavaScriptCore/ModuleAnalyzer.h>
#include <JavaScriptCore/ModuleLoaderObject.h>
#include <JavaScriptCore/Nodes.h>
#include <JavaScriptCore/ObjectConstructor.h>
#include <JavaScriptCore/Parser.h>
#include <JavaScriptCore/ParserError.h>
#include <JavaScriptCore/tools/CodeProfiling.h>
#include <sys/stat.h>

namespace NativeScript {
using namespace JSC;

template <mode_t mode>
static NSString* stat(NSString* path) {
    struct stat statbuf;
    if (stat(path.fileSystemRepresentation, &statbuf) == 0) {
        if ((statbuf.st_mode & S_IFMT) == mode) {
            return path;
        }
    }

    return nil;
}

static NSString* resolveFile(NSString* filePath) {
    if (stat<S_IFREG>(filePath)) {
        return filePath;
    } else if (NSString* path = stat<S_IFREG>([filePath stringByAppendingPathExtension:@"js"])) {
        return path;
    } else if (NSString* path = stat<S_IFREG>([filePath stringByAppendingPathExtension:@"json"])) {
        return path;
    }

    return nil;
}

JSInternalPromise* GlobalObject::moduleLoaderResolve(JSGlobalObject* globalObject, ExecState* execState, JSValue keyValue, JSValue referrerValue) {
    JSInternalPromiseDeferred* deferred = JSInternalPromiseDeferred::create(execState, globalObject);

    if (keyValue.isSymbol()) {
        return deferred->resolve(execState, keyValue);
    }

    NSString* path = keyValue.toWTFString(execState);
    if (JSC::Exception* e = execState->exception()) {
        execState->clearException();
        return deferred->reject(execState, e);
    }

    GlobalObject* self = jsCast<GlobalObject*>(globalObject);

    NSString* absolutePath = path;
    unichar pathChar = [path characterAtIndex:0];
    if (pathChar != '/') {
        if (pathChar == '.') {
            if (referrerValue.isString()) {
                absolutePath = [static_cast<NSString*>(referrerValue.toWTFString(execState)) stringByDeletingLastPathComponent];
            } else {
                absolutePath = [static_cast<NSString*>(self->applicationPath()) stringByAppendingPathComponent:@"app"];
            }
        } else if (pathChar == '~') {
            absolutePath = [static_cast<NSString*>(self->applicationPath()) stringByAppendingPathComponent:@"app"];
            path = [path substringFromIndex:2];
        } else {
            absolutePath = [static_cast<NSString*>(self->applicationPath()) stringByAppendingPathComponent:@"app/tns_modules"];
        }

        absolutePath = [[absolutePath stringByAppendingPathComponent:path] stringByStandardizingPath];
    }

    WTF::String requestedPath = absolutePath;
    if (self->modulePathCache().contains(requestedPath)) {
        return deferred->resolve(execState, jsString(execState, self->modulePathCache().get(requestedPath)));
    }

    NSString* absoluteFilePath = resolveFile(absolutePath);
    if (!absoluteFilePath && stat<S_IFDIR>(absolutePath)) {
        NSString* mainFileName = @"index.js";

        NSString* packageJsonPath = [absolutePath stringByAppendingPathComponent:@"package.json"];
        if (stat<S_IFREG>(packageJsonPath)) {
            NSError* error = nil;
            NSData* packageJsonData = [NSData dataWithContentsOfFile:packageJsonPath options:0 error:&error];
            if (!packageJsonData && error) {
                return deferred->reject(execState, self->interop()->wrapError(execState, error));
            }

            NSDictionary* packageJson = [NSJSONSerialization JSONObjectWithData:packageJsonData options:0 error:&error];
            if (!packageJson && error) {
                return deferred->reject(execState, self->interop()->wrapError(execState, error));
            }

            if (NSString* packageMain = [packageJson objectForKey:@"main"]) {
                mainFileName = packageMain;
            }
        }

        absoluteFilePath = resolveFile([absolutePath stringByAppendingPathComponent:mainFileName]);
    }

    if (!absoluteFilePath) {
        WTF::String errorMessage = WTF::String::format("Could not find module '%s'. Computed path '%s'.", keyValue.toWTFString(execState).utf8().data(), absolutePath.UTF8String);
        return deferred->reject(execState, createError(execState, errorMessage));
    }

    self->modulePathCache().set(requestedPath, absoluteFilePath);
    return deferred->resolve(execState, jsString(execState, absoluteFilePath));
}

JSInternalPromise* GlobalObject::moduleLoaderFetch(JSGlobalObject* globalObject, ExecState* execState, JSValue keyValue) {
    JSInternalPromiseDeferred* deferred = JSInternalPromiseDeferred::create(execState, globalObject);

    NSString* modulePath = keyValue.toWTFString(execState);
    if (JSC::Exception* e = execState->exception()) {
        execState->clearException();
        return deferred->reject(execState, e->value());
    }

    GlobalObject* self = jsCast<GlobalObject*>(globalObject);

    NSError* error = nil;
    NSData* moduleContent = [NSData dataWithContentsOfFile:modulePath options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        return deferred->reject(execState, self->interop()->wrapError(execState, error));
    }

    return deferred->resolve(execState, self->interop()->bufferFromData(execState, moduleContent));
}

JSInternalPromise* GlobalObject::moduleLoaderTranslate(JSGlobalObject* globalObject, ExecState* execState, JSValue keyValue, JSValue sourceValue) {
    JSInternalPromiseDeferred* deferred = JSInternalPromiseDeferred::create(execState, globalObject);

    id source = NativeScript::toObject(execState, sourceValue);
    if (Exception* exception = execState->exception()) {
        execState->clearException();
        return deferred->reject(execState, exception);
    }

    NSString* contents = nil;

    if ([source isKindOfClass:[NSData class]]) {
        contents = [[NSString alloc] initWithData:source encoding:NSUTF8StringEncoding];

        if (contents == nil) {
            return deferred->reject(execState, createTypeError(execState, WTF::String::format("Only UTF-8 character encoding is supported: %s", keyValue.toWTFString(execState).utf8().data())));
        }
    } else if ([source isKindOfClass:[NSString class]]) {
        contents = source;
    } else {
        return deferred->reject(execState, createTypeError(execState, WTF::String::format("Unexpected module source type '%s'.", NSStringFromClass([source class]).UTF8String)));
    }

    return deferred->resolve(execState, jsString(execState, contents));
}

static JSModuleRecord* parseModule(ExecState* execState, const SourceCode& sourceCode, const Identifier& moduleKey, ParserError& parserError) {
    CodeProfiling profile(sourceCode);

    std::unique_ptr<ModuleProgramNode> moduleProgramNode = parse<ModuleProgramNode>(
        &execState->vm(), sourceCode, Identifier(), JSParserBuiltinMode::NotBuiltin,
        JSParserStrictMode::Strict, SourceParseMode::ModuleAnalyzeMode, parserError);

    if (!moduleProgramNode) {
        return nullptr;
    }

    ModuleAnalyzer moduleAnalyzer(execState, moduleKey, sourceCode, moduleProgramNode->varDeclarations(), moduleProgramNode->lexicalVariables());
    return moduleAnalyzer.analyze(*moduleProgramNode);
}

JSInternalPromise* GlobalObject::moduleLoaderInstantiate(JSGlobalObject* globalObject, ExecState* execState, JSValue keyValue, JSValue sourceValue) {
    JSInternalPromiseDeferred* deferred = JSInternalPromiseDeferred::create(execState, globalObject);

    VM& vm = execState->vm();
    const Identifier moduleKey = execState->argument(0).toPropertyKey(execState);
    if (Exception* exception = execState->exception()) {
        vm.clearException();
        return deferred->reject(execState, exception->value());
    }

    WTF::String source = execState->argument(1).toWTFString(execState);
    if (Exception* exception = execState->exception()) {
        vm.clearException();
        return deferred->reject(execState, exception->value());
    }

    GlobalObject* self = jsCast<GlobalObject*>(globalObject);

    WTF::StringBuilder moduleUrl;
    moduleUrl.append("file://");

    if (moduleKey.impl()->startsWith(self->applicationPath().impl())) {
        moduleUrl.append(moduleKey.impl()->substring(self->applicationPath().length()));
    } else {
        moduleUrl.append(WTF::String(moduleKey.impl()));
    }

    JSValue json;
    if (moduleKey.impl()->endsWith(".json")) {
        if (source.is8Bit()) {
            LiteralParser<LChar> jsonParser(execState, source.characters8(), source.length(), StrictJSON);
            json = jsonParser.tryLiteralParse();
            if (!json) {
                return deferred->reject(execState, createSyntaxError(execState, jsonParser.getErrorMessage()));
            }
        } else {
            LiteralParser<UChar> jsonParser(execState, source.characters16(), source.length(), StrictJSON);
            json = jsonParser.tryLiteralParse();
            if (!json) {
                return deferred->reject(execState, createSyntaxError(execState, jsonParser.getErrorMessage()));
            }
        }

        moduleUrl.clear(); // hide the module from the debugger
        source = WTF::ASCIILiteral("export default undefined;");
    }

    SourceCode sourceCode = SourceCode(EditableSourceProvider::create(source, moduleUrl.toString()));
    ParserError error;
    JSModuleRecord* moduleRecord = parseModule(execState, sourceCode, moduleKey, error);

    if (!moduleRecord || (moduleRecord->requestedModules().isEmpty() && moduleRecord->exportEntries().isEmpty() && moduleRecord->starExportEntries().isEmpty() && !json)) {
        error = ParserError();
        sourceCode = SourceCode(EditableSourceProvider::create(WTF::ASCIILiteral("export default undefined;"), WTF::emptyString()));
        moduleRecord = parseModule(execState, sourceCode, moduleKey, error);
        ASSERT(!error.isValid());

        WTF::StringBuilder moduleFunctionSource;
        moduleFunctionSource.append("{function anonymous(require, module, exports, __dirname, __filename) {");
        moduleFunctionSource.append(source);
        moduleFunctionSource.append("\n}}");

        JSObject* exception = nullptr;
        sourceCode = SourceCode(EditableSourceProvider::create(moduleFunctionSource.toString(), moduleUrl.toString()));
        FunctionExecutable* moduleFunctionExecutable = FunctionExecutable::fromGlobalCode(Identifier::fromString(execState, "anonymous"), *execState, sourceCode, exception, -1);
        if (!moduleFunctionExecutable) {
            ASSERT(exception);
            return deferred->reject(execState, exception);
        }

        JSFunction* moduleFunction = JSFunction::create(vm, moduleFunctionExecutable, self);
        moduleRecord->putDirect(vm, self->_commonJSModuleFunctionIdentifier, moduleFunction);
    } else if (json) {
        moduleRecord->putDirect(vm, vm.propertyNames->JSON, json);
    } else if (error.isValid()) {
        return deferred->reject(execState, error.toErrorObject(globalObject, sourceCode));
    }

    return deferred->resolve(execState, moduleRecord);
}

EncodedJSValue JSC_HOST_CALL GlobalObject::commonJSRequire(ExecState* execState) {
    JSValue moduleName = execState->argument(0);
    if (!moduleName.isString()) {
        return JSValue::encode(throwTypeError(execState, WTF::ASCIILiteral("Expected module identifier to be a string.")));
    }

    JSValue callee = execState->calleeAsValue();
    JSValue refererKey = callee.get(execState, execState->propertyNames().sourceURL);

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    JSInternalPromise* promise = globalObject->moduleLoader()->resolve(execState, moduleName, refererKey);

    Exception* exception = nullptr;
    JSFunction* errorHandler = JSNativeStdFunction::create(execState->vm(), globalObject, 1, String(), [&exception](ExecState* execState) {
        JSValue error = execState->argument(0);
        exception = jsDynamicCast<Exception*>(error);
        if (!exception && !error.isUndefinedOrNull()) {
            exception = Exception::create(execState->vm(), error);
        }
        return JSValue::encode(jsUndefined());
    });

    JSModuleRecord* record;
    promise->then(execState, JSNativeStdFunction::create(execState->vm(), globalObject, 1, String(), [&record, errorHandler](ExecState* execState) {
                      JSValue moduleKey = execState->argument(0);

                      JSValue moduleLoader = execState->lexicalGlobalObject()->moduleLoader();
                      JSObject* function = jsCast<JSObject*>(moduleLoader.get(execState, execState->propertyNames().builtinNames().linkAndEvaluateModulePublicName()));
                      CallData callData;
                      CallType callType = JSC::getCallData(function, callData);

                      JSInternalPromise* promise = jsCast<JSInternalPromise*>(JSC::call(execState, function, callType, callData, moduleLoader, execState));
                      promise = promise->then(execState, JSNativeStdFunction::create(execState->vm(), execState->lexicalGlobalObject(), 1, String(), [moduleKey, &record](ExecState* execState) {
                                                  JSValue moduleLoader = execState->lexicalGlobalObject()->moduleLoader();
                                                  JSObject* function = jsCast<JSObject*>(moduleLoader.get(execState, execState->propertyNames().builtinNames().ensureRegisteredPublicName()));

                                                  CallData callData;
                                                  CallType callType = JSC::getCallData(function, callData);

                                                  MarkedArgumentBuffer args;
                                                  args.append(moduleKey);
                                                  JSValue entry = JSC::call(execState, function, callType, callData, moduleLoader, args);
                                                  record = jsCast<JSModuleRecord*>(entry.get(execState, Identifier::fromString(execState, "module")));

                                                  return JSValue::encode(jsUndefined());
                                              }),
                                              errorHandler);

                      return JSValue::encode(promise);
                  }),
                  errorHandler);
    globalObject->drainMicrotasks();

    if (exception) {
        execState->vm().throwException(execState, exception);
        return JSValue::encode(exception);
    }

    // maybe the require'd module is a CommonJS module?
    if (JSValue moduleFunction = record->getDirect(execState->vm(), globalObject->_commonJSModuleFunctionIdentifier)) {
        JSValue module = moduleFunction.get(execState, execState->propertyNames().builtinNames().moduleEvaluationPrivateName());
        return JSValue::encode(module.get(execState, Identifier::fromString(execState, "exports")));
    }

    JSModuleRecord::Resolution resolution = record->resolveExport(execState, execState->propertyNames().defaultKeyword);
    if (resolution.type == JSModuleRecord::Resolution::Type::Resolved) {
        JSValue defaultExport = record->moduleEnvironment()->get(execState, resolution.localName);
        ASSERT(!defaultExport.isEmpty());
        return JSValue::encode(defaultExport);
    }

    return JSValue::encode(jsUndefined());
}

static void putValueInScopeAndSymbolTable(VM& vm, JSModuleRecord* moduleRecord, const Identifier& identifier, JSValue value) {
    JSModuleEnvironment* moduleEnvironment = moduleRecord->moduleEnvironment();
    SymbolTable* moduleSymbolTable = moduleEnvironment->symbolTable();

    const SymbolTableEntry& entry = moduleSymbolTable->get(identifier.impl());
    ASSERT(!entry.isNull());
    moduleEnvironment->variableAt(entry.scopeOffset()).set(vm, moduleEnvironment, value);
}

JSValue GlobalObject::moduleLoaderEvaluate(JSGlobalObject* globalObject, ExecState* execState, JSValue keyValue, JSValue moduleRecordValue) {
    JSModuleRecord* moduleRecord = jsDynamicCast<JSModuleRecord*>(moduleRecordValue);
    if (!moduleRecord) {
        return jsUndefined();
    }

    GlobalObject* self = jsCast<GlobalObject*>(globalObject);
    VM& vm = execState->vm();

    if (JSValue moduleFunction = moduleRecord->getDirect(vm, self->_commonJSModuleFunctionIdentifier)) {
        NSURL* moduleUrl = [NSURL fileURLWithPath:(NSString*)keyValue.toWTFString(execState).createCFString().get()];
        Identifier exportsIdentifier = Identifier::fromString(&vm, "exports");

        JSObject* module = constructEmptyObject(execState);
        jsCast<JSObject*>(moduleFunction)->putDirect(vm, vm.propertyNames->builtinNames().moduleEvaluationPrivateName(), module, ReadOnly | DontDelete | DontEnum);
        module->putDirect(vm, Identifier::fromString(&vm, "id"), jsString(&vm, moduleUrl.path));
        module->putDirect(vm, Identifier::fromString(&vm, "filename"), jsString(&vm, moduleUrl.path));

        JSObject* exports = constructEmptyObject(execState);
        module->putDirect(vm, exportsIdentifier, exports);

        JSFunction* require = JSFunction::create(vm, globalObject, 1, WTF::ASCIILiteral("require"), commonJSRequire);
        require->putDirect(vm, vm.propertyNames->sourceURL, keyValue, ReadOnly | DontDelete | DontEnum);
        module->putDirect(vm, Identifier::fromString(&vm, "require"), require);

        MarkedArgumentBuffer args;
        args.append(require);
        args.append(module);
        args.append(exports);
        args.append(jsString(&vm, moduleUrl.path.stringByDeletingLastPathComponent));
        args.append(jsString(&vm, moduleUrl.path));

        CallData callData;
        CallType callType = JSC::getCallData(moduleFunction, callData);

        WTF::NakedPtr<Exception> exception;
        JSValue result = JSC::call(execState, moduleFunction.asCell(), callType, callData, execState->globalThisValue(), args, exception);
        if (exception) {
            vm.throwException(execState, exception.get());
            return exception.get();
        }

        putValueInScopeAndSymbolTable(vm, moduleRecord, vm.propertyNames->builtinNames().starDefaultPrivateName(), module->getDirect(vm, exportsIdentifier));
        return result;
    } else if (JSValue json = moduleRecord->getDirect(vm, vm.propertyNames->JSON)) {
        putValueInScopeAndSymbolTable(vm, moduleRecord, vm.propertyNames->builtinNames().starDefaultPrivateName(), json);
        return json;
    }

    return moduleRecord->evaluate(execState);
}
}
