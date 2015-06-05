//
//  ObjCProtocolWrapper.mm
//  NativeScript
//
//  Created by Jason Zhekov on 8/8/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#include "ObjCProtocolWrapper.h"
#include "Metadata.h"

namespace NativeScript {
using namespace JSC;
using namespace Metadata;

const ClassInfo ObjCProtocolWrapper::s_info = { "ObjCProtocolWrapper", &Base::s_info, 0, CREATE_METHOD_TABLE(ObjCProtocolWrapper) };

void ObjCProtocolWrapper::finishCreation(VM& vm, const ProtocolMeta* metadata, Protocol* aProtocol) {
    Base::finishCreation(vm);
    this->_metadata = metadata;
    this->_protocol = aProtocol;
}

WTF::String ObjCProtocolWrapper::className(const JSObject* object) {
    ObjCProtocolWrapper* protocolWrapper = (ObjCProtocolWrapper*)object;
    const char* protocolName = protocolWrapper->metadata()->name();
    return protocolName;
}
};
