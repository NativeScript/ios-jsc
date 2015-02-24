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

namespace NativeScript {
class SymbolLoader {
public:
    static SymbolLoader& instance();

    void* loadFunctionSymbol(std::string libraryName, const char* symbolName);
    void* loadDataSymbol(std::string libraryName, const char* symbolName);
    bool ensureFramework(const char* frameworkName);

private:
    SymbolLoader();

    std::map<const char*, WTF::RetainPtr<CFBundleRef>> _cache;
};
}

#endif /* defined(__NativeScript__SymbolLoader__) */
