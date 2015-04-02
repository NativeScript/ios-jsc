//
//  TNSDictionaryAdapter.h
//  NativeScript
//
//  Created by Yavor Georgiev on 28.03.15.
//  Copyright (c) 2015 г. Telerik. All rights reserved.
//

@interface TNSDictionaryAdapter : NSDictionary

- (instancetype)initWithJSObject:(JSC::JSObject*)jsObject execState:(JSC::ExecState*)execState;

@end
