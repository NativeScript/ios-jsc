//
//  JSWeakRefInstance.cpp
//  NativeScript
//
//  Created by Yavor Georgiev on 02.10.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "JSWeakRefInstance.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo JSWeakRefInstance::s_info = { "WeakRef", &Base::s_info, nullptr, nullptr, CREATE_METHOD_TABLE(JSWeakRefInstance) };
} // namespace NativeScript
