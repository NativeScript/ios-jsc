//
//  ObjCMetadataModule.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 22.01.16 г..
//
//

#include "ObjCMetadataModule.h"
#include <JavaScriptCore/JSModuleEnvironment.h>

namespace NativeScript {
using namespace JSC;

const ClassInfo ObjCMetadataModule::s_info = { "ObjCMetadataModule", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCMetadataModule) };
    
EncodedJSValue ObjCMetadataModule::lazyMetadataSymbolGetter(ExecState* execState, JSC::JSObject* slotBase, EncodedJSValue thisValue, PropertyName propertyName) {
    JSModuleEnvironment* moduleEnvironment = jsCast<JSModuleEnvironment*>(slotBase);
    VM& vm = execState->vm();
    GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());
    
    ObjCMetadataModule* metadataModule = jsCast<ObjCMetadataModule*>(moduleEnvironment->moduleRecord()->getDirect(vm, globalObject->metadataModuleIdentifier()));
    
    WTF::StringImpl* publicName = propertyName.publicName();
    ASSERT(publicName);
    
    if (const Metadata::Meta* meta = metadataModule->module()->globalTable->findMeta(publicName)) {
        JSValue symbolWrapper = jsString(&vm, meta->jsName());
        moduleEnvironment->putDirect(vm, propertyName, symbolWrapper);
        return JSValue::encode(symbolWrapper);
    }
    
    return 0;
}
}