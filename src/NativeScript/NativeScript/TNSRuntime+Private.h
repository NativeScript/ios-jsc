//
//  TNSRuntime+Private.h
//  NativeScript
//
//  Created by Yavor Georgiev on 01.08.14.
//  Copyright (c) 2014 г. Telerik. All rights reserved.
//

@interface TNSRuntime () {
    WTF::RefPtr<JSC::VM> _vm;
    JSC::Strong<NativeScript::GlobalObject> _globalObject;
    NSString* _applicationPath;
    WTF::Vector<JSC::SourceProvider*> _sourceProviders;
}

@end
