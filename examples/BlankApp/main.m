#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <NativeScript.h>

static NSString *toString(JSContextRef context, JSValueRef value) {
  JSStringRef errorMessageRef = JSValueToStringCopy(context, value, NULL);
  size_t errorSize = JSStringGetMaximumUTF8CStringSize(errorMessageRef);
  char errorMessage[errorSize];
  JSStringGetUTF8CString(errorMessageRef, errorMessage, errorSize);
  JSStringRelease(errorMessageRef);
  return [NSString stringWithUTF8String:errorMessage];
}

int main(int argc, char *argv[]) {
  @autoreleasepool {
    TNSRuntime *runtime = [[TNSRuntime alloc]
        initWithApplicationPath:[NSBundle mainBundle].bundlePath];
    TNSRuntimeInspector.logsToSystemConsole = YES;

    NSError *error = nil;
    NSString *script =
        [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
                                               pathForResource:@"bootstrap"
                                                        ofType:@"js"
                                                   inDirectory:@"app"]
                                  encoding:NSUTF8StringEncoding
                                     error:&error];

    if (error) {
      NSLog(@"%@", error.localizedDescription);
      return 1;
    }

    JSValueRef errorRef = NULL;

    JSStringRef scriptRef = JSStringCreateWithUTF8CString(script.UTF8String);
    JSStringRef sourceURLRef =
        JSStringCreateWithUTF8CString("app/bootstrap.js");
    JSObjectRef globalObjectRef =
        JSContextGetGlobalObject(runtime.globalContext);
    JSEvaluateScript(runtime.globalContext, scriptRef, globalObjectRef,
                     sourceURLRef, 0, &errorRef);
    JSStringRelease(sourceURLRef);
    JSStringRelease(scriptRef);

    if (errorRef) {
      NSLog(@"%@", toString(runtime.globalContext, errorRef));
      return 1;
    }

    return 0;
  }
}
