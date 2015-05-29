//
//  TNSClassWithPlaceholder.m
//  NativeScript
//
//  Created by Yavor Georgiev on 26.05.15.
//  Copyright (c) 2015 г. Telerik. All rights reserved.
//

#import "TNSClassWithPlaceholder.h"

@interface TNSClassWithPlaceholderReal : TNSClassWithPlaceholder

@end

@implementation TNSClassWithPlaceholderReal

- (NSString *)description {
    return @"real";
}

@end

@interface TNSClassWithPlaceholderPlaceholder : TNSClassWithPlaceholder

@end

@implementation TNSClassWithPlaceholderPlaceholder

- (TNSClassWithPlaceholder *)init {
    return (id)[[TNSClassWithPlaceholderReal alloc] init];
}

- (oneway void)release {
    [super release];

    TNSLog(@"release on placeholder called");
}

@end

@implementation TNSClassWithPlaceholder

+ (instancetype)alloc {
    if (self == [TNSClassWithPlaceholder class]) {
        return [TNSClassWithPlaceholderPlaceholder alloc];
    }

    return [super alloc];
}

@end
