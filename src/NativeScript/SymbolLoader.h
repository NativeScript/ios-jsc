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
class SymbolResolver {
public:
    virtual void* loadFunctionSymbol(const char* symbolName) = 0;
    virtual void* loadDataSymbol(const char* symbolName) = 0;
    virtual bool load() = 0;
};

class SymbolLoader {
public:
    static SymbolLoader& instance();

    void* loadFunctionSymbol(const Metadata::ModuleMeta*, const char* symbolName);
    void* loadDataSymbol(const Metadata::ModuleMeta*, const char* symbolName);
    bool ensureModule(const Metadata::ModuleMeta*);

    SymbolResolver* resolveModule(const Metadata::ModuleMeta*);

private:
    std::map<const Metadata::ModuleMeta*, std::unique_ptr<SymbolResolver>> _cache;
};
}

#endif /* defined(__NativeScript__SymbolLoader__) */
