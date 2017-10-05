//
//  FFICache.cpp
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 02/10/2017.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#include "FFICache.h"
#include <stdio.h>

namespace NativeScript {

FFICache* FFICache::global() {

    static FFICache* instance;

    if (!instance)
        instance = new FFICache;
    return instance;
}

} // namespace NativeScript
