//
//  TNSDebugging.h
//  TNSDebugging
//
//  Created by Ivan Buhov on 10/10/14.
//  Copyright (c) 2014 Telerik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <NativeScript/NativeScript.h>

@interface TNSRuntime (TNSDebugging)

- (id)enableDebuggingWithName:(NSString*)name;

@end
