//
//  Utilities.m
//  NativeScriptTests
//
//  Created by Panayot Cankov on 8/12/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#import "Utilities.h"

NSString *toString(JSGlobalContextRef context, JSValueRef value) {
    JSStringRef errorMessageRef = JSValueToStringCopy(context, value, NULL);
    size_t errorSize = JSStringGetMaximumUTF8CStringSize(errorMessageRef);
    char errorMessage[errorSize];
    JSStringGetUTF8CString(errorMessageRef, errorMessage, errorSize);
    JSStringRelease(errorMessageRef);
    return [NSString stringWithUTF8String:errorMessage];
}
