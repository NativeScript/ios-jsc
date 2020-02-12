//
//  TNSSwiftLike.h
//  TestFixtures
//
//  Created by Martin Bekchiev on 30.10.19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
__attribute__((objc_runtime_name("_TtC17NativeScriptTests12TNSSwiftLike")))
@interface TNSSwiftLike : NSObject

@end

__attribute__((objc_runtime_name("_TtCC17NativeScriptTests12TNSSwiftLike5Inner")))
@interface TNSSwiftLikeInner : NSObject

@end

@interface TNSSwiftLikeFactory : NSObject
+ (TNSSwiftLike*)create;
+ (TNSSwiftLikeInner*)createInner;
@end

NS_ASSUME_NONNULL_END
