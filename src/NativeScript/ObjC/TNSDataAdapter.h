//
//  TNSDataAdapter.h
//  NativeScript
//
//  Created by Yavor Georgiev on 20.07.15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

@interface TNSDataAdapter : NSMutableData

- (instancetype)initWithJSObject:(JSC::JSObject*)jsObject execState:(JSC::ExecState*)execState;

@end
