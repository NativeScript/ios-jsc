//
//  TNSTestCases.h
//  NativeScriptTests
//
//  Created by Jason Zhekov on 2/19/14.
//  Copyright (c) 2014 Jason Zhekov. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TNSTestCommon.h"

#import "TestFixtures/Api/TNSApi.h"

#import "TestFixtures/Functions/TNSFunctions.h"

#import "TestFixtures/Marshalling/TNSPrimitives.h"
#import "TestFixtures/Marshalling/TNSObjCTypes.h"
#import "TestFixtures/Marshalling/TNSRecords.h"
#import "TestFixtures/Marshalling/TNSPrimitivePointers.h"
#import "TestFixtures/Marshalling/TNSFunctionPointers.h"

#import "TestFixtures/Interfaces/TNSMethodCalls.h"
#import "TestFixtures/Interfaces/TNSConstructorResolution.h"
#import "TestFixtures/Interfaces/TNSInheritance.h"

#import "TestFixtures/Metadata/TNSMetadataSymbols.h"

#ifdef __IPHONE_7_1
#import <iAd/ADClient.h>
#endif
#import <MapKit/MapKit.h>
#import <SpriteKit/SpriteKit.h>
#import <StoreKit/StoreKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MediaPlayer/MediaPlayer.h>

// This should be last
#import "TestFixtures/TNSTestNativeCallbacks.h"
