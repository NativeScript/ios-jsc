//
//  unzip.h
//  TKLiveSync
//
//  Created by Jason Zhekov on 7/29/16.
//  Copyright © 2016 Telerik. All rights reserved.
//

#ifndef unzip_h
#define unzip_h

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Copied from https://github.com/NativeScript/android-runtime/blob/v2.1.0/runtime/src/main/jni/AssetExtractor.cpp
int64_t unzip(const char* syncZipPath, const char* destination);

#ifdef __cplusplus
}
#endif

#endif /* unzip_h */
