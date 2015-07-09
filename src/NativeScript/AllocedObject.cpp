//
//  AllocedObject.cpp
//  NativeScript
//
//  Created by Ivan Buhov on 7/9/15.
//
//

#include "AllocedObject.h"

namespace NativeScript {
using namespace JSC;

const ClassInfo AllocedObject::s_info = { "AllocedObject", &Base::s_info, 0, CREATE_METHOD_TABLE(AllocedObject) };
}