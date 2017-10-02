//
//  FFICache.h
//  NativeScript
//
//  Created by Teodor Dermendzhiev on 02/10/2017.
//
//

#ifndef __NativeScript__FFICache__
#define __NativeScript__FFICache__

#include "FFIType.h"
#include <vector>

namespace NativeScript {

struct SignatureHash {

    std::size_t operator()(std::vector<const ffi_type*> signature) const {
        std::size_t seed = 2166136261;

        for (size_t i = 0; i < signature.size(); i++) {
            seed = (seed ^ reinterpret_cast<size_t>(signature[i])) * 16777619U;
        }
        return seed;
    }
};

class FFICache {

public:
    std::unordered_map<std::vector<const ffi_type*>, std::shared_ptr<ffi_cif>, SignatureHash> cifCache;

    static FFICache* global();
};

} // namespace NativeScript

#endif /* FFICache_h */
