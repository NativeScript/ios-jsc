//
//  Prefix header
//
//  The contents of this file are implicitly included at the beginning of every source file.
//

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

// Clang format reorders these headers and this fails the build
// clang-format off
#ifdef __cplusplus
#include <JavaScriptCore/config.h>
#include <JavaScriptCore/JSCInlines.h>
#include <JavaScriptCore/Error.h>
#include "RecordType.h"
#include "GlobalObject.h"
#include "JSWarnings.h"
#endif
// clang-format on

#include <JavaScriptCore/JavaScript.h>
