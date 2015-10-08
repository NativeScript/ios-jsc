//
//  TNSBridgedTypes.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 6/10/15.
//  Copyright (c) 2015 Jason Zhekov. All rights reserved.
//

typedef const struct CF_BRIDGED_TYPE(id) __TNSObject* TNSObjectRef;
TNSObjectRef TNSObjectGet();

typedef struct CF_BRIDGED_MUTABLE_TYPE(id) __TNSMutableObject* TNSMutableObjectRef;
TNSMutableObjectRef TNSMutableObjectGet();

// TODO: Handle CF_RELATED_TYPE, too
