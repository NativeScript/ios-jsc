//
//  TNSVersions.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 21/08/15.
//  Copyright (c) 2015 Jason Zhekov. All rights reserved.
//

#define generateVersionDeclarations(V1, V2)                                                     \
    __attribute__((availability(ios, introduced = V1)))                                         \
        @interface TNSInterface                                                                 \
    ##V2##Plus : NSObject                                                                       \
                 @end                                                                           \
                                                                                                \
    @interface TNSInterfaceMembers                                                              \
    ##V2 : NSObject                                                                             \
           @property int property                                                               \
           __attribute__((availability(ios, introduced = V1)));                                 \
                                                                                                \
    +(void)staticMethod                                                                         \
        __attribute__((availability(ios, introduced = V1)));                                    \
                                                                                                \
    -(void)instanceMethod                                                                       \
        __attribute__((availability(ios, introduced = V1)));                                    \
    @end                                                                                        \
                                                                                                \
    __attribute__((availability(ios, introduced = V1))) void TNSFunction##V2##Plus();           \
                                                                                                \
    __attribute__((availability(ios, introduced = V1))) extern const int TNSConstant##V2##Plus; \
                                                                                                \
    enum TNSEnum##V2##Plus {                                                                    \
        TNSEnum##V2##Member                                                                     \
    }                                                                                           \
    __attribute__((availability(ios, introduced = V1)))

#ifndef generateVersionImpl
#define generateVersion(V1, V2) \
    generateVersionDeclarations(V1, V2)
#else
#define generateVersion(V1, V2)          \
    generateVersionDeclarations(V1, V2); \
                                         \
    @implementation TNSInterface         \
    ##V2##Plus                           \
        @end                             \
                                         \
    @implementation TNSInterfaceMembers  \
    ##V2                                 \
        + (void)staticMethod{}           \
                                         \
        - (void)instanceMethod {}        \
    @end                                 \
                                         \
    void TNSFunction##V2##Plus() {}      \
                                         \
    const int TNSConstant##V2##Plus = 0
#endif

#define generateMinors(MAJOR)              \
    generateVersion(MAJOR##.0, MAJOR##_0); \
    generateVersion(MAJOR##.1, MAJOR##_1); \
    generateVersion(MAJOR##.2, MAJOR##_2); \
    generateVersion(MAJOR##.3, MAJOR##_3); \
    generateVersion(MAJOR##.4, MAJOR##_4); \
    generateVersion(MAJOR##.5, MAJOR##_5);

generateMinors(9);
generateMinors(10);
generateMinors(11);
generateMinors(12);
generateMinors(13);
generateMinors(14);
generateMinors(15);

// max availability version that can be currently represented in the binary metadata is 31.7 (major << 3 | minor) -> uint8_t
#define MAX_AVAILABILITY 31.7

@interface TNSInterfaceAlwaysAvailable : NSObject
@end

__attribute__((availability(ios, introduced = MAX_AVAILABILITY)))
@interface TNSInterfaceNeverAvailable : TNSInterfaceAlwaysAvailable
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"
@interface TNSInterfaceNeverAvailableDescendant : TNSInterfaceNeverAvailable
@end
#pragma clang diagnostic pop
