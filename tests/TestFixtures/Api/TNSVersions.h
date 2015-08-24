//
//  TNSVersions.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 21/08/15.
//  Copyright (c) 2015 Jason Zhekov. All rights reserved.
//

#define generateVersionDeclarations(V1, V2)                \
    __attribute__((availability(ios, introduced=V1)))      \
    @interface TNSInterface##V2##Plus : NSObject           \
    @end                                                   \
                                                           \
    @interface TNSInterfaceMembers##V2 : NSObject          \
        @property int property                             \
        __attribute__((availability(ios, introduced=V1))); \
                                                           \
        + (void)staticMethod                               \
        __attribute__((availability(ios, introduced=V1))); \
                                                           \
        - (void)instanceMethod                             \
        __attribute__((availability(ios, introduced=V1))); \
    @end                                                   \
                                                           \
    __attribute__((availability(ios, introduced=V1)))      \
    void TNSFunction##V2##Plus();                          \
                                                           \
    __attribute__((availability(ios, introduced=V1)))      \
    extern const int TNSConstant##V2##Plus;                \
                                                           \
    enum TNSEnum##V2##Plus {                               \
        TNSEnum##V2##Member                                \
    } __attribute__((availability(ios, introduced=V1)))

#ifndef generateVersionImpl
    #define generateVersion(V1, V2)         \
        generateVersionDeclarations(V1, V2)
#else
    #define generateVersion(V1, V2)             \
        generateVersionDeclarations(V1, V2);    \
                                                \
        @implementation TNSInterface##V2##Plus  \
        @end                                    \
                                                \
        @implementation TNSInterfaceMembers##V2 \
            + (void)staticMethod { }            \
                                                \
            - (void)instanceMethod { }          \
        @end                                    \
                                                \
        void TNSFunction##V2##Plus() { }        \
                                                \
        const int TNSConstant##V2##Plus = 0
#endif

generateVersion(7.0, 7_0);
generateVersion(7.1, 7_1);
generateVersion(7.2, 7_2);
generateVersion(7.3, 7_3);
generateVersion(7.4, 7_4);
generateVersion(7.5, 7_5);

generateVersion(8.0, 8_0);
generateVersion(8.1, 8_1);
generateVersion(8.2, 8_2);
generateVersion(8.3, 8_3);
generateVersion(8.4, 8_4);
generateVersion(8.5, 8_5);

generateVersion(9.0, 9_0);
generateVersion(9.1, 9_1);
generateVersion(9.2, 9_2);
generateVersion(9.3, 9_3);
generateVersion(9.4, 9_4);
generateVersion(9.5, 9_5);

generateVersion(10.0, 10_0);
generateVersion(10.1, 10_1);
generateVersion(10.2, 10_2);
generateVersion(10.3, 10_3);
generateVersion(10.4, 10_4);
generateVersion(10.5, 10_5);
