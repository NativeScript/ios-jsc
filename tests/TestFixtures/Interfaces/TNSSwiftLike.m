//
//  TNSSwiftLike.m
//  TestFixtures
//
//  Created by Martin Bekchiev on 30.10.19.
//

#import "TNSSwiftLike.h"

@implementation TNSSwiftLike

@end

@implementation TNSSwiftLikeInner

@end

@implementation TNSSwiftLikeFactory
+ (TNSSwiftLike*)create {
    return [TNSSwiftLike new];
}

+ (TNSSwiftLikeInner*)createInner {
    return [TNSSwiftLikeInner new];
}
@end
