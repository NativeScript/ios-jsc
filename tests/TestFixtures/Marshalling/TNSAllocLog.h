//
//  TNSAllocLog.h
//  NativeScript
//
//  Created by Martin Bekchiev on 1.02.19.
//

#ifndef TNSAllocLog_h
#define TNSAllocLog_h

@interface TNSAllocLog : NSObject

// Disable ARC for TextFixtures.a and uncomment for debugging puproses
//- (instancetype)retain;
//- (void)release;

- (instancetype)init;
- (void)dealloc;

@end

#endif /* TNSAllocLog_h */
