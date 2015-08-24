//
//  SymbolLoader.h
//  NativeScript
//
//  Created by Yavor Georgiev on 28.07.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

#ifndef __NativeScript__SymbolLoader__
#define __NativeScript__SymbolLoader__

#include <map>

namespace Metadata {
struct ModuleMeta;
}

namespace NativeScript {
class SymbolResolver;

class SymbolLoader {
public:
    static SymbolLoader& instance();

    void* loadFunctionSymbol(const Metadata::ModuleMeta*, const char* symbolName);
    void* loadDataSymbol(const Metadata::ModuleMeta*, const char* symbolName);
    bool ensureModule(const Metadata::ModuleMeta*);

private:
    SymbolResolver* resolveModule(const Metadata::ModuleMeta*);

    std::map<const Metadata::ModuleMeta*, std::unique_ptr<SymbolResolver>> _cache;
};
}

#endif /* defined(__NativeScript__SymbolLoader__) */
