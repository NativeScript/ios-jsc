//
//  ObjCProtocolWrapper.h
//  NativeScript
//
//  Created by Jason Zhekov on 8/8/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCProtocolObject__
#define __NativeScript__ObjCProtocolObject__

namespace Metadata {
struct ProtocolMeta;
}

namespace NativeScript {
class ObjCPrototype;

class ObjCProtocolWrapper : public JSC::JSNonFinalObject {
public:
    typedef JSC::JSNonFinalObject Base;

    static const unsigned StructureFlags = JSC::OverridesGetOwnPropertySlot | Base::StructureFlags;

    DECLARE_INFO;

    static ObjCProtocolWrapper* create(JSC::VM& vm, JSC::Structure* structure, ObjCPrototype* prototype, const Metadata::ProtocolMeta* metadata, Protocol* aProtocol = nil) {
        ObjCProtocolWrapper* cell = new (NotNull, JSC::allocateCell<ObjCProtocolWrapper>(vm.heap)) ObjCProtocolWrapper(vm, structure);
        cell->finishCreation(vm, prototype, metadata, aProtocol);
        return cell;
    }

    static JSC::Structure* createStructure(JSC::VM& vm, JSC::JSGlobalObject* globalObject, JSC::JSValue prototype) {
        return JSC::Structure::create(vm, globalObject, prototype, JSC::TypeInfo(JSC::InternalFunctionType, StructureFlags), info());
    }

    static WTF::String className(const JSObject* object);

    const Metadata::ProtocolMeta* metadata() const {
        return this->_metadata;
    }

    Protocol* protocol() const {
        return this->_protocol;
    }

private:
    ObjCProtocolWrapper(JSC::VM& vm, JSC::Structure* structure)
        : Base(vm, structure) {
    }

    void finishCreation(JSC::VM& vm, ObjCPrototype* prototype, const Metadata::ProtocolMeta* metadata, Protocol* aProtocol);

    static bool getOwnPropertySlot(JSC::JSObject*, JSC::ExecState*, JSC::PropertyName, JSC::PropertySlot&);

    const Metadata::ProtocolMeta* _metadata;

    Protocol* _protocol;
};
} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCProtocolObject__) */
