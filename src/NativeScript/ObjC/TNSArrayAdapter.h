//
//  TNSArrayAdapter.h
//  NativeScript
//
//  Created by Yavor Georgiev on 27.03.15.
//  Copyright (c) 2015 г. Telerik. All rights reserved.
//

@interface TNSArrayAdapter : NSArray

- (instancetype)initWithJSObject:(JSC::JSObject*)jsObject execState:(JSC::ExecState*)execState;

@end
