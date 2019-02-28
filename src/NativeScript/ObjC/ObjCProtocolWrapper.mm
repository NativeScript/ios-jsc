//
//  ObjCProtocolWrapper.mm
//  NativeScript
//
//  Created by Jason Zhekov on 8/8/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCProtocolWrapper.h"
#include "Metadata.h"
#include "ObjCMethodCall.h"
#include "ObjCPrototype.h"
#include "SymbolLoader.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

const ClassInfo ObjCProtocolWrapper::s_info = { "ObjCProtocolWrapper", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(ObjCProtocolWrapper) };

void ObjCProtocolWrapper::finishCreation(VM& vm, ObjCPrototype* prototype, const ProtocolMeta* metadata, Protocol* aProtocol) {
    Base::finishCreation(vm);
    this->putDirect(vm, vm.propertyNames->prototype, prototype, PropertyAttribute::DontEnum | PropertyAttribute::DontDelete | PropertyAttribute::ReadOnly);
    this->_metadata = metadata;
    this->_protocol = aProtocol;
}

WTF::String ObjCProtocolWrapper::className(const JSObject* object, VM&) {
    ObjCProtocolWrapper* protocolWrapper = (ObjCProtocolWrapper*)object;
    const char* protocolName = protocolWrapper->metadata()->name();
    return protocolName;
}

bool ObjCProtocolWrapper::getOwnPropertySlot(JSObject* object, ExecState* execState, PropertyName propertyName, PropertySlot& propertySlot) {
    if (Base::getOwnPropertySlot(object, execState, propertyName, propertySlot)) {
        return true;
    }

    if (UNLIKELY(!propertyName.publicName())) {
        return false;
    }

    ObjCProtocolWrapper* protocol = jsCast<ObjCProtocolWrapper*>(object);

    MembersCollection metas = protocol->_metadata->getStaticMethods(propertyName.publicName(), nullptr);
    if (metas.size() > 0) {
        SymbolLoader::instance().ensureModule((*metas.begin())->topLevelModule());

        GlobalObject* globalObject = jsCast<GlobalObject*>(execState->lexicalGlobalObject());

        auto wrapper = ObjCMethodWrapper::create(execState->vm(), globalObject, globalObject->objCMethodWrapperStructure(), metas);
        object->putDirect(execState->vm(), propertyName, wrapper.get());
        propertySlot.setValue(object, static_cast<unsigned>(PropertyAttribute::None), wrapper.get());
        return true;
    }

    return false;
}
};
