//
//  TNSDeclarationConflicts.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 11/09/15.
//  Copyright (c) 2015 Jason Zhekov. All rights reserved.
//

@protocol TNSInterfaceProtocolConflict <NSObject>
@end
@protocol TNSInterfaceProtocolConflictProtocol <NSObject>
@end
@interface TNSInterfaceProtocolConflict : NSObject <TNSInterfaceProtocolConflict, TNSInterfaceProtocolConflictProtocol>
@end

struct TNSStructFunctionConflict {
    int x;
};
void TNSStructFunctionConflict(struct TNSStructFunctionConflict);

struct TNSStructVarConflict {
    int x;
};
extern const int TNSStructVarConflict;
