//
//  ModuleObject.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 5/8/15.
//
//

#include "ModuleObject.h"
#include <string>
//#include <JavaScriptCore/FunctionConstructor.h>
//#include <JavaScriptCore/JSGlobalObjectInspectorController.h>
//#include <JavaScriptCore/Microtask.h>
//#include <JavaScriptCore/Completion.h>
//#include "ObjCProtocolWrapper.h"
//#include "ObjCConstructorNative.h"
#include "SymbolLoader.h"
//#include "FFIFunctionCall.h"
//#include "RecordConstructor.h"
//#include "TypeFactory.h"

namespace NativeScript {
    using namespace JSC;
    using namespace Metadata;
    
    const unsigned ModuleObject::StructureFlags = OverridesGetOwnPropertySlot | Base::StructureFlags;
    
    const ClassInfo ModuleObject::s_info = { "ModuleObject", &Base::s_info, 0, 0, CREATE_METHOD_TABLE(ModuleObject) };
    
    void ModuleObject::finishCreation(VM &vm, const Metadata::ModuleMeta* moduleMetadata) {
        Base::finishCreation(vm);
        this->_moduleMetadata = moduleMetadata;
        
        WTF::CString nameStr = name.utf8();
        SymbolLoader::instance().ensureFramework(nameStr.data());
    }
    
    WTF::String ModuleObject::className(const JSObject *object) {
        const ModuleObject* moduleObject = jsCast<const ModuleObject*>(object);
        return moduleObject->_moduleMetadata->name();
    }
    
    bool ModuleObject::getOwnPropertySlot(JSObject* object, ExecState* execState, PropertyName propertyName, PropertySlot& propertySlot) {
        if (Base::getOwnPropertySlot(object, execState, propertyName, propertySlot)) {
            return true;
        }
        
        ModuleObject* moduleObject = jsCast<ModuleObject*>(object);
        GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
        VM& vm = execState->vm();
        
        //    if (propertyName == globalObject->_interopIdentifier) {
        //        propertySlot.setValue(object, DontEnum | ReadOnly | DontDelete, globalObject->interop());
        //        return true;
        //    }
        
        StringImpl* symbolName = propertyName.publicName();
        const Meta* symbolMeta = getMetadata()->findMeta(symbolName);
        if (!symbolMeta || !WTF::equalIgnoringCase(moduleObject->_name, symbolMeta->moduleName()))
            return false;
        
        JSValue symbolWrapper;
        
        switch (symbolMeta->type()) {
            case Interface: {
                Class klass = objc_getClass(symbolMeta->name());
                if (!klass) {
                    klass = objc_getClass(symbolMeta->name());
                }
                
                if (klass) {
                    symbolWrapper = globalObject->typeFactory()->getObjCNativeConstructor(globalObject, symbolMeta->jsName());
                    moduleObject->_objCConstructors.insert(std::pair<Class, Strong<ObjCConstructorBase>>(klass, Strong<ObjCConstructorBase>(vm, jsCast<ObjCConstructorBase*>(symbolWrapper))));
                }
                break;
            }
            case ProtocolType: {
                Protocol* aProtocol = objc_getProtocol(symbolMeta->name());
                if (!aProtocol) {
                    aProtocol = objc_getProtocol(symbolMeta->name());
                }
                
                symbolWrapper = ObjCProtocolWrapper::create(vm, ObjCProtocolWrapper::createStructure(vm, globalObject, globalObject->objectPrototype()), static_cast<const ProtocolMeta*>(symbolMeta), aProtocol);
                if (aProtocol) {
                    auto pair = std::pair<const Protocol*, Strong<ObjCProtocolWrapper>>(aProtocol, Strong<ObjCProtocolWrapper>(vm, jsCast<ObjCProtocolWrapper*>(symbolWrapper)));
                    moduleObject->_objCProtocolWrappers.insert(pair);
                }
                break;
            }
            case Union: {
                //        symbolWrapper = globalObject->typeFactory()->createOrGetUnionConstructor(globalObject, symbolName);
                break;
            }
            case Struct: {
                symbolWrapper = globalObject->typeFactory()->getStructConstructor(globalObject, symbolName);
                break;
            }
            case MetaType::Function: {
                void* functionSymbol = SymbolLoader::instance().loadFunctionSymbol(symbolMeta->moduleName(), symbolMeta->name());
                if (functionSymbol) {
                    const FunctionMeta* functionMeta = static_cast<const FunctionMeta*>(symbolMeta);
                    Metadata::MetaFileOffset cursor = functionMeta->encodingOffset();
                    JSCell* returnType = globalObject->typeFactory()->parseType(globalObject, cursor);
                    const WTF::Vector<JSCell*> parametersTypes = globalObject->typeFactory()->parseTypes(globalObject, cursor, functionMeta->encodingCount() - 1);
                    symbolWrapper = FFIFunctionCall::create(vm, globalObject->ffiFunctionCallStructure(), functionSymbol, functionMeta->jsName(), returnType, parametersTypes, functionMeta->ownsReturnedCocoaObject());
                }
                break;
            }
            case Var: {
                const VarMeta* varMeta = static_cast<const VarMeta*>(symbolMeta);
                void* varSymbol = SymbolLoader::instance().loadDataSymbol(varMeta->moduleName(), varMeta->name());
                if (varSymbol) {
                    MetaFileOffset cursor = varMeta->encodingOffset();
                    JSCell* symbolType = globalObject->typeFactory()->parseType(globalObject, cursor);
                    symbolWrapper = getFFITypeMethodTable(symbolType).read(execState, varSymbol, symbolType);
                }
                break;
            }
            case JsCode: {
                WTF::String source = WTF::String(static_cast<const JsCodeMeta*>(symbolMeta)->jsCode());
                symbolWrapper = evaluate(execState, makeSource(source));
                break;
            }
            default: {
                break;
            }
        }
        
        if (symbolWrapper) {
            object->putDirect(vm, propertyName, symbolWrapper);
            propertySlot.setValue(object, None, symbolWrapper);
            return true;
        }
        
        return false;
    }
    
    void ModuleObject::getOwnPropertyNames(JSObject* object, ExecState* execState, PropertyNameArray& propertyNames, EnumerationMode enumerationMode) {
        ModuleObject* moduleObject = jsCast<ModuleObject*>(object);
        
        MetaFileReader* metadata = getMetadata();
        for (MetaIterator it = metadata->begin(); it != metadata->end(); ++it) {
            if (WTF::equalIgnoringCase(moduleObject->_name, (*it)->moduleName()))
                propertyNames.add(Identifier(execState, (*it)->jsName()));
        }
        
        Base::getOwnPropertyNames(object, execState, propertyNames, enumerationMode);
    }
}