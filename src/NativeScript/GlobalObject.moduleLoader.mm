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
#include "ManualInstrumentation.h"
#include "ObjCTypes.h"
#include "TNSRuntime.h"
#include <JavaScriptCore/BuiltinNames.h>
#include <JavaScriptCore/CatchScope.h>
#include <JavaScriptCore/Completion.h>
#include <JavaScriptCore/Exception.h>
#include <JavaScriptCore/FunctionConstructor.h>
#include <JavaScriptCore/JSArrayBuffer.h>
#include <JavaScriptCore/JSInternalPromise.h>
#include <JavaScriptCore/JSInternalPromiseDeferred.h>
#include <JavaScriptCore/JSModuleEnvironment.h>
#include <JavaScriptCore/JSModuleLoader.h>
#include <JavaScriptCore/JSModuleRecord.h>
#include <JavaScriptCore/JSNativeStdFunction.h>
#include <JavaScriptCore/JSSourceCode.h>
#include <JavaScriptCore/LiteralParser.h>
#include <JavaScriptCore/ModuleAnalyzer.h>
#include <JavaScriptCore/ModuleLoaderPrototype.h>
#include <JavaScriptCore/Nodes.h>
#include <JavaScriptCore/ObjectConstructor.h>
#include <JavaScriptCore/Parser.h>
#include <JavaScriptCore/ParserError.h>
#include <JavaScriptCore/tools/CodeProfiling.h>
#include <sys/stat.h>

static UChar pathSeparator() {
#if OS(WINDOWS)
    return '\\';
#else
    return '/';
#endif
}

struct DirectoryName {
    // In unix, it is "/". In Windows, it becomes a drive letter like "C:\"
    String rootName;

    // If the directory name is "/home/WebKit", this becomes "home/WebKit". If the directory name is "/", this becomes "".
    String queryName;
};

struct ModuleName {
    ModuleName(const String& moduleName);

    bool startsWithRoot() const {
        return !queries.isEmpty() && queries[0].isEmpty();
    }

    Vector<String> queries;
};

ModuleName::ModuleName(const String& moduleName) {
    // A module name given from code is represented as the UNIX style path. Like, `./A/B.js`.
    moduleName.split('/', true, queries);
}

static std::optional<DirectoryName> extractDirectoryName(const String& absolutePathToFile) {
    size_t firstSeparatorPosition = absolutePathToFile.find(pathSeparator());
    if (firstSeparatorPosition == notFound)
        return std::nullopt;
    DirectoryName directoryName;
    directoryName.rootName = absolutePathToFile.substring(0, firstSeparatorPosition + 1); // Include the separator.
    size_t lastSeparatorPosition = absolutePathToFile.reverseFind(pathSeparator());
    ASSERT_WITH_MESSAGE(lastSeparatorPosition != notFound, "If the separator is not found, this function already returns when performing the forward search.");
    if (firstSeparatorPosition == lastSeparatorPosition)
        directoryName.queryName = StringImpl::empty();
    else {
        size_t queryStartPosition = firstSeparatorPosition + 1;
        size_t queryLength = lastSeparatorPosition - queryStartPosition; // Not include the last separator.
        directoryName.queryName = absolutePathToFile.substring(queryStartPosition, queryLength);
    }
    return directoryName;
}

static String resolvePath(const DirectoryName& directoryName, const ModuleName& moduleName) {
    Vector<String> directoryPieces;
    directoryName.queryName.split(pathSeparator(), false, directoryPieces);

    // Only first '/' is recognized as the path from the root.
    if (moduleName.startsWithRoot())
        directoryPieces.clear();

    for (const auto& query : moduleName.queries) {
        if (query == String(ASCIILiteral(".."))) {
            if (!directoryPieces.isEmpty())
                directoryPieces.removeLast();
        } else if (!query.isEmpty() && query != String(ASCIILiteral(".")))
            directoryPieces.append(query);
    }

    StringBuilder builder;
    builder.append(directoryName.rootName);
    for (size_t i = 0; i < directoryPieces.size(); ++i) {
        builder.append(directoryPieces[i]);
        if (i + 1 != directoryPieces.size())
            builder.append(pathSeparator());
    }
    return builder.toString();
}

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

