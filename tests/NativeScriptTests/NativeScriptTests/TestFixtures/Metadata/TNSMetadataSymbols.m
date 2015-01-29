//
//  TNSMetadataSymbols.m
//  NativeScriptTests
//
//  Created by Ivan Buhov on 9/16/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#import "TNSMetadataSymbols.h"

@implementation TNSDuplicatesInterface : NSObject

- (NSString *)localDuplicate:(NSString *)string {
    return @"Local duplicate 1";
}
- (NSString *)localDuplicate {
    return @"Local duplicate 2";
}

- (NSString *)protocolDupli:(NSString *)string1 Cate:(NSString *)string2 {
    return @"protocolDupli:Cate:";
}

- (NSString *)protocolDupliCate {
    return @"protocolDupliCate";
}
- (NSString *)protocolDupli:(NSString *)string1 cate:(NSString *)string2 {
    return @"protocolDupli:cate:";
}
- (NSString *)protocolDupliCate:(NSString *)string {
    return @"protocolDupliCate:";
}

@end