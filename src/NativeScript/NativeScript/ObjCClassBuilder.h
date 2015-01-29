//
//  ObjCClassBuilder.h
//  NativeScript
//
//  Created by Jason Zhekov on 9/8/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCClassBuilder__
#define __NativeScript__ObjCClassBuilder__

#include <vector>

@protocol TNSDerivedClass
@end

namespace Metadata {
struct ProtocolMeta;
}

namespace NativeScript {
class ObjCConstructorNative;
class ObjCConstructorDerived;
class ObjCProtocolWrapper;

class ObjCClassBuilder {
public:
    ObjCClassBuilder(JSC::ExecState*, JSC::JSValue baseConstructor, JSC::JSObject* prototype, const WTF::String& className = WTF::emptyString());

    void implementProtocol(JSC::ExecState*, JSC::JSValue protocolWrapper);

    void implementProtocols(JSC::ExecState*, JSC::JSValue protocolsArray);

    void addInstanceMethod(JSC::ExecState*, const JSC::Identifier& jsName, JSC::JSCell* method);

    void addInstanceMethod(JSC::ExecState*, SEL methodName, JSC::JSCell* method, const WTF::String& typeEncoding, const WTF::String& compilerEncoding);

    void addProperty(JSC::ExecState*, const JSC::Identifier& name, const JSC::PropertyDescriptor& propertyDescriptor);

    void addInstanceMembers(JSC::ExecState*, JSC::JSObject* instanceMethods, JSC::JSValue exposedMethods);

    void addStaticMethod(JSC::ExecState*, const JSC::Identifier& jsName, JSC::JSCell* method);

    void addStaticMethod(JSC::ExecState*, SEL methodName, JSC::JSCell* method, const WTF::String& typeEncoding, const WTF::String& compilerEncoding);

    void addStaticMethods(JSC::ExecState*, JSC::JSObject* staticMethods);

    ObjCConstructorDerived* build(JSC::ExecState*);

private:
    JSC::Strong<ObjCConstructorDerived> _constructor;

    JSC::Strong<ObjCConstructorNative> _baseConstructor;

    std::vector<const Metadata::ProtocolMeta*> _protocols;
};
}

#endif /* defined(__NativeScript__ObjCClassBuilder__) */