static NSString* resolveAbsolutePath(NSString* absolutePath, WTF::HashMap<WTF::String, WTF::String, WTF::ASCIICaseInsensitiveHash>& cache, NSError** error) {
    if (cache.contains(absolutePath)) {
        return cache.get(absolutePath);
    }

    if (stat<S_IFREG>(absolutePath)) {
        cache.set(absolutePath, absolutePath);
        return absolutePath;
    }

    if (NSString* path = stat<S_IFREG>([absolutePath stringByAppendingPathExtension:@"js"])) {
        cache.set(absolutePath, path);
        return path;
    }

    if (NSString* path = stat<S_IFREG>([absolutePath stringByAppendingPathExtension:@"json"])) {
        cache.set(absolutePath, path);
        return path;
    }

    if (stat<S_IFDIR>(absolutePath)) {
        NSString* mainName = @"index.js";

        NSString* packageJsonPath = [absolutePath stringByAppendingPathComponent:@"package.json"];
        if (stat<S_IFREG>(packageJsonPath)) {
            NSData* packageJsonData = [NSData dataWithContentsOfFile:packageJsonPath options:0 error:error];
            if (!packageJsonData && error) {
                return nil;
            }

            NSDictionary* packageJson = [NSJSONSerialization JSONObjectWithData:packageJsonData options:0 error:error];
            if (!packageJson && error) {
                return nil;
            }

            if (NSString* packageMain = [packageJson objectForKey:@"main"]) {
                mainName = packageMain;
            }
        }

        NSString* resolved = resolveAbsolutePath([[absolutePath stringByAppendingPathComponent:mainName] stringByStandardizingPath], cache, error);
        if (*error) {
            return nil;
        }

        cache.set(absolutePath, resolved);
        return resolved;
    }

    return nil;
}

NSString* normalizePath(NSString* path) {
    NSArray<NSString*>* pathComponents = [path componentsSeparatedByString:@"/"];
    NSMutableArray* stack = [[NSMutableArray alloc] initWithCapacity:pathComponents.count];
    for (NSString* pathComponent in pathComponents) {
        if ([pathComponent isEqualToString:@".."]) {
            [stack removeLastObject];
        } else if (![pathComponent isEqualToString:@"."] && ![pathComponent isEqualToString:@""]) {
            [stack addObject:pathComponent];
        }
    }
    NSString* result = [stack componentsJoinedByString:@"/"];
    if ([path hasPrefix:@"/"]) {
        result = [@"/" stringByAppendingString:result];
    }
    [stack release];
    return result;
}

