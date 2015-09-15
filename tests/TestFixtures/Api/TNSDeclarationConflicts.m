//
//  TNSDeclarationConflicts.m
//  NativeScriptTests
//
//  Created by Jason Zhekov on 11/09/15.
//  Copyright (c) 2015 Jason Zhekov. All rights reserved.
//

#import "TNSDeclarationConflicts.h"

@implementation TNSInterfaceProtocolConflict
@end

void TNSStructFunctionConflict(struct TNSStructFunctionConflict str) {
    TNSLog(@(str.x).stringValue);
}

const int TNSStructVarConflict = 42;
