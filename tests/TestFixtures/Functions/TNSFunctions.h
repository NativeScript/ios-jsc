//
//  TNSFunctions.h
//  NativeScriptTests
//
//  Created by Yavor Georgiev on 25.02.14.
//  Copyright (c) 2014 г. Jason Zhekov. All rights reserved.
//

#include "../Interfaces/TNSInheritance.h"
#include <sys/resource.h>

CFArrayRef CFArrayCreateWithString(CFStringRef string);

struct rusage_info_v0 getBlacklistedRusage_info_v0();

TNSBlacklistedInterface<TNSBlacklistedProtocol>* getTNSBlacklisted();
BOOL funcWithTNSBlacklisted(TNSBlacklistedInterface* arg);
