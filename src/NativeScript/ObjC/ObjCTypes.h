//
//  ObjCTypes.h
//  NativeScript
//
//  Created by Yavor Georgiev on 13.06.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__ObjCIdType__
#define __NativeScript__ObjCIdType__

#include <objc/runtime.h>
#include "FFIType.h"
#include "ObjCWrapperObject.h"

@interface TNSValueWrapper : NSObject

+ (void)attachValue:(JSC::JSObject*)value toHost:(id)host;

- (JSC::JSObject*)value;

- (void)detach;

@end

namespace NativeScript {
id toObject(JSC::ExecState*, const JSC::JSValue&);
JSC::JSValue toValue(JSC::ExecState*, id, Class klass = nil);
JSC::JSValue toValue(JSC::ExecState*, id, JSC::Structure* (^structureResolver)());
}

#endif /* defined(__NativeScript__ObjCIdType__) */
