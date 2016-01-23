//
//  ObjCMetadataModule.h
//  NativeScript
//
//  Created by Yavor Georgiev on 22.01.16 г..
//
//

#pragma once

#include "Metadata.h"
#include "SymbolLoader.h"

namespace NativeScript {
class ObjCMetadataModule : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static ObjCMetadataModule* create(JSC::VM& vm, JSC::Structure* structure, const Metadata::ModuleMeta* module) {
        ObjCMetadataModule* cell = new (NotNull, JSC::allocateCell<ObjCMetadataModule>(vm.heap)) ObjCMetadataModule(vm, structure, module);
        cell->finishCreation(vm);
        return cell;
    }

    DECLARE_INFO;

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::ObjectType, StructureFlags), info());
    }

    const Metadata::ModuleMeta* module() const {
        return this->_module;
    }

    SymbolResolver* symbolResolver() const {
        return this->_symbolResolver;
    }

private:
    ObjCMetadataModule(JSC::VM& vm, JSC::Structure* structure, const Metadata::ModuleMeta* module)
        : Base(vm, structure)
        , _module(module)
        , _symbolResolver(SymbolLoader::instance().resolveModule(module)) {
    }

    const Metadata::ModuleMeta* _module;

    SymbolResolver* _symbolResolver;
};
}