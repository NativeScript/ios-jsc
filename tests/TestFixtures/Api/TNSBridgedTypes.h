//
//  TNSBridgedTypes.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 6/10/15.
//  Copyright (c) 2015 Jason Zhekov. All rights reserved.
//

typedef const struct CF_BRIDGED_TYPE(id) __TNSBridgedType* TNSBridgedTypeRef;
TNSBridgedTypeRef TNSBridgedGet();

typedef struct CF_BRIDGED_MUTABLE_TYPE(id) __TNSMutableBridgedType* TNSMutableBridgedTypeRef;
TNSMutableBridgedTypeRef TNSMutableBridgedGet();

typedef const struct CF_RELATED_TYPE(id, , ) __TNSRelatedType* TNSRelatedTypeRef;
TNSRelatedTypeRef TNSRelatedGet();
