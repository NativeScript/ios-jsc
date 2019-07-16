//
//  ObjCTypes.h
//  NativeScript
//
//  Created by Yavor Georgiev on 13.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCIdType__
#define __NativeScript__ObjCIdType__

#include <Metadata.h>
#include <wtf/Vector.h>

namespace NativeScript {
id toObject(JSC::ExecState*, const JSC::JSValue&);
JSC::JSValue toValue(JSC::ExecState*, id, Class klass = nil, const Metadata::ProtocolMetaVector& = Metadata::ProtocolMetaVector());
JSC::JSValue toValue(JSC::ExecState*, id, JSC::Structure* (^structureResolver)());
} // namespace NativeScript

#endif /* defined(__NativeScript__ObjCIdType__) */
