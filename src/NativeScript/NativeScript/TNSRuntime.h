//
//  TNSRuntime.h
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

@interface TNSRuntime : NSObject {
@private
    void* _impl;
}

@property(nonatomic, retain) NSString* applicationPath;

- (instancetype)initWithApplicationPath:(NSString*)applicationPath;

- (JSGlobalContextRef)globalContext;

- (void)executeModule:(NSString*)entryPointModuleIdentifier error:(JSValueRef*)error;

@end