JSInternalPromise* GlobalObject::moduleLoaderResolve(JSGlobalObject* globalObject, ExecState* execState, JSModuleLoader* loader, JSValue keyValue, JSValue referrerValue, JSValue initiator) {
    JSInternalPromiseDeferred* deferred = JSInternalPromiseDeferred::create(execState, globalObject);

    if (keyValue.isSymbol()) {
        return deferred->resolve(execState, keyValue);
    }

    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_CATCH_SCOPE(vm);

    NSString* path = keyValue.toWTFString(execState);
    if (JSC::Exception* e = scope.exception()) {
        scope.clearException();
        return deferred->reject(execState, e);
    }

    GlobalObject* self = jsCast<GlobalObject*>(globalObject);

    NSString* absolutePath = path;
    unichar pathChar = [path characterAtIndex:0];

    bool isModuleRequire = false;

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
            absolutePath = [static_cast<NSString*>(self->applicationPath()) stringByAppendingPathComponent:@"app/tns_modules/tns-core-modules"];
            isModuleRequire = true;
        }
        absolutePath = [normalizePath([absolutePath stringByAppendingPathComponent:path]) stringByStandardizingPath];
    }

    NSError* error = nil;
    NSString* absoluteFilePath = resolveAbsolutePath(absolutePath, self->modulePathCache(), &error);
    if (error) {
        return deferred->reject(execState, self->interop()->wrapError(execState, error));
    }

    if (isModuleRequire) {
        if (!absoluteFilePath) {
            NSString* currentSearchPath = [static_cast<NSString*>(referrerValue.toWTFString(execState)) stringByDeletingLastPathComponent];
            do {
                NSString* currentNodeModulesPath = [[currentSearchPath stringByAppendingPathComponent:@"node_modules"] stringByStandardizingPath];
                if (stat<S_IFDIR>(currentNodeModulesPath)) {
                    absoluteFilePath = resolveAbsolutePath([currentNodeModulesPath stringByAppendingPathComponent:path], self -> modulePathCache(), &error);
                    if (error) {
                        return deferred->reject(execState, self->interop()->wrapError(execState, error));
                    }

                    if (absoluteFilePath) {
                        break;
                    }
                }
                currentSearchPath = [currentSearchPath stringByDeletingLastPathComponent];
            } while (currentSearchPath.length > self->applicationPath().length());
        }

        if (!absoluteFilePath) {
            absolutePath = [[[static_cast<NSString*>(self->applicationPath()) stringByAppendingPathComponent:@"app/tns_modules"] stringByAppendingPathComponent:path] stringByStandardizingPath];
            absoluteFilePath = resolveAbsolutePath(absolutePath, self->modulePathCache(), &error);
            if (error) {
                return deferred->reject(execState, self->interop()->wrapError(execState, error));
            }
        }
    }

    if (!absoluteFilePath) {
        WTF::String errorMessage = WTF::String::format("Could not find module '%s'. Computed path '%s'.", keyValue.toWTFString(execState).utf8().data(), absolutePath.UTF8String);
        return deferred->reject(execState, createError(execState, errorMessage));
    }

    return deferred->resolve(execState, jsString(execState, absoluteFilePath));
}

JSInternalPromise* GlobalObject::moduleLoaderFetch(JSGlobalObject* globalObject, ExecState* execState, JSModuleLoader* loader, JSValue keyValue, JSValue initiator) {
    JSInternalPromiseDeferred* deferred = JSInternalPromiseDeferred::create(execState, globalObject);

    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_CATCH_SCOPE(vm);

    auto modulePath = keyValue.toWTFString(execState);
    if (JSC::Exception* e = scope.exception()) {
        scope.clearException();
        return deferred->reject(execState, e->value());
    }

    GlobalObject* self = jsCast<GlobalObject*>(globalObject);

    NSError* error = nil;
    NSData* moduleContent = [NSData dataWithContentsOfFile:modulePath options:NSDataReadingMappedIfSafe error:&error];
    if (error) {
        return deferred->reject(execState, self->interop()->wrapError(execState, error));
    }

    String moduleContentStr = WTF::String::fromUTF8((const LChar*)moduleContent.bytes, moduleContent.length);
    if (moduleContentStr.isNull() && moduleContent.length > 0) {
        return deferred->reject(execState, createTypeError(execState, WTF::String::format("Only UTF-8 character encoding is supported: %s", keyValue.toWTFString(execState).utf8().data())));
    }

    WTF::StringBuilder moduleUrl;
    moduleUrl.append("file://");

    if (modulePath.startsWith(self->applicationPath().impl())) {
        moduleUrl.append(modulePath.impl()->substring(self->applicationPath().length()));
    } else {
        moduleUrl.append(WTF::String(modulePath.impl()));
    }

    return deferred->resolve(execState, JSSourceCode::create(vm, makeSource(moduleContentStr, SourceOrigin(modulePath), moduleUrl.toString(), TextPosition(), SourceProviderSourceType::Module)));
}

