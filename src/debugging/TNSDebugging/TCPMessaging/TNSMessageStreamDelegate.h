//
//  TNSMessageStreamDelegate.h
//  TNSDebugging
//
//  Created by Panayot Cankov on 1/27/15.
//  Copyright (c) 2015 Telerik. All rights reserved.
//

@protocol TNSMessageStreamDelegate

- (void) closed: (id) stream;
- (void) receivedMessage: (id) message from: (id) stream;

@end
