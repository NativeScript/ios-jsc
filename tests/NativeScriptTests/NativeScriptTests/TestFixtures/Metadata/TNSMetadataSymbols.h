//
//  TNSMetadataSymbols.h
//  NativeScriptTests
//
//  Created by Ivan Buhov on 9/16/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#ifndef __NativeScriptTests__TNSMetadataSymbols__
#define __NativeScriptTests__TNSMetadataSymbols__

@protocol TNSDuplicatesProtocol2 <NSObject>

-(NSString *) protocolDupli: (NSString *) string1 Cate: (NSString *) string2;

@end

@protocol TNSDuplicatesProtocol1 <TNSDuplicatesProtocol2>

-(NSString *) protocolDupliCate: (NSString *) string;

@end

@interface TNSDuplicatesInterface : NSObject<TNSDuplicatesProtocol2>

-(NSString *) localDuplicate: (NSString *) string;
-(NSString *) localDuplicate;

-(NSString *) protocolDupliCate;
-(NSString *) protocolDupli: (NSString *) string1 cate: (NSString *) string2;
-(NSString *) protocolDupliCate: (NSString *) string;

@end


#endif /* defined(__NativeScriptTests__TNSMetadataSymbols__) */