static JSModuleRecord* parseModule(ExecState* execState, const SourceCode& sourceCode, const Identifier& moduleKey, ParserError& parserError) {
    CodeProfiling profile(sourceCode);

    std::unique_ptr<ModuleProgramNode> moduleProgramNode = parse<ModuleProgramNode>(
        &execState->vm(), sourceCode, Identifier(), JSParserBuiltinMode::NotBuiltin,
        JSParserStrictMode::Strict, JSParserScriptMode::Module, SourceParseMode::ModuleAnalyzeMode, SuperBinding::NotNeeded, parserError);

    if (!moduleProgramNode) {
        return nullptr;
    }

    ModuleAnalyzer moduleAnalyzer(execState, moduleKey, sourceCode, moduleProgramNode->varDeclarations(), moduleProgramNode->lexicalVariables());
    return moduleAnalyzer.analyze(*moduleProgramNode);
}

JSInternalPromise* GlobalObject::moduleLoaderInstantiate(JSGlobalObject* globalObject, ExecState* execState, JSModuleLoader* loader, JSValue keyValue, JSValue sourceValue, JSValue initiator) {
    JSInternalPromiseDeferred* deferred = JSInternalPromiseDeferred::create(execState, globalObject);
    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_CATCH_SCOPE(vm);

    const Identifier moduleKey = execState->argument(0).toPropertyKey(execState);
    if (Exception* exception = scope.exception()) {
        scope.clearException();
        return deferred->reject(execState, exception->value());
    }

    JSSourceCode* jsSourceCode = jsDynamicCast<JSSourceCode*>(vm, execState->argument(1));
    RELEASE_ASSERT(jsSourceCode);
    SourceCode sourceCode = jsSourceCode->sourceCode();
    WTF::String source = sourceCode.view().toString();

    if (Exception* exception = scope.exception()) {
        scope.clearException();
        return deferred->reject(execState, exception->value());
    }

    GlobalObject* self = jsCast<GlobalObject*>(globalObject);

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

        source = WTF::ASCIILiteral("export default undefined;");
        sourceCode = SourceCode(EditableSourceProvider::create(source, WTF::emptyString() /*empty url hides module from the debugger*/, WTF::TextPosition(), JSC::SourceProviderSourceType::Module));
    }

    ParserError error;
    JSModuleRecord* moduleRecord = parseModule(execState, sourceCode, moduleKey, error);

    if (!moduleRecord || (moduleRecord->requestedModules().isEmpty() && moduleRecord->exportEntries().isEmpty() && moduleRecord->starExportEntries().isEmpty() && !json)) {
        auto moduleUrl = sourceCode.provider()->url();
        error = ParserError();
        sourceCode = SourceCode(EditableSourceProvider::create(WTF::ASCIILiteral("export default undefined;"), WTF::emptyString(), WTF::TextPosition(), JSC::SourceProviderSourceType::Module));
        moduleRecord = parseModule(execState, sourceCode, moduleKey, error);
        ASSERT(!error.isValid());

        WTF::StringBuilder moduleFunctionSource;
        moduleFunctionSource.append(COMMONJS_FUNCTION_PROLOGUE);
        moduleFunctionSource.append(source);
        moduleFunctionSource.append(COMMONJS_FUNCTION_EPILOGUE);

        JSObject* exception = nullptr;

        sourceCode = SourceCode(EditableSourceProvider::create(moduleFunctionSource.toString(), moduleUrl, WTF::TextPosition(), JSC::SourceProviderSourceType::Module));
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
    tns::instrumentation::Frame frame;
    JSC::VM& vm = execState->vm();
    auto scope = DECLARE_THROW_SCOPE(vm);
    JSValue moduleName = execState->argument(0);
    if (!moduleName.isString()) {
        return JSValue::encode(throwTypeError(execState, scope, WTF::ASCIILiteral("Expected module identifier to be a string.")));
    }

    JSValue callee = execState->callee().asCell();
    JSValue refererKey = callee.get(execState, execState->propertyNames().sourceURL);

    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    JSInternalPromise* promise = globalObject->moduleLoader()->resolve(execState, moduleName, refererKey, refererKey);

    JSValue error;
    JSFunction* errorHandler = JSNativeStdFunction::create(execState->vm(), globalObject, 1, String(), [&error](ExecState* execState) {
        error = execState->argument(0);
        return JSValue::encode(jsUndefined());
    });

    JSModuleRecord* record;
    promise->then(execState, JSNativeStdFunction::create(execState->vm(), globalObject, 1, String(), [&record, errorHandler, frame](ExecState* execState) {
                      JSValue moduleKey = execState->argument(0);

                      JSValue moduleLoader = execState->lexicalGlobalObject()->moduleLoader();
                      JSObject* function = jsCast<JSObject*>(moduleLoader.get(execState, execState->propertyNames().builtinNames().loadAndEvaluateModulePublicName()));
                      CallData callData;
                      CallType callType = JSC::getCallData(function, callData);

                      JSInternalPromise* promise = jsCast<JSInternalPromise*>(JSC::call(execState, function, callType, callData, moduleLoader, execState));
                      promise = promise->then(execState, JSNativeStdFunction::create(execState->vm(), execState->lexicalGlobalObject(), 1, String(), [moduleKey, &record, frame](ExecState* execState) {
                                                  JSValue moduleLoader = execState->lexicalGlobalObject()->moduleLoader();
                                                  JSObject* function = jsCast<JSObject*>(moduleLoader.get(execState, execState->propertyNames().builtinNames().ensureRegisteredPublicName()));

                                                  CallData callData;
                                                  CallType callType = JSC::getCallData(function, callData);

                                                  MarkedArgumentBuffer args;
                                                  args.append(moduleKey);
                                                  JSValue entry = JSC::call(execState, function, callType, callData, moduleLoader, args);
                                                  record = jsCast<JSModuleRecord*>(entry.get(execState, Identifier::fromString(execState, "module")));

                                                  if (frame.check()) {
                                                      NSString* moduleName = (NSString*)moduleKey.toWTFString(execState).createCFString().get();
                                                      NSString* appPath = [TNSRuntime current].applicationPath;
                                                      if ([moduleName hasPrefix:appPath]) {
                                                          moduleName = [moduleName substringFromIndex:appPath.length];
                                                      }
                                                      frame.log([@"require: " stringByAppendingString:moduleName].UTF8String);
                                                  }

                                                  return JSValue::encode(jsUndefined());
                                              }),
                                              errorHandler);

                      return JSValue::encode(promise);
                  }),
                  errorHandler);
    globalObject->drainMicrotasks();

    if (!error.isUndefinedOrNull() && error.isCell() && error.asCell() != nullptr) {
        return JSValue::encode(scope.throwException(execState, error));
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

JSValue GlobalObject::moduleLoaderEvaluate(JSGlobalObject* globalObject, ExecState* execState, JSModuleLoader* loader, JSValue keyValue, JSValue moduleRecordValue, JSValue initiator) {
    JSModuleRecord* moduleRecord = jsDynamicCast<JSModuleRecord*>(execState->vm(), moduleRecordValue);
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
            auto scope = DECLARE_THROW_SCOPE(vm);

            scope.throwException(execState, exception.get());
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

JSInternalPromise* GlobalObject::moduleLoaderImportModule(JSGlobalObject* globalObject, ExecState* exec, JSModuleLoader*, JSString* moduleNameValue, const SourceOrigin& sourceOrigin) {
    VM& vm = globalObject->vm();
    auto scope = DECLARE_CATCH_SCOPE(vm);

    auto rejectPromise = [&](JSValue error) {
        return JSInternalPromiseDeferred::create(exec, globalObject)->reject(exec, error);
    };

    if (sourceOrigin.isNull())
        return rejectPromise(createError(exec, ASCIILiteral("Could not resolve the module specifier.")));

    auto referrer = sourceOrigin.string();
    auto moduleName = moduleNameValue->value(exec);
    if (UNLIKELY(scope.exception())) {
        JSValue exception = scope.exception();
        scope.clearException();
        return rejectPromise(exception);
    }

    auto directoryName = extractDirectoryName(referrer.impl());
    if (!directoryName)
        return rejectPromise(createError(exec, makeString("Could not resolve the referrer name '", String(referrer.impl()), "'.")));

    return JSC::importModule(exec, Identifier::fromString(&vm, resolvePath(directoryName.value(), ModuleName(moduleName))), jsUndefined());
}

} // namespace Nativescript
